import 'package:studio_app/bootstrap.dart';
import 'package:studio_app/core/flavor/flavor_config.dart';

// Config vem em build time via --dart-define (não há env em runtime no web).
// No Studio, fe e be compartilham o domínio: /api resolve pelo ingress.
const _baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '/api');

void main() async {
  await bootstrap(
    FlavorConfig(
      flavor: AppFlavor.prod,
      baseUrl: _baseUrl,
    ),
  );
}
