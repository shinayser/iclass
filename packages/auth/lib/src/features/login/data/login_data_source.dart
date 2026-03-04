import 'login_type.dart';

enum LoginDataSourceError { invalidCredentials, unknownError }

abstract interface class LoginDataSource {
  Future<LoginType> login(String username, String password);
}

class MockedLoginDataSource implements LoginDataSource {
  @override
  Future<LoginType> login(String username, String password) {
    return Future.delayed(const Duration(seconds: 2), () {
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
