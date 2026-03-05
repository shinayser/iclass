import 'package:auth/src/features/login/data/login_data_source.dart';
import 'package:common/common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockedLoginDataSource dataSource;

  setUp(() => dataSource = MockedLoginDataSource());

  group('MockedLoginDataSource', () {
    group('login — valid credentials', () {
      test('returns LoginType.teacher for teacher credentials', () async {
        final result = await dataSource.login('teacher', 'teacher123');
        expect(result, LoginType.teacher);
      });

      test('returns LoginType.student for student credentials', () async {
        final result = await dataSource.login('student', 'student123');
        expect(result, LoginType.student);
      });
    });

    group('login — invalid credentials', () {
      test('throws LoginDataSourceError.invalidCredentials', () async {
        expect(
          dataSource.login('unknown', 'wrongpassword'),
          throwsA(LoginDataSourceError.invalidCredentials),
        );
      });

      test('throws on empty credentials', () async {
        expect(
          dataSource.login('', ''),
          throwsA(LoginDataSourceError.invalidCredentials),
        );
      });

      test('throws when username is correct but password is wrong', () async {
        expect(
          dataSource.login('teacher', 'wrongpassword'),
          throwsA(LoginDataSourceError.invalidCredentials),
        );
      });
    });
  });
}
