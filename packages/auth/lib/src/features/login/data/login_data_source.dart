import 'package:common/common.dart' show LoginType;

enum LoginDataSourceError { invalidCredentials, unknownError }

abstract interface class LoginDataSource {
  Future<LoginType> login(String username, String password);
}

class MockedLoginDataSource implements LoginDataSource {
  @override
  Future<LoginType> login(String username, String password) {
    return Future.delayed(const Duration(milliseconds: 1200), () {
      switch ((username, password)) {
        case ('student', 'student123'):
          return .student;
        case ('teacher', 'teacher123'):
          return .teacher;
        default:
          throw LoginDataSourceError.invalidCredentials;
      }
    });
  }
}
