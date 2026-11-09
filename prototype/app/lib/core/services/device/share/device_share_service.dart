import 'dart:typed_data';

abstract class DeviceShareService {
  Future<void> shareImage(Uint8List image);
}
