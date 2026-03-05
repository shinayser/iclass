import 'package:equatable/equatable.dart';
import 'package:teacher/src/features/create_lesson/data/model/exercise_form_data.dart';

abstract class AddExerciseState with EquatableMixin {}

class AddExerciseFormState extends AddExerciseState with EquatableMixin {
  final int alternativeCount;
  final int? correctIndex;

  AddExerciseFormState({required this.alternativeCount, this.correctIndex});

  @override
  List<Object?> get props => [alternativeCount, correctIndex];
}

class AddExerciseErrorState extends AddExerciseState with EquatableMixin {
  final int alternativeCount;
  final int? correctIndex;
  final String errorMessage;

  AddExerciseErrorState({
    required this.alternativeCount,
    this.correctIndex,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [alternativeCount, correctIndex, errorMessage];
}

class AddExerciseDoneState extends AddExerciseState with EquatableMixin {
  final ExerciseFormData form;

  AddExerciseDoneState(this.form);

  @override
  List<Object?> get props => [form];
}
