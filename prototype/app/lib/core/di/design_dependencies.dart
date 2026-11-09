import 'package:studio_app/core/components/widgets/flushbar/flushbar_area_cubit.dart';
import 'package:studio_app/core/di/app_dependencies.dart';
import 'package:studio_app/core/flavor/flavor_config.dart';
import 'package:studio_app/core/logs/app_logger.dart';

// DI leve para o loop de design (Flutter Web hospedado).
// Registra apenas dependências web-safe: sem serviços nativos, sem dart:io.
// Datasources retornam mocks — nenhuma chamada HTTP real.
//
// Adicione as dependências de cada feature conforme forem criadas:
// configureXDependencies(injector);

Future<void> setupDesignDependencies() async {
  injector.registerSingleton<FlavorConfig>(
    FlavorConfig(baseUrl: '', flavor: AppFlavor.dev),
  );

  injector.registerLazySingleton<AppLogger>(
    () => AppLoggerManager(loggers: [TerminalLogger()]),
  );

  injector.registerLazySingleton<FlushbarAreaCubit>(() => FlushbarAreaCubit());

  // Features: registre aqui conforme o designer criar cada uma.
}
