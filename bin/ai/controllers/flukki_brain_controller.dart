import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:get/get.dart';

import '../../analyze/controllers/ai_controller.dart';
import '../../analyze/project_analyse/controllers/test_analyse_controller.dart';
import '../../core/conrtollers_interfaces.dart';
import '../../home/controllers/current_project_controller.dart';
import '../../utils/file_utils.dart';
import '../models/determine_models_models.dart';
import '../models/find_helpers_models.dart';
import '../models/generate_tests_models.dart';
import '../models/mocking_analyse_model.dart';
import 'analyze_controller.dart';

FlukkiBrainController flukkiBrainController =
    handleDependency(() => FlukkiBrainController());

class FlukkiBrainController {
  final _isWorking = RxBool(false);
  final _output = RxString('');

  String get output => _output.value;

  bool get isWorking => _isWorking.value;

  set isWorking(bool value) {
    _isWorking.value = value;
  }

  void addOutputLine(String line) {
    _output.value = '${_output.value}$line\n';
  }

  Future<void> start(String path) async {
    final project = currentProjectController.currentProjectPath!;

    addOutputLine('Hello, I will write tests for this file:');
    addOutputLine(path);
    addOutputLine('');
    addOutputLine('Starting project analysis...');
    addOutputLine('');

    try {
      final filesInProjectDir = Directory(project)
          .listSync(recursive: true)
          .whereType<File>()
          .where((element) => element.path.endsWith('.dart'))
          .map((e) => e.path)
          .toList();

      List<FileLowLevelData> filesLowLevelData =
          getStructure(filesInProjectDir, project);

      //todo: get structure for these files
      final filesDataFromTestDirectory = filesLowLevelData
          .where((element) => element.path.contains('test'))
          .toList();
      final testStructure = FilesLowLevel(filesDataFromTestDirectory).toMap();

      final mockingSteps = await _prepareMockingSteps(testStructure);
      final projectFileNames = filesLowLevelData.map((e) => e.path).toList();

      final testUtils =
          await _prepareTestUtilsStructure(testStructure, project);
      final testedFileContent = File(path).readAsStringSync();

      final requiredModelsPaths = await aiController.determineModels(
        DetermineModelsRequest(
          fileContent: testedFileContent,
          filesInProject: projectFileNames.fold(
              '', (previousValue, element) => '$previousValue\n$element'),
        ),
      );

      final modelsFileContents = requiredModelsPaths.paths
          .map((e) => File('$project$e').readAsStringSync())
          .toList();

      final generateTestRequest = GenerateTestsRequest(
        mockingSteps: mockingSteps,
        models: modelsFileContents,
        testedFileContent: testedFileContent,
        utilsStructure: FilesLowLevel(testUtils).toMap(),
      );

      final generateTestResponse =
          await aiController.generateTests(generateTestRequest);

      final testFilePath = path
          .replaceAll(project, '$project/test')
          .replaceAll('.dart', '_test.dart');
      // /Users/maciek/StudioProjects/personal/test/actions/controllers/adding_action_controller_test.dart
      // /Users/maciek/StudioProjects/personal/test/actions/controller/adding_action_controller_test.dart
      final file = File(testFilePath);
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }
      file.writeAsStringSync(generateTestResponse.newTestFileContent);

      addOutputLine('I\'m done, bye');
      addOutputLine('');
    } catch (e, s) {
      addOutputLine(e.toString() + s.toString());
    }
    return;
  }

  List<FileLowLevelData> getStructure(
      List<String> filesInProjectDir, String project) {
    final List<String> filesWithProjectIncluded = [];
    for (var element in filesInProjectDir) {
      if (element.contains(project)) {
        filesWithProjectIncluded.add(element);
      } else {
        filesWithProjectIncluded.add(project + element);
      }
    }
    final dartSdkPath = currentProjectController.dartSdkPath!;
    final session = AnalysisContextCollection(
      includedPaths: filesWithProjectIncluded,
      resourceProvider: PhysicalResourceProvider.INSTANCE,
      sdkPath: dartSdkPath,
    );

    List<FileLowLevelData> filesLowLevelData = [];
    for (final file in filesWithProjectIncluded) {
      final element = session.contexts.first.currentSession.getParsedUnit(file)
          as ParsedUnitResult;
      final methods = element.unit.declarations
          .map((e) {
            if (e is ClassDeclaration) {
              return e.members
                  .whereType<MethodDeclaration>()
                  .map((e) => MethodLowLevelData(
                        e.name.toString(),
                        e.parameters?.parameters.map((param) {
                          SimpleFormalParameter parameter;
                          if (param is DefaultFormalParameter) {
                            parameter =
                                param.parameter as SimpleFormalParameter;
                          } else {
                            parameter = param as SimpleFormalParameter;
                          }
                          return ParameterLowLevelData(
                              param.name.toString(), parameter.type.toString());
                        }).toList(),
                        (e.parent as ClassDeclaration).name.toString(),
                        e.toString(),
                      ));
            } else {
              return null;
            }
          })
          .toList()
          .fold(<MethodLowLevelData>[], (previousValue, element) {
            if (element != null) {
              return previousValue..addAll(element.toList());
            } else {
              return previousValue;
            }
          });
      final classes =
          element.unit.declarations.whereType<ClassDeclaration>().map((e) {
        final properties = List<String>.from(e.members
            .whereType<FieldDeclaration>()
            .map((e) => e.fields.variables.map((e) => e.toString()).toString())
            .toList());
        return ClassLowLevelData(e.name.toString(), methods, properties);
      }).toList();
      final enums = element.unit.declarations
          .whereType<EnumDeclaration>()
          .map((e) => EnumLowLevelData(e.name.toString(),
              e.constants.map((e) => e.name.toString()).toList()))
          .toList();
      final imports = element.unit.directives;
      final fileLowLevelData = FileLowLevelData(
        file,
        classes,
        imports.map((e) => e.toString()).toList(),
        enums,
        element.unit.toString(),
        project,
      );

      filesLowLevelData.add(fileLowLevelData);
    }
    return filesLowLevelData;
  }

  @override
  void clear() {
    _output.value = '';
  }

  @override
  Future<void> loadData(String userId) async {}

  Future<String> _prepareMockingSteps(String projectStructure) async {
    String? mocking = currentProjectController.mockingSteps;
    if (mocking != null) {
      return mocking;
    }

    String? path;
    List<String> alreadyAnalyzed = [];

    while (true) {
      String? fileContent;
      if (path != null) {
        fileContent = File(path).readAsStringSync();
      }
      final request = MockingAnalyseRequest(
        projectStructure: projectStructure,
        fileContent: fileContent,
        alreadyAnalyzedFiles: alreadyAnalyzed,
      );
      final response = await analyzeController.findMocking(request);
      if (path != null) {
        alreadyAnalyzed.add(path);
      }
      if (response.isMockingFound) {
        final steps = response.mockingSteps!;
        await currentProjectController.saveMockingSteps(steps);
        return steps;
      } else {
        if (path == null || path.isEmpty) {
          return 'There is no mocking found in this project. Use best practices to mock your code.';
        }
        path = response.path;
      }
    }
  }

  Future<List<FileLowLevelData>> _prepareTestUtilsStructure(
      String projectStructure, String projectRoot) async {
    List<String>? testUtils = currentProjectController.utilsFiles;
    if (testUtils.isNotEmpty) {
      return getStructure(testUtils, projectRoot);
    }

    final request = FindHelpersRequest(
      projectStructure: projectStructure,
    );
    final response = await testAnalyseController.findHelpers(request);
    await currentProjectController.saveUtilsFiles(response.paths);

    return getStructure(response.paths, projectRoot);
  }
}

String? readFileToString(String path) {
  try {
    return File(path).readAsStringSync();
  } catch (e) {
    return 'BAD, $e';
  }
}

// After choosing a project directory, add print statement saying if the selected project is a flutter project or not
