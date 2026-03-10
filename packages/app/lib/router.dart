import 'package:common/common.dart';
import 'package:go_router/go_router.dart';

GoRouter buildRouter(List<Module> modules) {
  final allRoutes = modules
      .whereType<RoutedModule>()
      .expand((module) => module.routes)
      .toList();

  return GoRouter(
    initialLocation: CommonRoutes.login,
    routes: allRoutes,
  );
}
