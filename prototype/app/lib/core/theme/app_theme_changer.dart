import 'package:flutter/material.dart';
import 'package:studio_app/core/di/app_dependencies.dart';
import 'package:studio_app/core/theme/app_theme.dart';
import 'package:studio_app/core/theme/app_theme_repository.dart';
import 'package:studio_app/core/theme/app_theme_transitioner.dart';
import 'package:studio_app/core/theme/themes/app_dark_theme.dart';
import 'package:studio_app/core/theme/themes/app_light_theme.dart';

class AppThemeChanger extends ChangeNotifier {
  AppThemeChanger({
    required this.vsync,
    required this.initialTheme,
    AppThemeRepository? themeRepository,
  }) : _themeRepository = themeRepository ?? injector.get() {
    _setListener();
  }

  final TickerProvider vsync;
  final AppTheme initialTheme;
  final AppThemeRepository _themeRepository;

  AppTheme? _targetTheme;
  late AppTheme _currentTheme = initialTheme;

  late final _controller = AnimationController(
    vsync: vsync,
    duration: const Duration(milliseconds: 500),
  );

  bool get isDarkTheme => _currentTheme is AppDarkTheme;

  AppTheme get currentTheme => _targetTheme == null
      ? _currentTheme
      : AppThemeTransitioner(
          animation: _controller,
          currentTheme: _currentTheme,
          targetTheme: _targetTheme!,
        );

  void changeTheme() {
    _targetTheme = isDarkTheme ? AppLightTheme() : AppDarkTheme();
    _themeRepository.setUserThemePreference(_targetTheme!);
    _controller.forward();
  }

  void _setListener() {
    _controller.addListener(() {
      if (_controller.status == AnimationStatus.completed) {
        _currentTheme = _targetTheme!;
        _targetTheme = null;
        _controller.reset();
      }
      notifyListeners();
    });
  }
}
