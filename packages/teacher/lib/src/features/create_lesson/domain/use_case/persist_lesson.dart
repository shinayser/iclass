import 'package:common/common.dart';

class PersistLesson {
  final LessonsRepository repository;

  PersistLesson(this.repository);

  Future<void> execute(Lesson lesson) async {
    await repository.saveLesson(lesson);
  }
}
