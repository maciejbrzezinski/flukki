import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ai/controllers/flukki_brain_controller.dart';
import '../../core/conrtollers_interfaces.dart';

CurrentProjectController currentProjectController =
    handleDependency(() => CurrentProjectController());

class CurrentProjectController {
  final _currentProjectPath = RxnString();
  final _dartSdkPath = RxnString();
  final _mockingSteps = RxnString();
  final _modelCreationSteps = RxnString();
  final _utilsFiles = RxList<String>();
  final _openAIKey = RxnString();

  String? get currentProjectPath => _currentProjectPath.value;

  String? get dartSdkPath => _dartSdkPath.value;

  String? get mockingSteps => _mockingSteps.value;

  String? get modelCreationSteps => _modelCreationSteps.value;

  List<String> get utilsFiles => _utilsFiles;

  String? get openAIKey => _openAIKey.value;

  Future<void> init() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final path = sharedPrefs.getString('currentProjectPath');
    final sdkPath = sharedPrefs.getString('dartSdkPath');
    final mockingSteps = sharedPrefs.getString('mockingSteps');
    final modelCreationSteps = sharedPrefs.getString('modelCreationSteps');
    final utilsFiles = sharedPrefs.getStringList('utilsFiles');
    final openAIKey = sharedPrefs.getString('openAIKey');
    if (path != null) {
      _currentProjectPath.value = path;
    }
    if (sdkPath != null) {
      _dartSdkPath.value = sdkPath;
    }
    if (mockingSteps != null) {
      _mockingSteps.value = mockingSteps;
    }
    if (modelCreationSteps != null) {
      _modelCreationSteps.value = modelCreationSteps;
    }
    if (utilsFiles != null) {
      _utilsFiles.value = utilsFiles;
    }
    if (openAIKey != null) {
      _openAIKey.value = openAIKey;
      OpenAI.apiKey = openAIKey;
    }
  }

  bool get loading => false;

  bool get isEverythingPrepared =>
      _currentProjectPath.value != null && _dartSdkPath.value != null;

  Future<void> chooseProject() async {
    var selected = await FilePicker.platform.getDirectoryPath();
    if (selected != null) {
      selected = selected.replaceAll('/Volumes/Macintosh HD/', '/');
      _currentProjectPath.value = selected;

      final sharedPrefs = await SharedPreferences.getInstance();
      await sharedPrefs.setString('currentProjectPath', selected);
    }
  }

  Future<void> chooseDartSdkPath() async {
    var selectedSdkPath = await FilePicker.platform.getDirectoryPath();
    if (selectedSdkPath != null) {
      selectedSdkPath =
          selectedSdkPath.replaceAll('/Volumes/Macintosh HD/', '/');
      if (File('$selectedSdkPath/lib/_internal/sdk_library_metadata/lib/libraries.dart')
              .existsSync() ==
          false) {
        flukkiBrainController.addOutputLine('!!! Wrong Dart SDK path');
        flukkiBrainController.addOutputLine(
            'Such file should exist in selected directory: /lib/_internal/sdk_library_metadata/lib/libraries.dart');
        flukkiBrainController.addOutputLine('');
        return;
      }
      _dartSdkPath.value = selectedSdkPath;

      final sharedPrefs = await SharedPreferences.getInstance();
      await sharedPrefs.setString('dartSdkPath', selectedSdkPath);
    }
  }

  Future<void> saveMockingSteps(String steps) async {
    _mockingSteps.value = steps;

    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setString('mockingSteps', steps);
  }

  Future<void> saveModelCreationSteps(String steps) async {
    _modelCreationSteps.value = steps;

    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setString('modelCreationSteps', steps);
  }

  Future<void> saveUtilsFiles(List<String> files) async {
    _utilsFiles.value = files;

    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setStringList('utilsFiles', files);
  }

  Future<void> saveOpenAIKey(String key) async {
    _openAIKey.value = key;
    OpenAI.apiKey = key;

    final sharedPrefs = await SharedPreferences.getInstance();
    await sharedPrefs.setString('openAIKey', key);
  }

  List<String> getCurrentProjectDartFilesToTest() {
    final files = <String>[];
    if (_currentProjectPath.value != null) {
      final dir = Directory(_currentProjectPath.value!);
      final filesListed = dir.listSync(recursive: true);

      for (final file in filesListed) {
        if (file.path.endsWith('.dart') && !file.path.contains('/test/')) {
          files.add(file.path.toString());
        }
      }
    }
    return files;
  }
}
