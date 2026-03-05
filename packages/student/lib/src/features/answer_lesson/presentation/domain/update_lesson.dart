import 'package:common/common.dart';

class UpdateLesson {
  final LessonsRepository repository;

  UpdateLesson(this.repository);

  Future<void> execute(Lesson lesson) async {
    await repository.saveLesson(lesson);
  }
}
