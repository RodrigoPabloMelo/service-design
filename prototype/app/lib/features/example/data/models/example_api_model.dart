import 'package:equatable/equatable.dart';

class ExampleApiModel extends Equatable {
  factory ExampleApiModel.fromJson(Map<String, dynamic> json) {
    return ExampleApiModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
  const ExampleApiModel({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
