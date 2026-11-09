import 'package:device_info_plus/device_info_plus.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter/services.dart';
import 'package:studio_app/core/di/injector.dart';
import 'package:studio_app/core/services/device/share/device_share_service.dart';
import 'package:studio_app/core/services/device/share/device_share_service_impl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studio_app/core/services/device/info/device_info.dart';
import 'package:studio_app/core/services/device/info/device_info_impl.dart';
import 'package:studio_app/core/services/device/local_preferences/device_local_preferences.dart';
import 'package:studio_app/core/services/device/local_preferences/device_local_preferences_impl.dart';
import 'package:studio_app/core/services/device/secure_storage/device_secure_storage.dart';
import 'package:studio_app/core/services/device/secure_storage/device_secure_storage_impl.dart';
import 'package:studio_app/core/services/device/settings/device_settings.dart';
import 'package:studio_app/core/services/device/settings/device_settings_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> configureDeviceDependencies(Injector injector) async {
  injector.registerFactory<DeviceSettings>(() => DeviceSettingsImpl());

  injector.registerFactory<DeviceInfo>(
    () => DeviceInfoImpl(DeviceInfoPlugin()),
  );

  injector.registerFactory<FileSystem>(() => const LocalFileSystem());

  injector.registerLazySingleton<PlatformAssetBundle>(
    () => PlatformAssetBundle(),
  );

  injector.registerLazySingleton<DeviceSecureStorage>(
    () => DeviceSecureStorageImpl(const FlutterSecureStorage()),
  );

  injector.registerLazySingleton<DeviceShareService>(
      () => DeviceShareServiceImpl());

  final sharedPreferences = await SharedPreferences.getInstance();
  injector.registerSingleton<SharedPreferences>(sharedPreferences);
  injector.registerFactory<DeviceLocalPreferences>(
    () => DeviceLocalPreferencesImpl(injector.get()),
  );
}
