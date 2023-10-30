import '../../server_core/base_models.dart';

class AddFileRequest extends RequestBaseModel {
  final String task;
  final String newFileDescription;
  final String pubspecDependencies;
  final String allChangesDescriptions;
  final String similarFile;

  AddFileRequest({
    required this.task,
    required this.newFileDescription,
    required this.pubspecDependencies,
    required this.allChangesDescriptions,
    required this.similarFile,
  });

  static AddFileRequest fromJson(Map<String, dynamic> json) {
    return AddFileRequest(
      task: json['task'],
      newFileDescription: json['newFileDescription'],
      pubspecDependencies: json['pubspecDependencies'],
      allChangesDescriptions: json['allChangesDescriptions'],
      similarFile: json['similarFile'],
    );
  }

  toJson() {
    return {
      'task': task,
      'newFileDescription': newFileDescription,
      'pubspecDependencies': pubspecDependencies,
      'allChangesDescriptions': allChangesDescriptions,
      'similarFile': similarFile,
    };
  }
}
