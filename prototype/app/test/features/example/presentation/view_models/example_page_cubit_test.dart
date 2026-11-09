import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_app/core/utils/helpers/result/result.dart';
import 'package:studio_app/features/example/domain/repositories/example_repository.dart';
import 'package:studio_app/features/example/presentation/view_models/example_page_cubit.dart';

import '../../mock_data.dart';

class MockExampleRepository extends Mock implements ExampleRepository {}

void main() {
  late MockExampleRepository mockRepository;

  setUp(() {
    mockRepository = MockExampleRepository();
  });

  ExamplePageCubit buildCubit() =>
      ExamplePageCubit(null, exampleRepository: mockRepository);

  group('onExamplePressed - ', () {
    blocTest<ExamplePageCubit, ExamplePageCubitState>(
      'should toggle isLoading and call repository when it succeeds',
      build: buildCubit,
      setUp: () {
        when(() => mockRepository.example())
            .thenAnswer((_) async => const Success(tExample));
      },
      act: (cubit) async => cubit.onExamplePressed(),
      expect: () => [
        const ExamplePageCubitState(isLoading: true),
        const ExamplePageCubitState(isLoading: false),
      ],
      verify: (cubit) {
        // Assert
        verify(() => mockRepository.example()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    blocTest<ExamplePageCubit, ExamplePageCubitState>(
      'should end with isLoading false when repository fails',
      build: buildCubit,
      setUp: () {
        when(() => mockRepository.example())
            .thenAnswer((_) async => const Failure(tExampleFailureInfo));
      },
      act: (cubit) async => cubit.onExamplePressed(),
      verify: (cubit) {
        // Assert
        expect(cubit.state.isLoading, isFalse);
        verify(() => mockRepository.example()).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );
  });

  group('onFieldChanged - ', () {
    blocTest<ExamplePageCubit, ExamplePageCubitState>(
      'should update field without calling repository',
      build: buildCubit,
      act: (cubit) => cubit.onFieldChanged('abc'),
      verify: (cubit) {
        // Assert
        expect(cubit.state.field, 'abc');
        verifyZeroInteractions(mockRepository);
      },
    );
  });

  group('onField2Changed - ', () {
    blocTest<ExamplePageCubit, ExamplePageCubitState>(
      'should update field2 without calling repository',
      build: buildCubit,
      act: (cubit) => cubit.onField2Changed('def'),
      verify: (cubit) {
        // Assert
        expect(cubit.state.field2, 'def');
        verifyZeroInteractions(mockRepository);
      },
    );
  });
}
