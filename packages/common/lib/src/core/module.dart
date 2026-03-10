import 'package:go_router/go_router.dart';

abstract class Module {
  Future<void> init();
}

mixin RoutedModule on Module {
  List<RouteBase> get routes;
}
