import 'dart:async';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:studio_app/app_widget.dart';
import 'package:studio_app/core/di/app_dependencies.dart';
import 'package:studio_app/core/flavor/flavor_config.dart';
import 'package:studio_app/core/i18n/app_i18n.dart';

Future<void> bootstrap(FlavorConfig flavorConfig) async {
  unawaited(runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await configureAppDependencies(flavorConfig);

      await injector.get<AppI18n>().init();

      runApp(
        DevicePreview(
          builder: (context) => const AppWidget(),
          enabled: const bool.fromEnvironment(
            'DEVICE_PREVIEW',
            defaultValue: false,
          ),
        ),
      );
    },
    (error, stack) {
      debugPrint('$error $stack');
    },
  ));
}
