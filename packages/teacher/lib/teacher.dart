import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:teacher/src/features/create_lesson/domain/use_case/persist_lesson.dart';
import 'package:teacher/src/features/create_lesson/presentation/controller/create_lesson_bloc.dart';
import 'package:teacher/src/features/create_lesson/presentation/page/add_exercise_page.dart';
import 'package:teacher/src/features/create_lesson/presentation/page/create_lesson_page.dart';
import 'package:teacher/src/features/home/presentation/controller/home_bloc.dart';
import 'package:teacher/src/features/home/presentation/page/home_page.dart';

import 'src/features/create_lesson/presentation/controller/add_exercise_bloc.dart';

class TeacherModule extends Module with RoutedModule {
  static final createLessonRoute = "/teacher/lesson/create";
  static final addExerciseRoute = "/teacher/exercise/add";

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
      () => HomeBloc(Injection.get<FetchLessons>()),
    );
  }

  void _initUseCases() {
    Injection.registerFactory(
      () => PersistLesson(Injection.get<LessonsRepository>()),
    );
    Injection.registerFactory(
      () => FetchLessons(Injection.get<LessonsRepository>()),
    );
  }

  @override
  Map<String, WidgetBuilder> get routes => {
    CommonRoutes.teacherHome: (context) => const HomePage(),
    createLessonRoute: (context) => const CreateLessonPage(),
    addExerciseRoute: (context) => const AddExercisePage(),
  };
}
