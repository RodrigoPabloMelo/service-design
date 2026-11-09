import 'package:go_router/go_router.dart';
import 'package:studio_app/features/example/presentation/views/example_page.dart';
import 'package:studio_app/features/splash/presentation/views/splash_page.dart';

class AppRouter {
  final config = GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.example,
        builder: (context, state) => const ExamplePage(),
      ),
    ],
  );
}

class AppRoutes {
  static const String splash = '/splash';
  static const String example = '/example';
}

class AppRoute {
  const AppRoute({required this.path, required this.fullPath});

  final String path;
  final String fullPath;
}

class AppRouteWithId {
  const AppRouteWithId({
    required this.path,
    required String Function(String? id) buildFullPath,
  }) : _buildFullPath = buildFullPath;

  final String path;
  final String Function(String? id) _buildFullPath;

  String fullPath({required String? id}) => _buildFullPath(id);
}
