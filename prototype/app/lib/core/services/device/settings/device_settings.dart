import 'dart:io';

abstract class DeviceSettings {
  Future<void> openAppSettings();
  Future<Directory> getAppDocumentsDir();
}
