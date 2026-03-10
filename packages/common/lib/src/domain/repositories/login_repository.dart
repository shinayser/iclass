import 'package:auth/src/features/login/data/login_data_source.dart';
import 'package:common/src/domain/entities/login_type.dart';
import 'package:common/common.dart';
import 'package:dartx/dartx.dart';

enum LoginRepositoryError { invalidCredentials, unknownError }

abstract interface class LoginRepository {
  Future<LoginType> login(String username, String password);

  Future<LoginType?> currentLoginType();

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
  Future<LoginType?> currentLoginType() async {
    final loginTypeString = await _localDatabase.getData(kLoginType);
    return LoginType.values.firstOrNullWhere((e) => e.name == loginTypeString);
  }

  @override
  Future<void> logout() async {
    await _localDatabase.clear();
  }
}
