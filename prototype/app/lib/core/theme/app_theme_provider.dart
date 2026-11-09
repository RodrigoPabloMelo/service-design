import 'package:flutter/material.dart';
import 'package:studio_app/core/theme/app_theme.dart';
import 'package:studio_app/core/theme/app_theme_changer.dart';
import 'package:provider/provider.dart';

class AppThemeProvider extends StatefulWidget {
  const AppThemeProvider({
    required this.child,
    required this.initialTheme,
    super.key,
  });

  final Widget child;
  final AppTheme initialTheme;

  @override
  State<AppThemeProvider> createState() => _AppThemeProviderState();
}

class _AppThemeProviderState extends State<AppThemeProvider>
    with SingleTickerProviderStateMixin {
  late final changer = AppThemeChanger(
    vsync: this,
    initialTheme: widget.initialTheme,
  );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: changer,
      child: Consumer<AppThemeChanger>(
        builder: (_, __, ___) {
          return Provider.value(
            value: changer.currentTheme,
            child: widget.child,
          );
        },
      ),
    );
  }
}
