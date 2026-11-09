// ignore_for_file: depend_on_referenced_packages
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:studio_app/core/components/widgets/flushbar/flushbar_area.dart';
import 'package:studio_app/core/di/app_dependencies.dart';
import 'package:studio_app/core/i18n/app_i18n.dart';
import 'package:studio_app/core/routes/app_routes.dart';
import 'package:studio_app/core/theme/app_theme_provider.dart';
import 'package:studio_app/core/theme/app_theme_repository.dart';
import 'package:studio_app/core/utils/no_glow_behavior.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  final i18n = injector.get<AppI18n>();
  final routerConfig = injector.get<AppRouter>().config;
  final themeRepository = injector.get<AppThemeRepository>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: i18n,
      child: AppThemeProvider(
        initialTheme: themeRepository.initialAppTheme,
        child: MaterialApp.router(
          title: 'Flutter MVVM Leap',
          routerConfig: routerConfig,
          debugShowCheckedModeBanner: false,
          locale: DevicePreview.locale(context),
          supportedLocales: const [
            Locale('pt', 'BR'),
            Locale('en', 'US'),
            Locale('es', 'ES'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: MediaQuery.of(context).textScaler.clamp(
                        minScaleFactor: 1.0,
                        maxScaleFactor: 1.5,
                      ),
                ),
                child: ScrollConfiguration(
                  behavior: NoGlowBehavior(),
                  child: DevicePreview.appBuilder(
                    context,
                    Stack(
                      children: [
                        if (child != null) child,
                        const FlushbarArea(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
