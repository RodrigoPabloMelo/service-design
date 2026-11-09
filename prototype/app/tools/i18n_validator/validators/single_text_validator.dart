import '../models/code_file.dart';
import '../models/validation_error.dart';
import '../models/localization_file.dart';
import 'base_validator.dart';

class SingleTextValidator extends BaseValidator {
  @override
  List<ValidationError> validate(
    CodeFile codeFile,
    LocalizationFile localizationFile,
  ) {
    final List<ValidationError> errors = [];
    final regex = RegExp(r"i18n[\.\s]*get\([\s]*\'([\.a-zA-Z0-9]*)\'");
    final keyPaths = extractKeyPaths(regex, codeFile.code);

    for (final keyPath in keyPaths) {
      if (keyPath == null) throw Exception('Invalid key path found!');

      final value = localizationFile.getLastValue(keyPath);

      if (value is! String) {
        errors.add(
          ValidationError(
            keyPath: keyPath,
            codeFileName: codeFile.name,
            localizationFileName: localizationFile.name,
          ),
        );
      } else {
        localizationFile.markKeyPathUsed(keyPath);
      }
    }

    return errors;
  }
}
