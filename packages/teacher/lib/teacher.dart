import 'package:common/common.dart';
import 'package:go_router/go_router.dart';
import 'package:teacher/src/features/create_lesson/domain/use_case/persist_lesson.dart';
import 'package:teacher/src/features/create_lesson/presentation/controller/create_lesson_bloc.dart';
import 'package:teacher/src/features/create_lesson/presentation/page/add_exercise_page.dart';
import 'package:teacher/src/features/create_lesson/presentation/page/create_lesson_page.dart';
import 'package:teacher/src/features/home/presentation/controller/home_bloc.dart';
import 'package:teacher/src/features/home/presentation/page/teacher_home_page.dart';

import 'src/features/create_lesson/presentation/controller/add_exercise_bloc.dart';

class TeacherModule extends Module with RoutedModule {
  static const createLessonRoute = "/teacher/lesson/create";
  static const addExerciseRoute = "/teacher/exercise/add";

  @override
  Future<void> init() async {
    _initUseCases();
    _initBlocs();
  }

  void _initBlocs() {
    Injection.registerFactory(
      () => CreateLessonBloc(Injection.get<PersistLesson>()),
    );
    Injection.registerFactory(() => AddExerciseBloc());
    Injection.registerFactory(
      () => TeacherHomeBloc(
        Injection.get<FetchLessons>(),
        Injection.get<DeleteLesson>(),
        Injection.get<LogoutUseCase>(),
        Injection.get<SyncService>(),
      ),
    );
  }

  void _initUseCases() {
    Injection.registerFactory(
      () => PersistLesson(Injection.get<LessonsRepository>()),
    );
    Injection.registerFactory(
      () => FetchLessons(Injection.get<LessonsRepository>()),
    );
    Injection.registerFactory(
      () => DeleteLesson(Injection.get<LessonsRepository>()),
    );
  }

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: CommonRoutes.teacherHome,
      builder: (_, __) => const TeacherHomePage(),
    ),
    GoRoute(
      path: createLessonRoute,
      builder: (_, __) => const CreateLessonPage(),
    ),
    GoRoute(
      path: addExerciseRoute,
      builder: (_, __) => const AddExercisePage(),
    ),
  ];
}
