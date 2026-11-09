extension ListNumberExtension on List<num> {
  /// Calculate the average of the elements in a list of numbers:
  double get average => isNotEmpty ? (reduce((a, b) => a + b) / length) : 0.0;
}

extension ListNullExtension on List<Object?>? {
  /// Checks is the list is not null nor empty
  bool get isNotNullOrEmpty {
    return this?.isNotEmpty ?? false;
  }
}
