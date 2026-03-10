import 'package:auth/src/features/login/data/login_data_source.dart';
import 'package:common/src/domain/entities/login_type.dart';
import 'package:common/common.dart';

enum LoginRepositoryError { invalidCredentials, unknownError }

abstract interface class LoginRepository {
  Future<LoginType> login(String username, String password);

  Future<bool> isLoggedIn();

  Future<void> logout();
}

class LoginRepositoryImpl implements LoginRepository {
  static const kLoginType = 'login_type';

  final LoginDataSource _dataSource;
  final LocalDatabase _localDatabase;

  LoginRepositoryImpl(this._dataSource, this._localDatabase);

  @override
  Future<LoginType> login(String username, String password) async {
    try {
      final loginType = await _dataSource.login(username, password);

      await _localDatabase.saveData(kLoginType, loginType.name);

      return loginType;
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
    return await _localDatabase.getData(kLoginType) != null;
  }

  @override
  Future<void> logout() async {
    await _localDatabase.clear();
  }
}
