import 'package:auth/src/features/login/data/login_data_source.dart';
import 'package:common/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoginDataSource extends Mock implements LoginDataSource {}

/// Minimal in-memory [LocalDatabase] for use in auth package tests.
class _FakeLocalDatabase implements LocalDatabase {
  final _store = <String, String>{};

  @override
  Future<void> saveData(String key, String value) async => _store[key] = value;

  @override
  Future<String?> getData(String key) async => _store[key];

  @override
  Future<void> deleteData(String key) async => _store.remove(key);
}

void main() {
  late _MockLoginDataSource mockDataSource;
  late _FakeLocalDatabase fakeDb;
  late LoginRepositoryImpl repository;

  setUp(() {
    mockDataSource = _MockLoginDataSource();
    fakeDb = _FakeLocalDatabase();
    repository = LoginRepositoryImpl(mockDataSource, fakeDb);
  });

  group('LoginRepositoryImpl', () {
    group('login', () {
      test('returns LoginType and persists it locally on success', () async {
        when(() => mockDataSource.login(any(), any()))
            .thenAnswer((_) async => LoginType.teacher);

        final result = await repository.login('teacher', 'teacher123');

        expect(result, LoginType.teacher);
        expect(await repository.isLoggedIn(), isTrue);
      });

      test('throws LoginRepositoryError.invalidCredentials on bad credentials',
          () async {
        when(() => mockDataSource.login(any(), any()))
            .thenThrow(LoginDataSourceError.invalidCredentials);

        expect(
          () => repository.login('bad', 'creds'),
          throwsA(LoginRepositoryError.invalidCredentials),
        );
      });

      test('throws LoginRepositoryError.unknownError on unexpected error',
          () async {
        when(() => mockDataSource.login(any(), any()))
            .thenThrow(Exception('unexpected'));

        expect(
          () => repository.login('x', 'y'),
          throwsA(LoginRepositoryError.unknownError),
        );
      });
    });

    group('isLoggedIn', () {
      test('returns false when no session exists', () async {
        expect(await repository.isLoggedIn(), isFalse);
      });

      test('returns true after a successful login', () async {
        when(() => mockDataSource.login(any(), any()))
            .thenAnswer((_) async => LoginType.student);
        await repository.login('student', 'student123');

        expect(await repository.isLoggedIn(), isTrue);
      });
    });

    group('logout', () {
      test('removes session so isLoggedIn returns false', () async {
        when(() => mockDataSource.login(any(), any()))
            .thenAnswer((_) async => LoginType.teacher);
        await repository.login('teacher', 'teacher123');

        await repository.logout();

        expect(await repository.isLoggedIn(), isFalse);
      });
    });
  });
}
