import 'package:get_it/get_it.dart';

class Injection {
  static final GetIt _getIt = GetIt.instance;

  static void registerLazySingleton<T extends Object>(
    T Function() factory, {
    String? instanceName,
    DisposingFunc<T>? dispose,
  }) => _getIt.registerLazySingleton<T>(
    factory,
    instanceName: instanceName,
    dispose: dispose,
  );

  static void registerLazySingletonAsync<T extends Object>(
    Future<T> Function() factory, {
    String? instanceName,
    DisposingFunc<T>? dispose,
  }) => _getIt.registerLazySingletonAsync<T>(
    factory,
    instanceName: instanceName,
    dispose: dispose,
  );

  static void registerSingleton<T extends Object>(
    T instance, {
    String? instanceName,
    bool? signalsReady,
    DisposingFunc<T>? dispose,
  }) => _getIt.registerSingleton<T>(
    instance,
    instanceName: instanceName,
    signalsReady: signalsReady,
    dispose: dispose,
  );

  static void registerFactory<T extends Object>(
    T Function() factory, {
    String? instanceName,
  }) => _getIt.registerFactory<T>(factory, instanceName: instanceName);

  static T get<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
  }) =>
      _getIt.get<T>(instanceName: instanceName, param1: param1, param2: param2);

  static Future<T> getAsync<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
  }) => _getIt.getAsync<T>(
    instanceName: instanceName,
    param1: param1,
    param2: param2,
  );

  static void resetLazySingleton<T extends Object>({
    T? instance,
    String? instanceName,
    void Function(T)? disposing,
  }) => _getIt.resetLazySingleton<T>(
    instance: instance,
    instanceName: instanceName,
    disposingFunction: disposing,
  );

  static bool isRegistered<T extends Object>({
    Object? instance,
    String? instanceName,
  }) => _getIt.isRegistered<T>(instance: instance, instanceName: instanceName);

  static Future<void> reset({bool dispose = true}) =>
      _getIt.reset(dispose: dispose);
}
