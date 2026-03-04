import 'package:auth/src/features/login/data/login_data_source.dart';
import 'package:auth/src/features/login/data/login_type.dart';
import 'package:common/common.dart';

enum LoginRepositoryError { invalidCredentials, unknownError }

abstract interface class LoginRepository {
  Future<LoginType> login(String username, String password);

  Future<bool> isLoggedIn();

  Future<void> logout();
}

class LoginRepositoryImpl implements LoginRepository {
  final LoginDataSource _dataSource;
  final LocalDatabase _localDatabase;

  LoginRepositoryImpl(this._dataSource, this._localDatabase);

  @override
  Future<LoginType> login(String username, String password) {
    try {
      return _dataSource.login(username, password);
    } catch (e) {
      switch (e) {
        case LoginDataSourceError.invalidCredentials:
          throw LoginRepositoryError.invalidCredentials;
        default:
          throw LoginRepositoryError.unknownError;
      }
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    return true;
  }

  @override
  Future<void> logout() {
    return Future.delayed(const Duration(seconds: 1));
  }
}
