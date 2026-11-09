import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import '../models/code_file.dart';
import '../models/localization_file.dart';

final currentPath = Directory.current.path;

Future<List<LocalizationFile>> getLocalizationFiles() async {
  final files = Directory(
    join(currentPath, 'assets', 'i18n'),
  ).listSync(recursive: true).where((e) => e.path.endsWith('.json'));

  final localizationFiles = <LocalizationFile>[];

  for (final file in files) {
    final localizationFile = await _mapLocalizationFile(file);
    localizationFiles.add(localizationFile);
  }

  return localizationFiles;
}

Future<LocalizationFile> _mapLocalizationFile(
  FileSystemEntity jsonFile,
) async {
  final file = File(jsonFile.path);

  final jsonString = await file.readAsString();
  final data = jsonDecode(jsonString) as Map<String, dynamic>;
  final fileName = jsonFile.path.split(Platform.pathSeparator).last;

  final keyPaths = _extractAllKeyPaths(data);

  return LocalizationFile(
    name: fileName,
    data: data,
    allKeyPaths: keyPaths,
  );
}

Set<String> _extractAllKeyPaths(Map<String, dynamic> data) {
  final Set<String> keys = {};

  void extractRecursive(Map<String, dynamic> map, String prefix) {
    for (final entry in map.entries) {
      final fullKey = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';

      if (entry.value is Map<String, dynamic>) {
        extractRecursive(entry.value as Map<String, dynamic>, fullKey);
      } else {
        keys.add(fullKey);
      }
    }
  }

  extractRecursive(data, '');
  return keys;
}

Future<List<CodeFile>> getCodeFiles() async {
  final files = Directory(
    join(currentPath, 'lib'),
  ).listSync(recursive: true).where((e) => e.path.endsWith('.dart'));

  final codeFiles = <CodeFile>[];

  for (final file in files) {
    final codeFile = await _mapCodeFile(file);
    codeFiles.add(codeFile);
  }

  return codeFiles;
}

Future<CodeFile> _mapCodeFile(FileSystemEntity dartFile) async {
  final file = File(dartFile.path);

  final code = await file.readAsString();
  final fileName = file.path.split(Platform.pathSeparator).last;

  return CodeFile(name: fileName, code: code);
}
