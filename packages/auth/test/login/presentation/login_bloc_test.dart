import 'package:auth/src/features/login/domain/login_use_case.dart';
import 'package:auth/src/features/login/presentation/controller/login_bloc.dart';
import 'package:auth/src/features/login/presentation/controller/login_state.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:common/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  late _MockLoginUseCase mockUseCase;

  setUp(() => mockUseCase = _MockLoginUseCase());

  group('LoginBloc', () {
    test('initial state is LoginInitialState', () {
      expect(LoginBloc(mockUseCase).state, isA<LoginInitialState>());
    });

    blocTest<LoginBloc, LoginState>(
      'emits [Loading, Done] on successful login as teacher',
      build: () {
        when(() => mockUseCase.login(any(), any()))
            .thenAnswer((_) async => LoginType.teacher);
        return LoginBloc(mockUseCase);
      },
      act: (bloc) => bloc.login('teacher', 'teacher123'),
      expect: () => [
        isA<LoginLoadingState>()
            .having((s) => s.login, 'login', 'teacher')
            .having((s) => s.password, 'password', 'teacher123'),
        isA<LoginDoneState>()
            .having((s) => s.loginType, 'loginType', LoginType.teacher),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [Loading, Done] on successful login as student',
      build: () {
        when(() => mockUseCase.login(any(), any()))
            .thenAnswer((_) async => LoginType.student);
        return LoginBloc(mockUseCase);
      },
      act: (bloc) => bloc.login('student', 'student123'),
      expect: () => [
        isA<LoginLoadingState>(),
        isA<LoginDoneState>()
            .having((s) => s.loginType, 'loginType', LoginType.student),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [Loading, Error] with invalid-credentials message',
      build: () {
        when(() => mockUseCase.login(any(), any()))
            .thenThrow(LoginUseCaseError.invalidCredentials);
        return LoginBloc(mockUseCase);
      },
      act: (bloc) => bloc.login('bad', 'creds'),
      expect: () => [
        isA<LoginLoadingState>(),
        isA<LoginErrorState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'login.invalid.credentials',
        ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [Loading, Error] with unknown-error message on unexpected failure',
      build: () {
        when(() => mockUseCase.login(any(), any()))
            .thenThrow(LoginUseCaseError.unknownError);
        return LoginBloc(mockUseCase);
      },
      act: (bloc) => bloc.login('x', 'y'),
      expect: () => [
        isA<LoginLoadingState>(),
        isA<LoginErrorState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'login.unknown.error',
        ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'error state preserves username and password',
      build: () {
        when(() => mockUseCase.login(any(), any()))
            .thenThrow(LoginUseCaseError.invalidCredentials);
        return LoginBloc(mockUseCase);
      },
      act: (bloc) => bloc.login('myuser', 'mypass'),
      expect: () => [
        isA<LoginLoadingState>(),
        isA<LoginErrorState>()
            .having((s) => s.login, 'login', 'myuser')
            .having((s) => s.password, 'password', 'mypass'),
      ],
    );
  });
}
