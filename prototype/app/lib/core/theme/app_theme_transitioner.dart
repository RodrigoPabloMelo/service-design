import 'package:flutter/material.dart';
import 'package:studio_app/core/theme/app_theme.dart';

class AppThemeTransitioner implements AppTheme {
  AppThemeTransitioner({
    required this.currentTheme,
    required this.targetTheme,
    required this.animation,
  });

  final AppTheme currentTheme;
  final AppTheme targetTheme;
  final Animation<double> animation;

  Color evaluate(Color begin, Color end) =>
      ColorTween(begin: begin, end: end).evaluate(animation)!;

  // ========== TEXT STYLES ==========
  @override
  TextStyle get displayLargeText => targetTheme.displayLargeText;

  @override
  TextStyle get titleLargeText => targetTheme.titleLargeText;

  // ========== COLORS ==========
  @override
  Color get primaryColor =>
      evaluate(currentTheme.primaryColor, targetTheme.primaryColor);

  @override
  Color get secondaryColor =>
      evaluate(currentTheme.secondaryColor, targetTheme.secondaryColor);
}
