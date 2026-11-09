import 'package:studio_app/features/example/data/models/example_api_model.dart';
import 'package:studio_app/features/example/domain/entities/example.dart';

class ExampleMapper {
  static Example toEntity(ExampleApiModel model) {
    return Example(
      id: model.id,
      name: model.name,
    );
  }
}
