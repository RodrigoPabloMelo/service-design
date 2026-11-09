import 'package:studio_app/core/di/injector.dart';
import 'package:studio_app/core/services/url_launcher/url_launcher.dart';
import 'package:studio_app/core/services/url_launcher/url_launcher_impl.dart';

Future<void> configureUrlLauncherDependencies(Injector injector) async {
  injector.registerFactory<UrlLauncher>(() => UrlLauncherImpl());
}
