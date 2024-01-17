
import '../../core/models/base_models.dart';

class ModifyFileRequest extends RequestBaseModel {
  final String task;
  final String changeDescription;
  final String allChangesDescriptions;
  final String pubspecDependencies;
  final String content;

  ModifyFileRequest({
    required this.task,
    required this.changeDescription,
    required this.allChangesDescriptions,
    required this.pubspecDependencies,
    required this.content,
  });

  static ModifyFileRequest fromJson(Map<String, dynamic> json) {
    return ModifyFileRequest(
      task: json['task'],
      changeDescription: json['changeDescription'],
      allChangesDescriptions: json['allChangesDescriptions'],
      pubspecDependencies: json['pubspecDependencies'],
      content: json['content'],
    );
  }

  toJson() {
    return {
      'task': task,
      'changeDescription': changeDescription,
      'allChangesDescriptions': allChangesDescriptions,
      'pubspecDependencies': pubspecDependencies,
      'content': content,
    };
  }
}