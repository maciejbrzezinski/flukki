
import '../../server_core/base_models.dart';

class MockingAnalyseRequest extends RequestBaseModel {
  String projectStructure;
  String? fileContent;
  List<String> alreadyAnalyzedFiles;

  MockingAnalyseRequest({
    required this.projectStructure,
    this.fileContent,
    this.alreadyAnalyzedFiles = const [],
  });

  static MockingAnalyseRequest fromJson(Map<String, dynamic> json) {
    return MockingAnalyseRequest(
      projectStructure: json['projectStructure'],
      fileContent: json['fileContent'],
      alreadyAnalyzedFiles:
          List<String>.from(json['alreadyAnalyzedFiles'] ?? []),
    );
  }

  toJson() {
    return {
      'projectStructure': projectStructure,
      'fileContent': fileContent,
      'alreadyAnalyzedFiles': alreadyAnalyzedFiles,
    };
  }
}

class MockingAnalyseResponse extends ResponseBaseModel {
  String? path;
  bool isMockingFound;
  String? mockingSteps;

  MockingAnalyseResponse({
    this.path,
    required super.usedTokens,
    required this.isMockingFound,
    this.mockingSteps,
  });

  static MockingAnalyseResponse fromJson(Map<String, dynamic> json,
      {int? usedTokens}) {
    return MockingAnalyseResponse(
      path: json['path'],
      usedTokens: usedTokens ?? json['usedTokens'],
      isMockingFound: json['isMockingFound'] ?? false,
      mockingSteps: json['mockingSteps'],
    );
  }

  @override
  toJson() {
    return {
      'path': path,
      'usedTokens': usedTokens,
      'isMockingFound': isMockingFound,
      'mockingSteps': mockingSteps,
    };
  }
}
