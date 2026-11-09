enum AppFlavor { dev, hml, prod }

class FlavorConfig {
  FlavorConfig({
    required this.baseUrl,
    required this.flavor,
  });
  final String baseUrl;
  final AppFlavor flavor;
}
