

import '../../core/models/base_models.dart';

class DetermineModelsRequest extends RequestBaseModel {
  final String fileContent;
  final String filesInProject;

  DetermineModelsRequest({
    required this.fileContent,
    required this.filesInProject,
  });

  static DetermineModelsRequest fromJson(Map<String, dynamic> json) {
    return DetermineModelsRequest(
      fileContent: json['fileContent'],
      filesInProject: json['filesInProject'],
    );
  }

  toJson() {
    return {
      'fileContent': fileContent,
      'filesInProject': filesInProject,
    };
  }
}

class DetermineModelsResponse extends ResponseBaseModel {
  List<String> paths;

  DetermineModelsResponse({
    required this.paths,
    required super.usedTokens,
  });

  static DetermineModelsResponse fromJson(Map<String, dynamic> json,
      {int? usedTokens}) {
    return DetermineModelsResponse(
      paths: List<String>.from(json['paths'] ?? []),
      usedTokens: usedTokens ?? json['usedTokens'],
    );
  }

  @override
  toJson() {
    return {
      'paths': paths,
      'usedTokens': usedTokens,
    };
  }
}
