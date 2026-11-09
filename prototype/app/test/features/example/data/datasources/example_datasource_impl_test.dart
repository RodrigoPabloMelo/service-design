import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_app/core/logs/app_logger.dart';
import 'package:studio_app/core/network/http_client.dart';
import 'package:studio_app/core/utils/helpers/result/result.dart';
import 'package:studio_app/features/example/data/datasources/example_datasource_impl.dart';
import 'package:studio_app/features/example/data/failures/example_failures.dart';
import 'package:studio_app/features/example/data/models/example_api_model.dart';

import '../../mock_data.dart';

class MockHttpClient extends Mock implements HttpClient {}

class MockAppLogger extends Mock implements AppLogger {}

void main() {
  late MockHttpClient mockHttpClient;
  late MockAppLogger mockLogger;
  late ExampleDatasourceImpl datasource;

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockLogger = MockAppLogger();
    datasource = ExampleDatasourceImpl(mockHttpClient, mockLogger);
  });

  group('example - ', () {
    test('should parse the response into a model on success', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: '/example'),
          data: tExampleJson,
        ),
      );

      // Act
      final result = await datasource.example();

      // Assert
      expect(result, isA<Success<ExampleFailure, ExampleApiModel>>());
      expect((result as Success).object, tExampleApiModel);
      verify(() => mockHttpClient.get('/example')).called(1);
      verifyNoMoreInteractions(mockHttpClient);
    });

    test('should log and return unkown failure when the request throws',
        () async {
      // Arrange
      final tException = DioException(
        requestOptions: RequestOptions(path: '/example'),
      );
      when(() => mockHttpClient.get(any())).thenThrow(tException);

      // Act
      final result = await datasource.example();

      // Assert
      expect(result, isA<Failure<ExampleFailure, ExampleApiModel>>());
      expect((result as Failure).error.type, ExampleFailure.unkown);
      verify(() => mockHttpClient.get('/example')).called(1);
      verify(() => mockLogger.e(tException)).called(1);
      verifyNoMoreInteractions(mockHttpClient);
      verifyNoMoreInteractions(mockLogger);
    });
  });
}
