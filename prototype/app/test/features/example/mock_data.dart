import 'package:studio_app/core/utils/helpers/result/result.dart';
import 'package:studio_app/features/example/data/failures/example_failures.dart';
import 'package:studio_app/features/example/data/models/example_api_model.dart';
import 'package:studio_app/features/example/domain/entities/example.dart';

const tExampleId = 'example-id-1';
const tExampleName = 'Example Name';

const tExampleApiModel = ExampleApiModel(id: tExampleId, name: tExampleName);
const tExample = Example(id: tExampleId, name: tExampleName);

const tExampleJson = <String, dynamic>{'id': tExampleId, 'name': tExampleName};

const tExampleFailureInfo = FailureInfo<ExampleFailure>(
  type: ExampleFailure.unkown,
);
