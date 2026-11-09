import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:studio_app/core/di/app_dependencies.dart';
import 'package:studio_app/core/utils/extensions/cubit_extension.dart';
import 'package:studio_app/core/utils/helpers/result/result.dart';
import 'package:studio_app/features/example/data/failures/example_failures.dart';
import 'package:studio_app/features/example/domain/repositories/example_repository.dart';
import 'package:studio_app/features/example/presentation/views/example_page_actions.dart';

part 'example_page_state.dart';

class ExamplePageCubit extends Cubit<ExamplePageCubitState> {
  ExamplePageCubit(
    this._actions, {
    ExampleRepository? exampleRepository,
  })  : _exampleRepository = exampleRepository ?? injector.get(),
        super(const ExamplePageCubitState());

  ExamplePageActions? _actions;
  final ExampleRepository _exampleRepository;

  Future<void> onExamplePressed() async {
    safeEmit(state.copyWith(isLoading: true));
    final result = await _exampleRepository.example();

    if (result case Failure(error: final error)) {
      switch (error.type) {
        case ExampleFailure.example:
        // EXAMPLE ACTION
        default:
        // DEFAULT ACTION
      }
    } else {
      // EXAMPLE ACTION
    }

    safeEmit(state.copyWith(isLoading: false));
  }

  void showFlushbar() => _actions?.showFlushbar();

  void showModalBottomSheet() => _actions?.showModalBottomSheet();

  void onFieldChanged(String field) => safeEmit(state.copyWith(field: field));

  void onField2Changed(String field2) =>
      safeEmit(state.copyWith(field2: field2));

  @override
  Future<void> close() {
    _actions = null;
    return super.close();
  }
}
