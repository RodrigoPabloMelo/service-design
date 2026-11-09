import 'package:flutter/material.dart';

abstract class AppTheme {
  // ========== TEXT STYLES ==========
  TextStyle get displayLargeText => const TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        height: 64 / 57,
        letterSpacing: -0.25,
      );

  TextStyle get titleLargeText => const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        height: 28 / 22,
      );

  // ========== COLORS ==========
  // --- Primary ---
  Color get primaryColor;

  // --- Secondary ---
  Color get secondaryColor;
}
