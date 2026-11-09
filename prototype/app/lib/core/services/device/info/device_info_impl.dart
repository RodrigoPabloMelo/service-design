import 'dart:io';
import 'package:studio_app/core/services/device/info/device_info.dart';
import 'package:studio_app/core/utils/extensions/string_extension.dart';
import 'package:studio_app/core/utils/helpers/result/result.dart';
import 'package:studio_app/core/utils/helpers/result/enums/generic_failure.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

class DeviceInfoImpl implements DeviceInfo {
  DeviceInfoImpl(this._info);

  final DeviceInfoPlugin _info;

  @override
  Future<bool> checkLocaleSupport() async {
    if (Platform.isIOS) return true;

    final androidInfo = await _info.androidInfo;

    return androidInfo.version.sdkInt >= 33;
  }

  @override
  Future<Result<GenericFailure, void>> downloadAndSaveFile(
    String url,
    String fileName,
  ) async {
    try {
      final tempPath = '${Directory.systemTemp.path}/$fileName';
      await Dio().download(url, tempPath);
      final tempFile = File(tempPath);

      final isImage = fileName.hasImageFormat;

      if (isImage) {
        await Gal.putImage(tempPath);
      } else {
        final saveResult = await _saveFileToDevice(tempFile, fileName);
        if (saveResult is Failure) return saveResult;
      }

      if (await tempFile.exists()) await tempFile.delete();

      return const Success(null);
    } catch (e) {
      return const Failure(FailureInfo(type: GenericFailure.unknown));
    }
  }

  Future<Result<GenericFailure, void>> _saveFileToDevice(
    File file,
    String fileName,
  ) async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _info.androidInfo;

        if (androidInfo.version.sdkInt >= 29) {
          final mediaStore = MediaStore();
          await MediaStore.ensureInitialized();
          MediaStore.appFolder = 'Download';

          await mediaStore.saveFile(
            tempFilePath: file.path,
            dirType: DirType.download,
            dirName: DirName.download,
          );
        } else {
          if (!await _requestStoragePermission()) {
            return const Failure(FailureInfo(type: GenericFailure.unknown));
          }

          final dir = Directory('/storage/emulated/0/Download');
          if (!await dir.exists()) await dir.create(recursive: true);
          final saveFile = File('${dir.path}/$fileName');
          await saveFile.writeAsBytes(file.readAsBytesSync());
        }
      } else if (Platform.isIOS) {
        await FlutterFileDialog.saveFile(
          params: SaveFileDialogParams(sourceFilePath: file.path),
        );
      }

      return const Success(null);
    } catch (e) {
      return const Failure(FailureInfo(type: GenericFailure.unknown));
    }
  }

  Future<bool> _requestStoragePermission() async {
    final status = await Permission.storage.status;
    if (status.isGranted) return true;
    final result = await Permission.storage.request();
    return result.isGranted;
  }
}
