import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:studio_app/core/services/device/info/device_info.dart';
import 'package:studio_app/core/services/device/local_preferences/device_local_preferences.dart';
import 'package:studio_app/core/i18n/enums/language.dart';
import 'package:studio_app/core/logs/app_logger.dart';
import 'package:studio_app/core/services/device/local_preferences/enums/device_local_preferences_key.dart';
import 'package:path/path.dart';

class AppI18n extends ChangeNotifier {
  AppI18n(
    this._rootBundle,
    this._appLogger,
    this._deviceInfo,
    this._deviceLocalPreferences,
  );

  final PlatformAssetBundle _rootBundle;
  final AppLogger _appLogger;
  final DeviceInfo _deviceInfo;
  final DeviceLocalPreferences _deviceLocalPreferences;

  late Language currentLanguage;
  Map<String, dynamic>? translations;

  Future<void> init() async {
    final language = await _getCurrentLanguage();
    final path = join('assets', 'i18n', '${language.locale}.json');
    final fileContent = await _rootBundle.loadString(path);
    translations = jsonDecode(fileContent) as Map<String, dynamic>;
    notifyListeners();
  }

  String get(String path, {List<String>? params}) {
    try {
      String text = _checkPath(path) as String;

      if (params != null && text.contains('{}')) {
        for (final v in params) {
          text = text.replaceFirst('{}', v);
        }
      }

      return text;
    } catch (e) {
      _appLogger.e('Error when searching for path translation: $path. $e');
      return '';
    }
  }

  String getPlural(String path, int count, {List<String>? params}) {
    try {
      final keys = _checkPath(path);
      String text = (count == 1 ? keys['one'] : keys['many']) as String;

      if (params != null && text.contains('{}')) {
        for (final v in params) {
          text = text.replaceFirst('{}', v);
        }
      }

      return text;
    } catch (e) {
      _appLogger.e('Error when searching for path translation: $path. $e');
      return '';
    }
  }

  Future<void> changeCurrentLanguage(Language language) async {
    await _deviceLocalPreferences.setString(
      DeviceLocalPreferencesKey.appLanguage.name,
      language.locale,
    );

    return init();
  }

  Future<Language> _getCurrentLanguage() async {
    final isDeviceSupported = await _deviceInfo.checkLocaleSupport();
    final language = _deviceLocalPreferences.getString(
      DeviceLocalPreferencesKey.appLanguage.name,
    );

    if (language == null && isDeviceSupported) {
      // PlatformDispatcher em vez de Platform.localeName: web-safe (dart:io
      // quebra o build web, que é o produto do loop de design).
      final platformLocale = PlatformDispatcher.instance.locale
          .toLanguageTag()
          .replaceAll('-', '_');
      final locale = platformLocale.split('_').first.toLowerCase();

      currentLanguage = Language.values.firstWhere(
        (e) => e.locale.split('_').first == locale,
        orElse: () => Language.portuguese,
      );
    } else {
      currentLanguage = Language.values.firstWhere(
        (e) => e.locale == language,
        orElse: () => Language.portuguese,
      );
    }

    notifyListeners();
    return currentLanguage;
  }

  dynamic _checkPath(String path) {
    if (translations == null) return '';

    final keys = path.split('.');

    Map<String, dynamic> current = translations!;
    for (final key in keys.sublist(0, keys.length - 1)) {
      current = current[key] as Map<String, dynamic>;
    }

    return current[keys.last];
  }
}
