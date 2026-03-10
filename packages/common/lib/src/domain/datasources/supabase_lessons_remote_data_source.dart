import 'package:common/common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Simulates a remote server in memory with artificial network latency.
class SupabaseRemoteLessonsDataSource implements RemoteLessonsDataSource {
  final SupabaseClient _supabase;

  SupabaseRemoteLessonsDataSource(this._supabase);

  @override
  Future<List<Lesson>> fetchLessons() async {
    final result = await _supabase.from('lessons').select('*, exercises(*)');
    return result.map(Lesson.fromJson).toList();
  }

  @override
  Future<int> saveLesson(Lesson lesson) async {
    final lessons = await _supabase
        .from('lessons')
        .upsert({
          if (lesson.id != 0) 'id': lesson.id,
          'name': lesson.name,
          'description': lesson.description,
          'answered': lesson.answered,
          'image_url': lesson.imageUrl,
        })
        .select('id');

    final returnedLessonId = lessons.first['id'] as int;

    await _supabase
        .from('exercises')
        .upsert(
          lesson.exercises.map((e) {
            return {
              if (e.id != 0) 'id': e.id,
              'title': e.title,
              'correct_answer': e.correctAnswer,
              'wrong_answers': e.wrongAnswers,
              'lesson_id': returnedLessonId,
            };
          }).toList(),
        );

    return returnedLessonId;
  }

  @override
  Future<void> deleteLesson(int id) async {
    await _supabase.from('lessons').delete().eq('id', id);
  }
}
