import 'package:dio/dio.dart';
import 'package:studio_app/core/network/http_client.dart';
import 'package:studio_app/core/network/http_client_exception.dart';

class DioClientImpl implements HttpClient {
  DioClientImpl(this._dio);

  final Dio _dio;

  @override
  Future<Response<dynamic>> get(
    String url, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw HttpClientException(
        requestOptions: e.requestOptions,
        response: e.response,
        type: e.type,
        error: e.error,
        message: e.message,
        stackTrace: e.stackTrace,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response<dynamic>> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw HttpClientException(
        requestOptions: e.requestOptions,
        response: e.response,
        type: e.type,
        error: e.error,
        message: e.message,
        stackTrace: e.stackTrace,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response<dynamic>> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw HttpClientException(
        requestOptions: e.requestOptions,
        response: e.response,
        type: e.type,
        error: e.error,
        message: e.message,
        stackTrace: e.stackTrace,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response<dynamic>> patch(
    String url, {
    dynamic data,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.patch(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw HttpClientException(
        requestOptions: e.requestOptions,
        response: e.response,
        type: e.type,
        error: e.error,
        message: e.message,
        stackTrace: e.stackTrace,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response<dynamic>> delete(
    String url, {
    Map<String, dynamic>? headers,
  }) async {
    try {
      return await _dio.delete(
        url,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      throw HttpClientException(
        requestOptions: e.requestOptions,
        response: e.response,
        type: e.type,
        error: e.error,
        message: e.message,
        stackTrace: e.stackTrace,
      );
    } catch (e) {
      rethrow;
    }
  }
}
