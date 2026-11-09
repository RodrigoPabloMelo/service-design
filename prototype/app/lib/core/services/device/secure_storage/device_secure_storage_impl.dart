import 'package:studio_app/core/services/device/secure_storage/enums/device_secure_storage_key.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:studio_app/core/services/device/secure_storage/device_secure_storage.dart';

class DeviceSecureStorageImpl extends DeviceSecureStorage {
  DeviceSecureStorageImpl(this._secureStorage);

  final FlutterSecureStorage _secureStorage;

  @override
  Future<void> saveSessionToken(String token) => _secureStorage.write(
        value: token,
        key: DeviceSecureStorageKey.sessionToken.name,
      );

  @override
  Future<String?> getSessionToken() => _secureStorage.read(
        key: DeviceSecureStorageKey.sessionToken.name,
      );

  @override
  Future<void> deleteSessionToken() => _secureStorage.delete(
        key: DeviceSecureStorageKey.sessionToken.name,
      );
}
