import 'dart:io';

import 'package:dart_openai/dart_openai.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/output/controllers/output_controller.dart';
import '../../core/utils/di_utils.dart';
import '../../core/utils/file_utils.dart';

CurrentProjectController currentProjectController =
    handleDependency(() => CurrentProjectController());

class CurrentProjectController {
  final _currentProjectPath = RxnString();
  final _dartSdkPath = RxnString();
  final _mockingSteps = RxnString();
  final _modelCreationSteps = RxnString();
  final _utilsFiles = RxList<String>();
  final _openAIKey = RxnString();
  final _loading = RxBool(false);
  late SharedPreferences _sharedPrefs;

  String? get currentProjectPath => _currentProjectPath.value;

  String? get dartSdkPath => _dartSdkPath.value;

  String? get mockingSteps => _mockingSteps.value;

  String? get modelCreationSteps => _modelCreationSteps.value;

  List<String> get utilsFiles => _utilsFiles;

  String? get openAIKey => _openAIKey.value;

  Future<void> init() async {
    _loading.value = true;
    _sharedPrefs = await SharedPreferences.getInstance();
    final path = _sharedPrefs.getString('currentProjectPath');
    final sdkPath = _sharedPrefs.getString('dartSdkPath');
    final mockingSteps = _sharedPrefs.getString('mockingSteps');
    final modelCreationSteps = _sharedPrefs.getString('modelCreationSteps');
    final utilsFiles = _sharedPrefs.getStringList('utilsFiles');
    final openAIKey = _sharedPrefs.getString('openAIKey');
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
    _loading.value = false;
  }

  bool get loading => _loading.value;

  bool get isEverythingPrepared =>
      _currentProjectPath.value != null && _dartSdkPath.value != null;

  Future<void> chooseProject() async {
    var selected = await FilePicker.platform.getDirectoryPath(
        initialDirectory: (await getApplicationDocumentsDirectory()).path);
    if (selected != null) {
      selected = selected.replaceAll('/Volumes/Macintosh HD/', '/');
      _currentProjectPath.value = selected;

      await _sharedPrefs.setString('currentProjectPath', selected);
    }
  }

  Future<void> clearProject() async {
    _currentProjectPath.value = null;
    await _sharedPrefs.remove('currentProjectPath');
  }

  Future<void> chooseDartSdkPath() async {
    var selectedSdkPath = await FilePicker.platform
        .getDirectoryPath(initialDirectory: dartSdkPath);
    if (selectedSdkPath != null) {
      selectedSdkPath =
          selectedSdkPath.replaceAll('/Volumes/Macintosh HD/', '/');
      if (File('$selectedSdkPath/lib/_internal/sdk_library_metadata/lib/libraries.dart')
              .existsSync() ==
          false) {
        addOutputLine('!!! Wrong Dart SDK path');
        addOutputLine(
            'Such file should exist in selected directory: /lib/_internal/sdk_library_metadata/lib/libraries.dart');
        addOutputLine('');
        return;
      }
      _dartSdkPath.value = selectedSdkPath;

      await _sharedPrefs.setString('dartSdkPath', selectedSdkPath);
    }
  }

  Future<void> saveMockingSteps(String steps) async {
    _mockingSteps.value = steps;

    await _sharedPrefs.setString('mockingSteps', steps);
  }

  Future<void> saveModelCreationSteps(String steps) async {
    _modelCreationSteps.value = steps;

    await _sharedPrefs.setString('modelCreationSteps', steps);
  }

  Future<void> saveUtilsFiles(List<String> files) async {
    _utilsFiles.value = files;

    await _sharedPrefs.setStringList('utilsFiles', files);
  }

  Future<void> saveOpenAIKey(String key) async {
    _openAIKey.value = key;
    OpenAI.apiKey = key;

    await _sharedPrefs.setString('openAIKey', key);
  }

  List<String> getCurrentProjectDartFilesToTest() {
    final files = <String>[];
    if (_currentProjectPath.value != null) {
      final dir = Directory(_currentProjectPath.value!);
      final filesListed = dir.listSync(recursive: true);

      for (final file in filesListed) {
        if (isCustomProjectDartFile(file.path) &&
            !file.path.contains('/test/')) {
          files.add(file.path.toString());
        }
      }
    }
    return files;
  }
}
