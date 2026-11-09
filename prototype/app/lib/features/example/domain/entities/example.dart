import 'package:equatable/equatable.dart';

class Example extends Equatable {
  const Example({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
