import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:flukki/ai/controllers/tasks_controller.dart';
import 'package:flukki/ai/controllers/tests_controller.dart';
import 'package:flukki/home/controllers/status_controller.dart';
import 'package:get/get.dart';

import '../output/controllers/output_controller.dart';
import '../../current_project/controllers/current_project_controller.dart';
import '../utils/di_utils.dart';
import '../utils/file_utils.dart';
import '../../ai/models/add_file.dart';
import '../../ai/models/determine_models_models.dart';
import '../../ai/models/find_helpers_models.dart';
import '../../ai/models/generate_tests_models.dart';
import '../../ai/models/mocking_analyse_model.dart';
import '../../ai/models/modify_file.dart';
import '../../ai/models/split_task.dart';

FlukkiBrainController flukkiBrainController =
    handleDependency(() => FlukkiBrainController());

class FlukkiBrainController {
  final _isWorking = RxBool(false);

  bool get isWorking => _isWorking.value;

  set isWorking(bool value) {
    _isWorking.value = value;
  }

  Future<void> start(String task) async {
    statusController.currentJob = task;
    if (task.isEmpty) {
      addOutputLine('Task is empty');
      addOutputLine('');
      return;
    }
    final project = currentProjectController.currentProjectPath!;
    final dartSdkPath = currentProjectController.dartSdkPath!;

    //todo: describe project architecture
    final architecture = 'No specific architecture in the project';

    addOutputLine('Hello, I will work on this task:');
    addOutputLine(task);
    addOutputLine('');
    addOutputLine('Starting project analysis...');
    addOutputLine('');

    try {
      final filesInProjectDir = Directory(project)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => isCustomProjectDartFile(file.path))
          .map((e) => e.path)
          .toList();

      final session = AnalysisContextCollection(
        includedPaths: filesInProjectDir,
        resourceProvider: PhysicalResourceProvider.INSTANCE,
        sdkPath: dartSdkPath,
      );

      List<FileLowLevelData> filesLowLevelData = [];
      for (final file in filesInProjectDir) {
        final element = session.contexts.first.currentSession
            .getParsedUnit(file) as ParsedUnitResult;
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
                            return ParameterLowLevelData(param.name.toString(),
                                parameter.type.toString());
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
              .map(
                  (e) => e.fields.variables.map((e) => e.toString()).toString())
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

      final projectStructure = FilesLowLevel(filesLowLevelData).toMap();

      final pubspecDependencies = await getDependencies(project);

      final request = SplitTaskRequest(
        architecture: architecture ?? 'No architecture described',
        task: task,
        projectStructure: projectStructure,
        pubspecDependencies: pubspecDependencies,
      );
      final smallerTasks = await tasksAIController.splitTask(request);

      for (String command in smallerTasks.flutterAddDependenciesCommands) {
        addOutputLine('Adding dependencies: $command');
        await Process.run('flutter', command.split(' '),
            workingDirectory: project);
      }
      if (smallerTasks.flutterAddDependenciesCommands.isNotEmpty) {
        addOutputLine('');
      }
      final newPubspecDependencies = await getDependencies(project);

      for (final change in smallerTasks.fileChangeDescriptions) {
        addOutputLine('Working on file: ${change.path}');
        if (change.isFileCreated) {
          final similarFileContent =
              await File('$project/${change.similarFilePath}').readAsString();
          final addRequest = AddFileRequest(
            newFileDescription: change.changeDescriptions,
            allChangesDescriptions: smallerTasks.toString(),
            task: task,
            pubspecDependencies: newPubspecDependencies,
            similarFile: similarFileContent,
          );
          final result = await tasksAIController.addFile(addRequest);
          File('$project/${change.path}').writeAsStringSync(result.message);
          addOutputLine('File created: ${change.path}');
        } else {
          final content = await File('$project/${change.path}').readAsString();
          final modifyRequest = ModifyFileRequest(
            task: task,
            changeDescription: change.changeDescriptions,
            allChangesDescriptions: smallerTasks.toString(),
            pubspecDependencies: pubspecDependencies,
            content: content,
          );
          final result = await tasksAIController.modifyFile(modifyRequest);
          File('$project/${change.path}').writeAsStringSync(result.message);
          addOutputLine('File modified: ${change.path}');
        }
        addOutputLine('');
      }

      addOutputLine('');
      statusController.finish('I\'m done, bye');
    } catch (e, s) {
      addOutputLine(e.toString() + s.toString());
    }
    return;
  }

  Future<void> generateTests(String path) async {
    statusController.currentJob = 'Generating tests for $path';
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

      final requiredModelsPaths = await testsAIController.determineModels(
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
          await testsAIController.generateTests(generateTestRequest);

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

      statusController.finish('I\'m done, bye');
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
      final response = await testsAIController.findMocking(request);
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
    final response = await testsAIController.findHelpers(request);
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
