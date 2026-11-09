import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studio_app/core/services/device/local_preferences/device_local_preferences.dart';

class DeviceLocalPreferencesImpl implements DeviceLocalPreferences {
  DeviceLocalPreferencesImpl(this._preferences);

  final SharedPreferences _preferences;

  @override
  String? getString(String key) => _preferences.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _preferences.setString(key, value);

  @override
  Future<bool> remove(String key) async => _preferences.remove(key);
}
