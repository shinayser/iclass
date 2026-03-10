import 'package:equatable/equatable.dart';
import 'package:teacher/src/features/create_lesson/data/model/exercise_form_data.dart';

abstract class CreateLessonState with EquatableMixin {}

class CreateLessonFormState extends CreateLessonState with EquatableMixin {
  final List<ExerciseFormData> exercises;
  final String? imagePath;

  CreateLessonFormState({this.exercises = const [], this.imagePath});

  @override
  List<Object?> get props => [exercises, imagePath];
}

class CreateLessonErrorState extends CreateLessonState with EquatableMixin {
  final List<ExerciseFormData> exercises;
  final String errorMessage;
  final String? imagePath;

  CreateLessonErrorState({
    required this.exercises,
    required this.errorMessage,
    this.imagePath,
  });

  @override
  List<Object?> get props => [exercises, errorMessage, imagePath];
}

class CreateLessonDoneState extends CreateLessonState with EquatableMixin {
  @override
  List<Object?> get props => [];
}
