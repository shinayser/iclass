import 'package:auth/src/features/login/data/login_data_source.dart';
import 'package:common/src/domain/entities/login_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final mockedLoginDataSource = MockedLoginDataSource();

  test('should return a LoginType.teacher', () async {
    final loginType = await mockedLoginDataSource.login(
      'teacher',
      'teacher123',
    );
    expect(loginType, LoginType.teacher);
  });

  test('should return a LoginType.student', () async {
    final loginType = await mockedLoginDataSource.login(
      'student',
      'student123',
    );
    expect(loginType, LoginType.student);
  });
}
