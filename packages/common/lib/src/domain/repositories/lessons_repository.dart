import 'dart:convert';

import 'package:common/common.dart';

abstract interface class LessonsRepository {
  Future<List<Lesson>> fetchLessons();

  Future<void> saveLesson(Lesson lesson);
}

class LocalLessonsRepository implements LessonsRepository {
  static const kLessonsList = 'lessons_list';
  final LocalDatabase _database;

  LocalLessonsRepository(this._database);

  @override
  Future<List<Lesson>> fetchLessons() {
    return _database.getData(kLessonsList).then((jsonString) {
      if (jsonString != null) {
        final decodedJson = jsonDecode(jsonString) as List<dynamic>;
        return decodedJson.map((json) => Lesson.fromJson(json)).toList();
      } else {
        return [];
      }
    });
  }

  @override
  Future<void> saveLesson(Lesson lesson) async {
    final lessons = await fetchLessons();
    lessons.add(lesson);
    final encodedJson = jsonEncode(lessons.map((e) => e.toJson()).toList());
    return _database.saveData(kLessonsList, encodedJson);
  }
}
