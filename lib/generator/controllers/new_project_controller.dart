import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../core/utils/di_utils.dart';

NewProjectController get newProjectController =>
    handleDependency(() => NewProjectController());

class NewProjectController {
  Future<String> createNewFlutterProject(String name) async {
    final properProjectName = name.replaceAll(' ', '_').toLowerCase();
    await Process.run(
      'flutter',
      [
        'create',
        '--org',
        'com.example',
        '--project-name',
        properProjectName,
        '${(await getApplicationDocumentsDirectory()).path}/$properProjectName',
      ],
      runInShell: true,
    );
    return '${(await getApplicationDocumentsDirectory()).path}/$properProjectName';
  }
}
