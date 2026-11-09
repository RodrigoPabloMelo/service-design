extension DoubleExtension on double {
  /// Formats the number as a brazilian monetary value:
  String toCurrency({String symbol = 'R\$', int decimals = 2}) {
    return '$symbol${toStringAsFixed(decimals).replaceAll('.', ',')}';
  }

  /// Transforms the double into the nearest integer:
  int get rounded => round();
}
