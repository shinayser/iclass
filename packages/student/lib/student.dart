import 'package:common/common.dart';
import 'package:go_router/go_router.dart';
import 'package:student/src/features/answer_lesson/presentation/controller/answer_lesson_bloc.dart';
import 'package:student/src/features/answer_lesson/presentation/domain/update_lesson.dart';
import 'package:student/src/features/answer_lesson/presentation/page/answer_lesson_page.dart';
import 'package:student/src/features/home/presentation/controller/student_home_bloc.dart';
import 'package:student/src/features/home/presentation/page/student_home_page.dart';

class StudentModule extends Module with RoutedModule {
  static const answerLessonRoute = '/student/home/lesson/:lessonId/answer';

  @override
  Future<void> init() async {
    _initUsecases();
    _initBlocs();
  }

  void _initUsecases() {
    Injection.registerFactory(
      () => UpdateLesson(Injection.get<LessonsRepository>()),
    );
    Injection.registerFactory(
      () => FetchLessonById(Injection.get<LessonsRepository>()),
    );
  }

  void _initBlocs() {
    Injection.registerFactory(
      () => StudentHomeBloc(
        Injection.get<FetchLessons>(),
        Injection.get<LogoutUseCase>(),
        Injection.get<SyncService>(),
      ),
    );

    Injection.registerFactory(
      () => AnswerLessonBloc(
        Injection.get<UpdateLesson>(),
        Injection.get<FetchLessonById>(),
      ),
    );
  }

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: CommonRoutes.studentHome,
      builder: (_, __) => const StudentHomePage(),
      routes: [
        GoRoute(
          path: 'lesson/:lessonId/answer',
          builder: (_, state) {
            final lessonId = int.parse(state.pathParameters['lessonId']!);
            return AnswerLessonPage(lessonId: lessonId);
          },
        ),
      ],
    ),
  ];
}
