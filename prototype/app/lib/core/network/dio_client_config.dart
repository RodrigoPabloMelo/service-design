import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:studio_app/core/services/device/secure_storage/device_secure_storage.dart';
import 'package:studio_app/core/di/app_dependencies.dart';
import 'package:studio_app/core/flavor/flavor_config.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioClientConfig {
  DioClientConfig(this._flavorConfig) {
    _init();
  }

  late final Dio _dio;
  final FlavorConfig _flavorConfig;

  Dio get dio => _dio;

  void _init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _flavorConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    _dio.interceptors.addAll([
      CustomInterceptors(),
      if (kDebugMode) ...[
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          compact: false,
        ),
      ],
    ]);
  }
}

class CustomInterceptors extends InterceptorsWrapper {
  DeviceSecureStorage? _secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    _secureStorage ??= injector.get();

    final accessToken = await _secureStorage!.getSessionToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    handler.next(err);
  }
}
