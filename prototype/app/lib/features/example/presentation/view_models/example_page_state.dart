part of 'example_page_cubit.dart';

class ExamplePageCubitState extends Equatable {
  const ExamplePageCubitState({
    this.field = '',
    this.field2 = '',
    this.isLoading = false,
  });

  final String field;
  final String field2;
  final bool isLoading;

  ExamplePageCubitState copyWith({
    String? field,
    String? field2,
    bool? isLoading,
  }) {
    return ExamplePageCubitState(
      field: field ?? this.field,
      field2: field2 ?? this.field2,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [field, field2, isLoading];
}
