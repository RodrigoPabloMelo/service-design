import 'package:studio_app/core/utils/helpers/result/result.dart';
import 'package:studio_app/features/example/data/failures/example_failures.dart';
import 'package:studio_app/features/example/domain/entities/example.dart';

abstract class ExampleRepository {
  Future<Result<ExampleFailure, Example>> example();
}
