
import '../../core/models/base_models.dart';

class FindHelpersRequest extends RequestBaseModel {
  final String projectStructure;

  FindHelpersRequest({
    required this.projectStructure,
  });

  static FindHelpersRequest fromJson(Map<String, dynamic> json) {
    return FindHelpersRequest(
      projectStructure: json['projectStructure'],
    );
  }

  toJson() {
    return {
      'projectStructure': projectStructure,
    };
  }
}

class FindHelpersResponse extends ResponseBaseModel {
  final List<String> paths;

  FindHelpersResponse({
    required this.paths,
    required super.usedTokens,
  });

  static FindHelpersResponse fromJson(Map<String, dynamic> json,
      {int? usedTokens}) {
    return FindHelpersResponse(
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
