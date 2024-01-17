
import '../../core/models/base_models.dart';

class GenerateTestsRequest extends RequestBaseModel {
  final String testedFileContent;
  final String mockingSteps;
  final String utilsStructure;
  final List<String> models;

  GenerateTestsRequest({
    required this.testedFileContent,
    required this.mockingSteps,
    required this.models,
    required this.utilsStructure,
  });

  static GenerateTestsRequest fromJson(Map<String, dynamic> json) {
    return GenerateTestsRequest(
      testedFileContent: json['testedFileContent'],
      mockingSteps: json['mockingSteps'],
      models: List<String>.from(json['models'] ?? []),
      utilsStructure: json['utilsStructure'],
    );
  }

  toJson() {
    return {
      'testedFileContent': testedFileContent,
      'mockingSteps': mockingSteps,
      'models': models,
      'utilsStructure': utilsStructure,
    };
  }
}

class GenerateTestsResponse extends ResponseBaseModel {
  String newTestFileContent;

  GenerateTestsResponse({
    required this.newTestFileContent,
    required super.usedTokens,
  });

  static GenerateTestsResponse fromJson(Map<String, dynamic> json,
      {int? usedTokens}) {
    return GenerateTestsResponse(
      newTestFileContent: json['newTestFileContent'],
      usedTokens: usedTokens ?? json['usedTokens'],
    );
  }

  @override
  toJson() {
    return {
      'newTestFileContent': newTestFileContent,
      'usedTokens': usedTokens,
    };
  }
}
