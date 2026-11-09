import 'package:flutter/material.dart';

Future<T?> showAppModalBottomSheet<T>({
  required String name,
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor = Colors.transparent,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: backgroundColor,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    routeSettings: RouteSettings(name: name),
    builder: builder,
  );
}

Future<T?> showAppDialog<T>({
  required String name,
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    routeSettings: RouteSettings(name: name),
    builder: builder,
  );
}
