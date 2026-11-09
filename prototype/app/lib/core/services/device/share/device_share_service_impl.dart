import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:studio_app/core/services/device/share/device_share_service.dart';
import 'package:share_plus/share_plus.dart';

class DeviceShareServiceImpl implements DeviceShareService {
  final _sharePlus = SharePlus.instance;

  @override
  Future<void> shareImage(Uint8List image) async {
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/image.png').writeAsBytes(image);

    await _sharePlus.share(ShareParams(files: [XFile(file.path)]));
  }
}
