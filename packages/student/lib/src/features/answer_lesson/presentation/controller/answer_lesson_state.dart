import 'package:common/common.dart';
import 'package:equatable/equatable.dart';

abstract class AnswerLessonState with EquatableMixin {}

class AnswerLessonInitialState extends AnswerLessonState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class AnswerLessonLoadingState extends AnswerLessonState with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class AnswerLessonFormState extends AnswerLessonState with EquatableMixin {
  final Lesson lesson;
  final Map<int, String> selectedAnswers;

  AnswerLessonFormState({
    required this.lesson,
    this.selectedAnswers = const {},
  });

  @override
  List<Object?> get props => [lesson, selectedAnswers];
}

class AnswerLessonErrorState extends AnswerLessonState with EquatableMixin {
  final Lesson lesson;
  final Map<int, String> selectedAnswers;
  final String errorMessage;

  AnswerLessonErrorState({
    required this.lesson,
    required this.selectedAnswers,
    required this.errorMessage,
  });

  @override
  List<Object?> get props => [lesson, selectedAnswers, errorMessage];
}

class AnswerLessonDoneState extends AnswerLessonState with EquatableMixin {
  @override
  List<Object?> get props => [];
}
