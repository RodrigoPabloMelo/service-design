extension DateTimeExtension on DateTime {
  /// Format date in readable string:
  String get formatted =>
      "${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year";
}
