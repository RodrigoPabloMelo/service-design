part of 'flushbar_area_cubit.dart';

class FlushbarAreaState extends Equatable {
  const FlushbarAreaState({this.flushbars = const []});

  final List<Flushbar> flushbars;

  @override
  List<Object> get props => [flushbars];
}
