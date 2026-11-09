import 'package:flutter/cupertino.dart';

/// Indicador de atividade no estilo iOS (HIG) — substitui o spinner
/// circular do Material nas telas de design.
class AppActivityIndicator extends StatelessWidget {
  const AppActivityIndicator({this.radius = 9, this.color, super.key});

  final double radius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CupertinoActivityIndicator(radius: radius, color: color);
  }
}
