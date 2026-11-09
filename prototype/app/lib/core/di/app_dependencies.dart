import 'package:studio_app/core/components/widgets/flushbar/flushbar_area_cubit.dart';
import 'package:studio_app/core/routes/app_routes.dart';
import 'package:studio_app/core/services/device/di/device_dependencies.dart';
import 'package:studio_app/core/di/get_it_injector_impl.dart';
import 'package:studio_app/core/flavor/flavor_config.dart';
import 'package:studio_app/core/i18n/app_i18n.dart';
import 'package:studio_app/core/logs/app_logger.dart';
import 'package:studio_app/core/network/dio_client_impl.dart';
import 'package:studio_app/core/network/http_client.dart';
import 'package:studio_app/core/network/dio_client_config.dart';
import 'package:studio_app/core/services/event_bus/app_event_bus.dart';
import 'package:studio_app/core/services/url_launcher/di/url_launcher_dependencies.dart';
import 'package:studio_app/core/theme/di/app_theme_dependencies.dart';
import 'package:studio_app/features/example/data/di/example_dependencies.dart';

final injector = GetItInjectorImpl();

Future<void> configureAppDependencies(FlavorConfig flavorConfig) async {
  injector.registerSingleton<FlavorConfig>(flavorConfig);

  injector.registerSingleton<AppEventBus>(AppEventBus());

  injector.registerLazySingleton<FlushbarAreaCubit>(() => FlushbarAreaCubit());

  injector.registerLazySingleton<AppLogger>(
    () => AppLoggerManager(
      loggers: [TerminalLogger()],
    ),
  );

  injector.registerLazySingleton<HttpClient>(
    () => DioClientImpl(DioClientConfig(flavorConfig).dio),
  );

  await configureDeviceDependencies(injector);

  await configureUrlLauncherDependencies(injector);

  await configureAppThemeDependencies(injector);

  await configureExampleDependencies(injector);

  injector.registerLazySingleton<AppI18n>(
    () => AppI18n(
      injector.get(),
      injector.get(),
      injector.get(),
      injector.get(),
    ),
  );

  injector.registerSingleton<AppRouter>(AppRouter());
}
