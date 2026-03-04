import 'package:auth/src/features/login/domain/login_use_case.dart';
import 'package:auth/src/features/login/presentation/controller/login_state.dart';
import 'package:bloc/bloc.dart';

class LoginBloc extends Cubit<LoginState> {
  final LoginUseCase _loginUseCase;

  LoginBloc(this._loginUseCase) : super(LoginInitialState());

  Future<void> login(String username, String password) async {
    emit(LoginLoadingState(username, password));

    try {
      final loginType = await _loginUseCase.login(username, password);
      emit(LoginDoneState(loginType));
    } catch (e) {
      switch (e) {
        case LoginUseCaseError.invalidCredentials:
          emit(
            LoginErrorState(username, password, 'login.invalid.credentials'),
          );
          break;
        default:
          emit(LoginErrorState(username, password, 'login.unknown.error'));
      }
    }
  }
}
