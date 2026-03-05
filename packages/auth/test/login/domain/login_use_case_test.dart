import 'package:auth/src/features/login/domain/login_use_case.dart';
import 'package:common/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoginRepository extends Mock implements LoginRepository {}

void main() {
  late _MockLoginRepository mockRepository;
  late LoginUseCase useCase;

  setUp(() {
    mockRepository = _MockLoginRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    test('returns the LoginType from the repository on success', () async {
      when(() => mockRepository.login(any(), any()))
          .thenAnswer((_) async => LoginType.teacher);

      final result = await useCase.login('teacher', 'teacher123');

      expect(result, LoginType.teacher);
    });

    test('maps LoginRepositoryError.invalidCredentials to UseCase error',
        () async {
      when(() => mockRepository.login(any(), any()))
          .thenThrow(LoginRepositoryError.invalidCredentials);

      expect(
        () => useCase.login('bad', 'creds'),
        throwsA(LoginUseCaseError.invalidCredentials),
      );
    });

    test('maps any other error to LoginUseCaseError.unknownError', () async {
      when(() => mockRepository.login(any(), any()))
          .thenThrow(Exception('unexpected'));

      expect(
        () => useCase.login('x', 'y'),
        throwsA(LoginUseCaseError.unknownError),
      );
    });
  });
}
