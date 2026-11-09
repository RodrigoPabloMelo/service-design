import '../models/code_file.dart';
import '../models/validation_error.dart';
import '../models/localization_file.dart';

abstract class BaseValidator {
  List<String?> extractKeyPaths(RegExp regex, String data) =>
      regex.allMatches(data).map<String?>((m) => m.group(1)).toList();

  List<ValidationError> validate(
    CodeFile codeFile,
    LocalizationFile localizationFile,
  );
}
