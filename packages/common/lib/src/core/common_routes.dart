import 'package:common/common.dart' show LoginType;

class CommonRoutes {
  static String get login => '/login';
  static String get teacherHome => '/teacher/home';
  static String get studentHome => '/student/home';

  static String getHome(LoginType loginType) {
    switch (loginType) {
      case LoginType.teacher:
        return teacherHome;
      case LoginType.student:
        return studentHome;
    }
  }
}
