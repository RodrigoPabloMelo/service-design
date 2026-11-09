import 'package:dio/dio.dart';

class HttpClientException extends DioException {
  HttpClientException({
    required super.requestOptions,
    super.response,
    super.type = DioExceptionType.unknown,
    super.error,
    super.message,
    StackTrace? stackTrace,
  });
}
