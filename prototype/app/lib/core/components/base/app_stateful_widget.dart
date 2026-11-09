import 'package:flutter/material.dart';
import 'package:studio_app/core/i18n/app_i18n.dart';
import 'package:studio_app/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

abstract class AppStatefulWidget<T extends StatefulWidget> extends State<T> {
  Widget buildWidget(BuildContext context, AppI18n i18n, AppTheme theme);

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<AppI18n>();
    final theme = context.watch<AppTheme>();

    return buildWidget(context, i18n, theme);
  }
}
