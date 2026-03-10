import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:common/common.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:teacher/src/features/create_lesson/domain/use_case/persist_lesson.dart';
import 'package:teacher/src/features/create_lesson/presentation/controller/create_lesson_state.dart';
import 'package:teacher/src/features/create_lesson/data/model/exercise_form_data.dart';

class CreateLessonBloc extends Cubit<CreateLessonState> {
  final PersistLesson _persistLesson;
  final ImagePicker _imagePicker;

  CreateLessonBloc(this._persistLesson, {ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker(),
        super(CreateLessonFormState());

  void addExercise(ExerciseFormData exercise) {
    final exercises = _currentExercises;
    emit(CreateLessonFormState(
      exercises: [...exercises, exercise],
      imagePath: _currentImagePath,
    ));
  }

  void removeExercise(int index) {
    final exercises = List<ExerciseFormData>.from(_currentExercises)
      ..removeAt(index);
    emit(CreateLessonFormState(
      exercises: exercises,
      imagePath: _currentImagePath,
    ));
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );
    if (picked == null) return;

    // Copy to persistent directory so the file survives cache cleaning.
    final appDir = await getApplicationDocumentsDirectory();
    final extension = picked.path.split('.').last;
    final fileName =
        'lesson_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final savedFile = await File(picked.path).copy('${appDir.path}/$fileName');

    emit(CreateLessonFormState(
      exercises: _currentExercises,
      imagePath: savedFile.path,
    ));
  }

  void removeImage() {
    emit(CreateLessonFormState(
      exercises: _currentExercises,
      imagePath: null,
    ));
  }

  Future<void> conclude(String title, String description) async {
    final exercises = _currentExercises;
    final imagePath = _currentImagePath;

    if (title.trim().isEmpty) {
      emit(
        CreateLessonErrorState(
          exercises: exercises,
          errorMessage: 'Informe o título',
          imagePath: imagePath,
        ),
      );
      return;
    }

    if (exercises.isEmpty) {
      emit(
        CreateLessonErrorState(
          exercises: exercises,
          errorMessage: 'Adicione pelo menos um exercício',
          imagePath: imagePath,
        ),
      );
      return;
    }

    await _persistLesson.execute(
      _buildLesson(title, description, imagePath),
    );

    emit(CreateLessonDoneState());
  }

  Lesson _buildLesson(
    String title,
    String description,
    String? localImagePath,
  ) {
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
      name: title,
      description: description,
      exercises: exercises,
      localImagePath: localImagePath,
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

  String? get _currentImagePath {
    final s = state;
    return switch (s) {
      CreateLessonFormState() => s.imagePath,
      CreateLessonErrorState() => s.imagePath,
      _ => null,
    };
  }
}
