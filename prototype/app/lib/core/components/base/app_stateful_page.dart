import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:studio_app/core/i18n/app_i18n.dart';
import 'package:studio_app/core/theme/app_theme.dart';

abstract class AppStatefulPage<T extends StatefulWidget> extends State<T> {
  List<BlocProvider>? get providers => null;

  Widget buildWidget(BuildContext context, AppI18n i18n, AppTheme theme);

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<AppI18n>();
    final theme = context.watch<AppTheme>();

    if (providers?.isNotEmpty ?? false) {
      return MultiBlocProvider(
        providers: providers!,
        child: Builder(
          builder: (context) => buildWidget(context, i18n, theme),
        ),
      );
    } else {
      return buildWidget(context, i18n, theme);
    }
  }
}
