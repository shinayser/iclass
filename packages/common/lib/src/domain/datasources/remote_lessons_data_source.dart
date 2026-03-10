import 'package:common/common.dart';

abstract interface class RemoteLessonsDataSource {
  Future<List<Lesson>> fetchLessons();

  Future<void> saveLesson(Lesson lesson);

  Future<void> deleteLesson(int id);
}

/// Simulates a remote server in memory with artificial network latency.
class FakeRemoteLessonsDataSource implements RemoteLessonsDataSource {
  final List<Lesson> _lessons = [];

  static const _simulatedDelay = Duration(milliseconds: 1500);

  @override
  Future<List<Lesson>> fetchLessons() {
    return Future.delayed(_simulatedDelay, () => List.unmodifiable(_lessons));
  }

  @override
  Future<void> saveLesson(Lesson lesson) {
    return Future.delayed(_simulatedDelay, () {
      _lessons.removeWhere((l) => l.id == lesson.id);
      _lessons.add(lesson);
    });
  }

  @override
  Future<void> deleteLesson(int id) {
    return Future.delayed(_simulatedDelay, () {
      _lessons.removeWhere((l) => l.id == id);
    });
  }
}
