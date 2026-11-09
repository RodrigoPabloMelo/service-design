import 'package:studio_app/core/utils/helpers/result/result.dart';
import 'package:studio_app/features/example/data/failures/example_failures.dart';
import 'package:studio_app/features/example/data/models/example_api_model.dart';

abstract class ExampleDatasource {
  Future<Result<ExampleFailure, ExampleApiModel>> example();
}
