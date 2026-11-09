import 'package:bloc/bloc.dart';
import 'package:studio_app/core/utils/extensions/cubit_extension.dart';
import 'package:equatable/equatable.dart';

part 'flushbar_area_state.dart';

// You can add more types here
enum FlushbarType { alert }

class FlushbarAreaCubit extends Cubit<FlushbarAreaState> {
  FlushbarAreaCubit() : super(const FlushbarAreaState());

  void showFlushbar(Flushbar flushbar) =>
      safeEmit(FlushbarAreaState(flushbars: [flushbar]));

  void removeFlushbar(Flushbar flushbar) {
    final flushbars = List<Flushbar>.from(state.flushbars);
    flushbars.removeAt(flushbars.indexOf(flushbar));

    safeEmit(FlushbarAreaState(flushbars: flushbars));
  }
}

class Flushbar extends Equatable {
  const Flushbar.alert({
    required this.text,
    this.duration = const Duration(seconds: 2),
  }) : type = FlushbarType.alert;

  final String text;
  final FlushbarType type;
  final Duration duration;

  @override
  List<Object?> get props => [text, type, duration];
}
