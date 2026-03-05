import 'package:equatable/equatable.dart';
import 'package:teacher/src/features/create_lesson/data/model/exercise_form_data.dart';

abstract class CreateLessonState with EquatableMixin {}

class CreateLessonFormState extends CreateLessonState with EquatableMixin {
  final List<ExerciseFormData> exercises;

  CreateLessonFormState({this.exercises = const []});

  @override
  List<Object?> get props => [exercises];
}

class CreateLessonErrorState extends CreateLessonState with EquatableMixin {
  final List<ExerciseFormData> exercises;
  final String errorMessage;

  CreateLessonErrorState({
    required this.exercises,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [exercises, errorMessage];
}

class CreateLessonDoneState extends CreateLessonState with EquatableMixin {
  @override
  List<Object?> get props => [];
}
