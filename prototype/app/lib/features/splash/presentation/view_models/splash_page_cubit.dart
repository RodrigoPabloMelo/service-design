import 'package:bloc/bloc.dart';
import 'package:studio_app/features/splash/presentation/views/splash_page_actions.dart';

part 'splash_page_state.dart';

class SplashPageCubit extends Cubit<SplashPageCubitState> {
  SplashPageCubit(this._actions) : super(const SplashPageCubitState());

  SplashPageActions? _actions;

  Future<void> initalize() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    _actions?.navToExample();
  }

  @override
  Future<void> close() {
    _actions = null;
    return super.close();
  }
}
