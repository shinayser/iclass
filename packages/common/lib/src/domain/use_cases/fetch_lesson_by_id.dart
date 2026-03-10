import 'package:common/common.dart';

class FetchLessonById {
  final LessonsRepository _repository;

  FetchLessonById(this._repository);

  Future<Lesson> execute(int id) {
    return _repository.fetchLessonById(id);
  }
}
