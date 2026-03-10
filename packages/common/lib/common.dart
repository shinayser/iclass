import 'package:common/src/core/connectivity_service.dart';
import 'package:common/src/core/injection.dart';
import 'package:common/src/core/local_database.dart';
import 'package:common/src/core/module.dart';
import 'package:common/src/core/sync_service.dart';
import 'package:common/src/domain/datasources/remote_lessons_data_source.dart';
import 'package:common/src/domain/datasources/supabase_lessons_remote_data_source.dart';
import 'package:common/src/domain/repositories/lessons_repository.dart';
import 'package:common/src/domain/repositories/login_repository.dart';
import 'package:common/src/domain/use_cases/logout_use_case.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
export 'package:common/src/domain/use_cases/fetch_lesson_by_id.dart';
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

    Injection.registerFactory<LogoutUseCase>(
      () => LogoutUseCase(Injection.get<LoginRepository>()),
    );

    Injection.registerLazySingleton<RemoteLessonsDataSource>(
      () => SupabaseRemoteLessonsDataSource(Supabase.instance.client),
    );

    final connectivityService = ConnectivityPlusService();
    Injection.registerLazySingleton<ConnectivityService>(
      () => connectivityService,
    );

    Injection.registerLazySingleton<LessonsRepository>(
      () => SyncAwareLessonsRepository(
        preferencesLocalDatabase,
        Injection.get<RemoteLessonsDataSource>(),
        connectivityService,
      ),
    );

    Injection.registerLazySingletonAsync<SyncService>(
      () async {
        var syncServiceImpl = SyncServiceImpl(
          Injection.get(),
          connectivityService,
        );
        await syncServiceImpl.init();
        return syncServiceImpl;
      },
    );

    await Injection.getAsync<SyncService>();
  }
}
