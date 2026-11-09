// ignore_for_file: avoid_print
import 'helpers/file_helpers.dart';
import 'models/validation_error.dart';
import 'validators/single_text_validator.dart';
import 'validators/plural_text_validator.dart';

Future<void> main() async {
  final List<ValidationError> errors = [];
  final validators = [SingleTextValidator(), PluralTextValidator()];

  final codeFiles = await getCodeFiles();
  final localizationFiles = await getLocalizationFiles();

  for (final localizationFile in localizationFiles) {
    for (final codeFile in codeFiles) {
      for (final validator in validators) {
        errors.addAll(validator.validate(codeFile, localizationFile));
      }
    }
  }

  final localizationFilesWithUnusedKeys =
      localizationFiles.where((file) => file.unusedKeys.isNotEmpty);

  print('======== UNUSED JSON PATHS ========');
  if (localizationFilesWithUnusedKeys.isNotEmpty) {
    for (final localizationFile in localizationFilesWithUnusedKeys) {
      final unusedKeys = localizationFile.unusedKeys.toList()..sort();

      print('\n📁 ${localizationFile.name}');
      for (final key in unusedKeys) {
        print('  ⚠️  $key');
      }
    }
  } else {
    print('✅ All the json paths are used!');
  }

  print('\n======== INVALID DART PATHS ========');
  if (errors.isNotEmpty) {
    final Map<String, Map<String, List<String>>> groupedErrors = {};

    for (final error in errors) {
      groupedErrors
          .putIfAbsent(error.localizationFileName, () => {})
          .putIfAbsent(error.codeFileName, () => [])
          .add(error.keyPath);
    }

    final sortedJsonFiles = groupedErrors.keys.toList()..sort();

    for (final jsonFile in sortedJsonFiles) {
      print('\n📁 $jsonFile');

      final sortedDartFiles = groupedErrors[jsonFile]!.keys.toList()..sort();

      for (final dartFile in sortedDartFiles) {
        print('  📄 $dartFile');

        final sortedKeys = groupedErrors[jsonFile]![dartFile]!..sort();

        for (final key in sortedKeys) {
          print('    ❌ $key');
        }
      }
    }
    print('\n💥 Fix the localization errors!');
  } else {
    print('✅ All the texts are correctly localized!\n');
  }
}
