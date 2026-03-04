import 'package:auth/src/features/login/data/login_data_source.dart';
import 'package:auth/src/features/login/domain/login_repository.dart';
import 'package:auth/src/features/login/domain/login_use_case.dart';
import 'package:auth/src/features/login/presentation/controller/login_bloc.dart';
import 'package:common/common.dart';

export 'package:auth/src/features/login/presentation/page/login_page.dart';

class AuthModule implements Module {
  @override
  Future<void> init() async {
    await _initDataSources();
    await _initRepositories();
    await _initUseCases();
    await _initBlocs();
  }

  Future _initDataSources() async {
    Injection.registerLazySingleton<LoginDataSource>(
      () => MockedLoginDataSource(),
    );
  }

  Future _initRepositories() async {
    Injection.registerLazySingleton<LoginRepository>(
      () => LoginRepositoryImpl(
        Injection.get<LoginDataSource>(),
        Injection.get<LocalDatabase>(),
      ),
    );
  }

  Future _initUseCases() async {
    Injection.registerFactory<LoginUseCase>(
      () => LoginUseCase(Injection.get<LoginRepository>()),
    );
  }

  Future _initBlocs() async {
    Injection.registerFactory<LoginBloc>(
      () => LoginBloc(Injection.get<LoginUseCase>()),
    );
  }
}
