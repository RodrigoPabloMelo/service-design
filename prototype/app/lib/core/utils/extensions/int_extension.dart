extension IntExtension on int {
  /// Calculate whether a number is even:
  bool get isEven => this % 2 == 0;

  /// Convert seconds to minute format:
  String get toMinutes {
    final minutes = (this ~/ 60).toString().padLeft(2, '0');
    final seconds = (this % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Transforms seconds into a time format:
  String get toTimeString {
    final hours = (this ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((this % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (this % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Transforms an integer into a formatted string:
  String toDecimalString(int decimals) {
    return toDouble().toStringAsFixed(decimals);
  }

  /// Formats the number as storage size:
  String get toFileSize {
    if (this < 1024) return '$this B';
    final kb = this / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(2)} KB';
    final mb = kb / 1024;
    if (mb < 1024) return '${mb.toStringAsFixed(2)} MB';
    final gb = mb / 1024;
    return '${gb.toStringAsFixed(2)} GB';
  }
}
