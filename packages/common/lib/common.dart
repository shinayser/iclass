import 'package:common/src/utils/injection.dart';
import 'package:common/src/utils/local_database.dart';
import 'package:common/src/utils/module.dart';

export 'package:common/src/utils/injection.dart';
export 'package:common/src/utils/local_database.dart';
export 'package:common/src/utils/module.dart';

class CommonModule implements Module {
  @override
  Future<void> init() async {
    final preferencesLocalDatabase = PreferencesLocalDatabase();
    await preferencesLocalDatabase.init();

    Injection.registerLazySingleton<LocalDatabase>(
      () => preferencesLocalDatabase,
    );
  }
}
