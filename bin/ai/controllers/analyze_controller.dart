import 'dart:io';


import '../../analyze/project_analyse/controllers/test_analyse_controller.dart';
import '../../core/conrtollers_interfaces.dart';
import '../../home/controllers/current_project_controller.dart';
import '../models/mocking_analyse_model.dart';
import '../models/model_creation_models.dart';

class ProblemEntryPointResult {
  final String path;

  ProblemEntryPointResult(this.path);

  ProblemEntryPointResult.fromJson(Map<String, dynamic> json)
      : path = json['path'];
}

class AnalyzeResult {
  final String? newContent;
  final List<String>? paths;

  AnalyzeResult(this.newContent, this.paths);

  AnalyzeResult.fromJson(Map<String, dynamic> json)
      : newContent = json['newContent'],
        paths = List<String>.from(json['paths'] ?? []);
}

AnalyzeController get analyzeController =>
    handleDependency(() => AnalyzeController());

class AnalyzeController {
  Future<ModelCreationResponse> findModelCreation(
      ModelCreationRequest request) async {
    List<String> analyzed = [];

    while (true) {
      final response =
          await testAnalyseController.getModelCreationSteps(request);
      if (!response.isModelCreationFound) {
        analyzed.add(response.path!);
        final file =
            File(currentProjectController.currentProjectPath! + response.path!);
        final content = await file.readAsString();
        request = ModelCreationRequest(
          fileContent: content,
          alreadyAnalyzedFiles: analyzed,
          projectStructure: request.projectStructure,
        );
      } else {
        return response;
      }
    }
  }

  Future<MockingAnalyseResponse> findMocking(
      MockingAnalyseRequest request) async {
    List<String> analyzed = [];

    while (true) {
      final response = await testAnalyseController.getMockingSteps(request);
      if (!response.isMockingFound) {
        analyzed.add(response.path!);
        final file =
            File(currentProjectController.currentProjectPath! + response.path!);
        final content = await file.readAsString();
        request = MockingAnalyseRequest(
          fileContent: content,
          alreadyAnalyzedFiles: analyzed,
          projectStructure: request.projectStructure,
        );
      } else {
        return response;
      }
    }
  }
}
