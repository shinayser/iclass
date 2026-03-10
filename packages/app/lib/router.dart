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
    redirect: (context, state) async {
      final loginType =
          await Injection.get<LoginRepository>().currentLoginType();
      final path = state.matchedLocation;

      // Not logged in — force login screen
      if (loginType == null && path != CommonRoutes.login) {
        return CommonRoutes.login;
      }

      // Logged in — skip login screen
      if (loginType != null && path == CommonRoutes.login) {
        return CommonRoutes.getHome(loginType);
      }

      // Role guard — prevent cross-role navigation
      if (loginType == LoginType.teacher && path.startsWith('/student')) {
        return CommonRoutes.teacherHome;
      }
      if (loginType == LoginType.student && path.startsWith('/teacher')) {
        return CommonRoutes.studentHome;
      }

      return null;
    },
  );
}
