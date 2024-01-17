import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

class FilesLowLevel {
  List<FileLowLevelData> files;

  FilesLowLevel(this.files);

  List<FileLowLevelData> findRelationsForFile(FileLowLevelData file) {
    return files
        .where((element) =>
            file.imports.any((import) => import.contains(element.name)))
        .toList();
  }

  String toMap({bool includeImports = false}) {
    return jsonEncode({
      'f': files
          .map((e) => e.toMap(includeImports: false, light: false))
          .toList()
    });
  }
}

class FileLowLevelData {
  final String fullPath;
  late String path;
  late final String name;
  final List<ClassLowLevelData> classes;
  final List<String> imports;
  final List<EnumLowLevelData> enums;

  String body;

  FileLowLevelData(
    this.fullPath,
    this.classes,
    this.imports,
    this.enums,
    this.body,
    String projectRoot,
  ) {
    path = fullPath.replaceFirst(projectRoot, '');
    name = fullPath.split('/').last;
  }

  dynamic toMap({bool includeImports = false, bool light = true}) {
    if (light) {
      return '($path: ${classes.where((element) => !element.name.startsWith('_')).map((e) => e.toMap(light: light)).toList()})';
    }
    return {
      'path': path,
      'n': name,
      'classes': classes.map((e) => e.toMap(light: false)).toList(),
      if (includeImports) 'i': imports,
      if (enums.isNotEmpty) 'e': enums.map((e) => e.toMap()).toList(),
    };
  }
}

class EnumLowLevelData {
  final String name;
  final List<String> values;

  EnumLowLevelData(this.name, this.values);

  Map toMap() {
    return {'n': name, 'v': values};
  }
}

class ClassLowLevelData {
  final String name;
  late final List<MethodLowLevelData> methods;
  final List<String> properties;

  ClassLowLevelData(this.name, List<MethodLowLevelData> m, this.properties) {
    methods = m.where((element) => element.parentName == name).toList();
  }

  toMap({bool light = false}) {
    if (light) {
      return name;
    }
    // final filtereds = methods.where((element) =>
    //     !element.name.startsWith('_') &&
    //     element.name != 'toString' &&
    //     element.name != 'createState' &&
    //     element.name != 'build');
    return {
      'name': name,
      'methods': methods.map((e) => e.toMap()).toList()
      // if (filtereds.isNotEmpty) 'm': filtereds.map((e) => e.toMap()).toList()
    };
  }
}

class MethodLowLevelData {
  final String name;
  final String parentName;
  final List<ParameterLowLevelData>? parameters;
  final String body;

  MethodLowLevelData(
    this.name,
    this.parameters,
    this.parentName,
    this.body,
  );

  String toMap() {
    // if (parameters == null || parameters!.isEmpty) return name;
    return '$name(${parameters?.map((e) => e.toMap()).join(', ')})';
    // return {
    //   'name': name,
    //   if (parameters != null && parameters!.isNotEmpty)
    //     'parameters': parameters?.map((e) => e.toMap()).toList()
    // };
  }
}

class ParameterLowLevelData {
  final String name;
  final String type;

  ParameterLowLevelData(this.name, this.type);

  String toMap() {
    return '$type $name';
  }
}

Future<String> getDependencies(String projectRoot) async {
final listOfDependencies = await _readPubspecYamlAndGetDependenciesListFromIt(projectRoot);
  return listOfDependencies.join('\n');
}

Future<List> _readPubspecYamlAndGetDependenciesListFromIt(String projectPath) async {
  final pubspecFile = File('$projectPath/pubspec.yaml');
  final pubspecYaml = await pubspecFile.readAsString();
  final pubspec = loadYaml(pubspecYaml);
  final dependencies = pubspec['dependencies'];
  final dependenciesList = dependencies.keys.toList();
  return dependenciesList;
}

bool isCustomProjectDartFile(String path) {
  return !path.contains('web') &&
      !path.contains('macos') &&
      !path.contains('linux') &&
      !path.contains('windows') &&
      !path.contains('android') &&
      !path.contains('ios') &&
      !path.contains('build') &&
      !path.contains('test') &&
      !path.contains('example') &&
      !path.contains('packages') &&
      !path.contains('flutter') &&
      !path.contains('dart_tool') &&
      !path.contains('analysis_options.yaml') &&
      // !path.contains('pubspec.yaml') &&
      !path.contains('pubspec.lock') &&
      !path.contains('README.md') &&
      !path.contains('CHANGELOG.md') &&
      !path.contains('LICENSE') &&
      (path.endsWith('.dart') || path.endsWith('.yaml'));
}