import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:teacher/src/features/create_lesson/domain/use_case/persist_lesson.dart';
import 'package:teacher/src/features/create_lesson/presentation/controller/create_lesson_state.dart';
import 'package:teacher/src/features/create_lesson/data/model/exercise_form_data.dart';

class CreateLessonBloc extends Cubit<CreateLessonState> {
  final PersistLesson _persistLesson;

  CreateLessonBloc(this._persistLesson) : super(CreateLessonFormState());

  void addExercise(ExerciseFormData exercise) {
    final exercises = _currentExercises;
    emit(CreateLessonFormState(exercises: [...exercises, exercise]));
  }

  void removeExercise(int index) {
    final exercises = List<ExerciseFormData>.from(_currentExercises)
      ..removeAt(index);
    emit(CreateLessonFormState(exercises: exercises));
  }

  void conclude(String title, String description) async {
    final exercises = _currentExercises;

    if (title.trim().isEmpty) {
      emit(
        CreateLessonErrorState(
          exercises: exercises,
          errorMessage: 'Informe o título',
        ),
      );
      return;
    }

    if (exercises.isEmpty) {
      emit(
        CreateLessonErrorState(
          exercises: exercises,
          errorMessage: 'Adicione pelo menos um exercício',
        ),
      );
      return;
    }

    await _persistLesson.execute(_buildLesson(title, description));

    emit(CreateLessonDoneState());
  }

  Lesson _buildLesson(String title, String description) {
    final exercises = _currentExercises.map(
      (e) {
        final correctAnswer = e.alternatives[e.correctIndex];
        final wrongAnswers = List<String>.from(e.alternatives)
          ..removeAt(e.correctIndex);

        return ExerciseEntity(
          title: e.question,
          wrongAnswers: wrongAnswers,
          correctAnswer: correctAnswer,
        );
      },
    ).toList();

    return Lesson(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: title,
      description: description,
      exercises: exercises,
    );
  }

  List<ExerciseFormData> get _currentExercises {
    final s = state;
    return switch (s) {
      CreateLessonFormState() => s.exercises,
      CreateLessonErrorState() => s.exercises,
      _ => [],
    };
  }
}
