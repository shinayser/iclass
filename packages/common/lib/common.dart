import 'package:common/src/core/connectivity_service.dart';
import 'package:common/src/core/injection.dart';
import 'package:common/src/core/local_database.dart';
import 'package:common/src/core/module.dart';
import 'package:common/src/core/sync_service.dart';
import 'package:common/src/domain/datasources/remote_lessons_data_source.dart';
import 'package:common/src/domain/repositories/lessons_repository.dart';
import 'package:common/src/domain/repositories/login_repository.dart';
import 'package:common/src/domain/use_cases/logout_use_case.dart';

export 'package:common/src/core/common_routes.dart';
export 'package:common/src/core/connectivity_service.dart';
export 'package:common/src/core/injection.dart';
export 'package:common/src/core/local_database.dart';
export 'package:common/src/core/module.dart';
export 'package:common/src/core/sync_service.dart';
export 'package:common/src/domain/datasources/remote_lessons_data_source.dart';
export 'package:common/src/domain/entities/lesson.dart';
export 'package:common/src/domain/entities/login_type.dart';
export 'package:common/src/domain/entities/sync_status.dart';
export 'package:common/src/domain/repositories/lessons_repository.dart';
export 'package:common/src/domain/repositories/login_repository.dart';
export 'package:common/src/domain/use_cases/delete_lesson.dart';
export 'package:common/src/domain/use_cases/fetch_lessons.dart';
export 'package:common/src/domain/use_cases/logout_use_case.dart';

class CommonModule extends Module {
  @override
  Future<void> init() async {
    final preferencesLocalDatabase = PreferencesLocalDatabase();
    await preferencesLocalDatabase.init();

    Injection.registerLazySingleton<LocalDatabase>(
      () => preferencesLocalDatabase,
    );

    final remoteDataSource = FakeRemoteLessonsDataSource();
    Injection.registerLazySingleton<RemoteLessonsDataSource>(
      () => remoteDataSource,
    );

    final connectivityService = ConnectivityPlusService();
    Injection.registerLazySingleton<ConnectivityService>(
      () => connectivityService,
    );

    final lessonsRepository = SyncAwareLessonsRepository(
      preferencesLocalDatabase,
      remoteDataSource,
      connectivityService,
    );
    Injection.registerLazySingleton<LessonsRepository>(
      () => lessonsRepository,
    );

    final syncService = SyncServiceImpl(lessonsRepository, connectivityService);
    await syncService.init();
    Injection.registerLazySingleton<SyncService>(() => syncService);

    Injection.registerFactory<LogoutUseCase>(
      () => LogoutUseCase(Injection.get<LoginRepository>()),
    );
  }
}
