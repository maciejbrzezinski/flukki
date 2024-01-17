import '../../core/models/base_models.dart';

class SplitTaskRequest extends RequestBaseModel {
  final String projectStructure;
  final String architecture;
  final String task;
  final String pubspecDependencies;

  SplitTaskRequest({
    required this.projectStructure,
    required this.architecture,
    required this.task,
    required this.pubspecDependencies,
  });

  static SplitTaskRequest fromJson(Map<String, dynamic> json) {
    return SplitTaskRequest(
      projectStructure: json['projectStructure'],
      architecture: json['architecture'],
      task: json['task'],
      pubspecDependencies: json['pubspecDependencies'],
    );
  }

  toJson() {
    return {
      'projectStructure': projectStructure,
      'architecture': architecture,
      'task': task,
      'pubspecDependencies': pubspecDependencies,
    };
  }
}

class SplitTaskResult extends ResponseBaseModel {
  final List<FileChangeDescription> fileChangeDescriptions;
  final List<String> flutterAddDependenciesCommands;

  SplitTaskResult({
    required this.fileChangeDescriptions,
    required super.usedTokens,
    required this.flutterAddDependenciesCommands,
  });

  SplitTaskResult.empty({required super.usedTokens})
      : fileChangeDescriptions = [],
        flutterAddDependenciesCommands = [];

  static fromJson(Map<String, dynamic> json, {int? usedTokens}) {
    return SplitTaskResult(
      fileChangeDescriptions: List<FileChangeDescription>.from(
          json['fileChangeDescriptions']
                  ?.map((x) => FileChangeDescription.fromJson(x)) ??
              []),
      flutterAddDependenciesCommands:
          List<String>.from(json['flutterAddDependenciesCommands'] ?? []),
      usedTokens: usedTokens ?? json['usedTokens'],
    );
  }

  @override
  toJson() {
    return {
      'fileChangeDescriptions': fileChangeDescriptions.map((e) => e.toJson()).toList(),
      'flutterAddDependenciesCommands': flutterAddDependenciesCommands,
      'usedTokens': usedTokens,
    };
  }

  @override
  String toString() {
    return 'SplitTaskResult{fileChangeDescriptions: $fileChangeDescriptions, flutterAddDependenciesCommands: $flutterAddDependenciesCommands, usedTokens: $usedTokens}';
  }
}

class FileChangeDescription {
  final String path;
  final String changeDescriptions;
  final bool isFileCreated;
  final String? similarFilePath;

  FileChangeDescription({
    required this.path,
    required this.changeDescriptions,
    required this.isFileCreated,
    this.similarFilePath,
  });

  static fromJson(Map<String, dynamic> json) {
    return FileChangeDescription(
      path: json['path'],
      changeDescriptions: json['changeDescriptions'],
      isFileCreated: json['isFileCreated'],
      similarFilePath: json['similarFilePath'],
    );
  }

  toJson() {
    return {
      'path': path,
      'changeDescriptions': changeDescriptions,
      'isFileCreated': isFileCreated,
      'similarFilePath': similarFilePath,
    };
  }

  @override
  String toString() {
    return 'FileChangeDescription{path: $path, changeDescriptions: $changeDescriptions, isFileCreated: $isFileCreated, similarFilePath: $similarFilePath}';
  }
}
