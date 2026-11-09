import 'dart:async';

abstract class DeviceLocalPreferences {
  String? getString(String key);
  Future<void> setString(String key, String value);
  Future<bool> remove(String key);
}
