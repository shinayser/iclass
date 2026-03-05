import 'package:common/common.dart';

class FetchLessons {
  final LessonsRepository _repository;

  FetchLessons(this._repository);

  Future<List<Lesson>> execute() {
    return _repository.fetchLessons();
  }
}
