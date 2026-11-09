import 'package:studio_app/core/di/injector.dart';
import 'package:studio_app/core/theme/app_theme_repository.dart';

Future<void> configureAppThemeDependencies(Injector injector) async {
  injector.registerFactory<AppThemeRepository>(
      () => AppThemeRepository(injector.get()));
}
