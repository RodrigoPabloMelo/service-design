abstract class Injector {
  T get<T extends Object>();
  void registerSingleton<T extends Object>(T instance);
  void registerLazySingleton<T extends Object>(T Function() instanceFunc);
  void registerFactory<T extends Object>(T Function() instanceFunc);
}
