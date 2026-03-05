import 'package:common/src/domain/entities/login_type.dart';
import 'package:common/src/domain/repositories/login_repository.dart';

class LogoutUseCase {
  final LoginRepository _repository;

  LogoutUseCase(this._repository);

  Future<void> logout(String username, String password) async =>
      _repository.logout();
}
