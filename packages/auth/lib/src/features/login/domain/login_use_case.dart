import 'package:auth/src/features/login/data/login_type.dart';
import 'package:auth/src/features/login/domain/login_repository.dart';

enum LoginUseCaseError { invalidCredentials, unknownError }

class LoginUseCase {
  final LoginRepository _repository;

  LoginUseCase(this._repository);

  Future<LoginType> login(String username, String password) async {
    try {
      final loginType = await _repository.login(username, password);
      return loginType;
    } catch (e) {
      switch (e) {
        case LoginRepositoryError.invalidCredentials:
          throw LoginUseCaseError.invalidCredentials;
        default:
          throw LoginUseCaseError.unknownError;
      }
    }
  }
}
