import 'package:studio_app/core/utils/misc.dart';

extension StringExtension on String {
  /// Checks if the String is a valid email:
  bool get isValidEmail {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(this);
  }

  /// Removes spaces at the beginning and end of a String:
  String get trimSpaces => trim();

  /// Check if the String is empty or contains only spaces:
  bool get isBlank => trim().isEmpty;

  /// Removes all characters other than numbers:
  String get onlyDigits => replaceAll(RegExp(r'\D'), '');

  /// Check if the String has image format
  bool get hasImageFormat =>
      contains('.png') || contains('.jpg') || contains('.jpeg');

  ///Return string with first letter in upper case
  String capitalize({
    String delimiter = ' ',
    List<String> exceptions = const [],
  }) {
    return toLowerCase()
        .trim()
        .split(delimiter)
        .map((e) => e.isEmpty
            ? e
            : exceptions.contains(e)
                ? e
                : e[0].toUpperCase() + e.substring(1))
        .toList()
        .join(delimiter);
  }

  ///Return string in format camel case
  String get toCamelCase {
    String text = this;
    text = text.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), ' ').toLowerCase();

    List<String> palavras = text.split(' ');
    String camelCase = palavras.first.toLowerCase();
    for (int i = 1; i < palavras.length; i++) {
      camelCase += palavras[i].capitalize();
    }
    return camelCase;
  }

  ///Replace all letters with accents for the same ones without
  String get removeAccentInWord {
    String text = this;
    text = text.replaceAllMapped(
        RegExp(r'[áàâãäéèêëíìîïóòôõöúùûüçÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇ]'), (match) {
      return mapAccents[match.group(0)]!;
    });

    return text;
  }
}

extension StringNullExtensions on String? {
  /// Checks is the string is not null nor empty
  bool get isNotNullOrEmpty {
    return this?.isNotEmpty ?? false;
  }
}
