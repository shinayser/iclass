import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:student/src/features/answer_lesson/presentation/controller/answer_lesson_bloc.dart';
import 'package:student/src/features/answer_lesson/presentation/domain/update_lesson.dart';
import 'package:student/src/features/answer_lesson/presentation/page/answer_lesson_page.dart';
import 'package:student/src/features/home/presentation/controller/student_home_bloc.dart';
import 'package:student/src/features/home/presentation/page/student_home_page.dart';

class StudentModule extends Module with RoutedModule {
  static const answerLessonRoute = '/student/lesson/answer';

  @override
  Future<void> init() async {
    _initUsecases();
    _initBlocs();
  }

  void _initUsecases() {
    Injection.registerFactory(
      () => UpdateLesson(Injection.get<LessonsRepository>()),
    );
  }

  void _initBlocs() {
    Injection.registerFactory(
      () => StudentHomeBloc(
        Injection.get<FetchLessons>(),
        Injection.get<LogoutUseCase>(),
      ),
    );

    //AnswerLessonBloc
    Injection.registerFactory(
      () => AnswerLessonBloc(Injection.get<UpdateLesson>()),
    );
  }

  @override
  Map<String, WidgetBuilder> get routes => {
    CommonRoutes.studentHome: (context) => const StudentHomePage(),
    answerLessonRoute: (context) {
      final lesson = ModalRoute.of(context)!.settings.arguments as Lesson;
      return AnswerLessonPage(lesson: lesson);
    },
  };
}
