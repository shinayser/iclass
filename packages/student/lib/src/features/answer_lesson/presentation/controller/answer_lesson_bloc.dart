import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:student/src/features/answer_lesson/presentation/controller/answer_lesson_state.dart';
import 'package:student/src/features/answer_lesson/presentation/domain/update_lesson.dart';

class AnswerLessonBloc extends Cubit<AnswerLessonState> {
  final UpdateLesson _updateLesson;

  AnswerLessonBloc(this._updateLesson) : super(AnswerLessonInitialState());

  void init(Lesson lesson) {
    emit(
      AnswerLessonFormState(
        lesson: lesson,
        selectedAnswers: {},
      ),
    );
  }

  void selectAnswer(int exerciseIndex, String answer) {
    final current = _currentFormData;
    final updatedAnswers = Map<int, String>.from(current.selectedAnswers)
      ..[exerciseIndex] = answer;

    emit(
      AnswerLessonFormState(
        lesson: current.lesson,
        selectedAnswers: updatedAnswers,
      ),
    );
  }

  Future<void> conclude() async {
    final current = _currentFormData;
    final totalExercises = current.lesson.exercises.length;

    if (current.selectedAnswers.length < totalExercises) {
      emit(
        AnswerLessonErrorState(
          lesson: current.lesson,
          selectedAnswers: current.selectedAnswers,
          errorMessage: 'Responda todos os exercícios antes de concluir',
        ),
      );
      return;
    }

    await _updateLesson.execute(_buildLesson(current.lesson));

    emit(AnswerLessonDoneState());
  }

  ({Lesson lesson, Map<int, String> selectedAnswers}) get _currentFormData {
    final s = state;
    return switch (s) {
      AnswerLessonFormState() => (
        lesson: s.lesson,
        selectedAnswers: s.selectedAnswers,
      ),
      AnswerLessonErrorState() => (
        lesson: s.lesson,
        selectedAnswers: s.selectedAnswers,
      ),
      _ => throw StateError('Invalid state'),
    };
  }

  Lesson _buildLesson(Lesson lesson) {
    final exercises = lesson.exercises.asMap().entries.map(
      (entry) {
        final exercise = entry.value;

        return ExerciseEntity(
          title: exercise.title,
          correctAnswer: exercise.correctAnswer,
          wrongAnswers: exercise.wrongAnswers,
        );
      },
    ).toList();

    return Lesson(
      id: lesson.id,
      name: lesson.name,
      description: lesson.description,
      exercises: exercises,
      answered: true,
    );
  }
}
