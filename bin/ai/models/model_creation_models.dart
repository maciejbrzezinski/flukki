import '../../server_core/base_models.dart';

class ModelCreationRequest extends RequestBaseModel {
  final String projectStructure;
  final String? fileContent;
  final List<String> alreadyAnalyzedFiles;

  ModelCreationRequest({
    required this.projectStructure,
    this.fileContent,
    this.alreadyAnalyzedFiles = const [],
  });

  static ModelCreationRequest fromJson(Map<String, dynamic> json) {
    return ModelCreationRequest(
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

class ModelCreationResponse extends ResponseBaseModel {
  String? path;
  bool isModelCreationFound;
  String? modelCreationSteps;

  ModelCreationResponse({
    this.path,
    required super.usedTokens,
    required this.isModelCreationFound,
    this.modelCreationSteps,
  });

  static ModelCreationResponse fromJson(Map<String, dynamic> json,
      {int? usedTokens}) {
    return ModelCreationResponse(
      path: json['path'],
      usedTokens: usedTokens ?? json['usedTokens'],
      isModelCreationFound: json['isModelCreationFound'] ?? false,
      modelCreationSteps: json['modelCreationSteps'],
    );
  }

  @override
  toJson() {
    return {
      'path': path,
      'usedTokens': usedTokens,
      'isModelCreationFound': isModelCreationFound,
      'modelCreationSteps': modelCreationSteps,
    };
  }
}
