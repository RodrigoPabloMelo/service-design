import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_app/core/utils/helpers/result/result.dart';
import 'package:studio_app/features/example/data/datasources/example_datasource.dart';
import 'package:studio_app/features/example/data/failures/example_failures.dart';
import 'package:studio_app/features/example/data/repositories/example_repository_impl.dart';
import 'package:studio_app/features/example/domain/entities/example.dart';

import '../../mock_data.dart';

class MockExampleDatasource extends Mock implements ExampleDatasource {}

void main() {
  late MockExampleDatasource mockDatasource;
  late ExampleRepositoryImpl repository;

  setUp(() {
    mockDatasource = MockExampleDatasource();
    repository = ExampleRepositoryImpl(mockDatasource);
  });

  group('example - ', () {
    test('should map the datasource model to entity on success', () async {
      // Arrange
      when(() => mockDatasource.example())
          .thenAnswer((_) async => const Success(tExampleApiModel));

      // Act
      final result = await repository.example();

      // Assert
      expect(result, isA<Success<ExampleFailure, Example>>());
      expect((result as Success).object, tExample);
      verify(() => mockDatasource.example()).called(1);
      verifyNoMoreInteractions(mockDatasource);
    });

    test('should forward the failure when the datasource fails', () async {
      // Arrange
      when(() => mockDatasource.example())
          .thenAnswer((_) async => const Failure(tExampleFailureInfo));

      // Act
      final result = await repository.example();

      // Assert
      expect(result, isA<Failure<ExampleFailure, Example>>());
      expect((result as Failure).error, tExampleFailureInfo);
      verify(() => mockDatasource.example()).called(1);
      verifyNoMoreInteractions(mockDatasource);
    });
  });
}
