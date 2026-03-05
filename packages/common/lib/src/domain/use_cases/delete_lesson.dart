import 'package:common/common.dart';

class DeleteLesson {
  final LessonsRepository _repository;

  DeleteLesson(this._repository);

  Future<void> execute(String id) {
    return _repository.deleteLesson(id);
  }
}
