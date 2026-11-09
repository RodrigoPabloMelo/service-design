import 'package:studio_app/core/logs/app_logger.dart';
import 'package:studio_app/core/network/http_client.dart';
import 'package:studio_app/core/utils/helpers/result/result.dart';
import 'package:studio_app/features/example/data/datasources/example_datasource.dart';
import 'package:studio_app/features/example/data/failures/example_failures.dart';
import 'package:studio_app/features/example/data/models/example_api_model.dart';

class ExampleDatasourceImpl extends ExampleDatasource {
  ExampleDatasourceImpl(this._httpClient, this._logger);

  final HttpClient _httpClient;
  final AppLogger _logger;

  @override
  Future<Result<ExampleFailure, ExampleApiModel>> example() async {
    try {
      final result = await _httpClient.get('/example');

      return Success(
          ExampleApiModel.fromJson(result.data as Map<String, dynamic>));
    } catch (e) {
      _logger.e(e);
      return const Failure(FailureInfo(type: ExampleFailure.unkown));
    }
  }
}
