abstract class DeviceSecureStorage {
  Future<void> saveSessionToken(String token);
  Future<String?> getSessionToken();
  Future<void> deleteSessionToken();
}
