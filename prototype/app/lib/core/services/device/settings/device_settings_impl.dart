import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:studio_app/core/services/device/settings/device_settings.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class DeviceSettingsImpl implements DeviceSettings {
  @override
  Future<void> openAppSettings() => AppSettings.openAppSettings();

  @override
  Future<Directory> getAppDocumentsDir() =>
      path_provider.getApplicationDocumentsDirectory();
}
