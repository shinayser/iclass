import 'package:bloc/bloc.dart';
import 'package:teacher/src/features/create_lesson/data/model/exercise_form_data.dart';
import 'package:teacher/src/features/create_lesson/presentation/controller/add_exercise_state.dart';

class AddExerciseBloc extends Cubit<AddExerciseState> {
  AddExerciseBloc() : super(AddExerciseFormState(alternativeCount: 3));

  void addAlternative() {
    final current = _currentFormData;
    if (current.alternativeCount >= 5) return;

    emit(
      AddExerciseFormState(
        alternativeCount: current.alternativeCount + 1,
        correctIndex: current.correctIndex,
      ),
    );
  }

  void removeAlternative(int index) {
    final current = _currentFormData;
    if (current.alternativeCount <= 3) return;

    int? newCorrectIndex = current.correctIndex;
    if (newCorrectIndex == index) {
      newCorrectIndex = null;
    } else if (newCorrectIndex != null && newCorrectIndex > index) {
      newCorrectIndex = newCorrectIndex - 1;
    }

    emit(
      AddExerciseFormState(
        alternativeCount: current.alternativeCount - 1,
        correctIndex: newCorrectIndex,
      ),
    );
  }

  void selectCorrectAnswer(int index) {
    final current = _currentFormData;
    emit(
      AddExerciseFormState(
        alternativeCount: current.alternativeCount,
        correctIndex: index,
      ),
    );
  }

  void save(String question, List<String> alternatives) {
    final current = _currentFormData;

    if (question.trim().isEmpty) {
      emit(
        AddExerciseErrorState(
          alternativeCount: current.alternativeCount,
          correctIndex: current.correctIndex,
          errorMessage: 'Informe a questão',
        ),
      );
      return;
    }

    if (alternatives.any((a) => a.trim().isEmpty)) {
      emit(
        AddExerciseErrorState(
          alternativeCount: current.alternativeCount,
          correctIndex: current.correctIndex,
          errorMessage: 'Preencha todas as alternativas',
        ),
      );
      return;
    }

    if (current.correctIndex == null) {
      emit(
        AddExerciseErrorState(
          alternativeCount: current.alternativeCount,
          correctIndex: current.correctIndex,
          errorMessage: 'Selecione a alternativa correta',
        ),
      );
      return;
    }

    emit(
      AddExerciseDoneState(
        ExerciseFormData(
          question: question.trim(),
          alternatives: alternatives.map((a) => a.trim()).toList(),
          correctIndex: current.correctIndex!,
        ),
      ),
    );
  }

  ({int alternativeCount, int? correctIndex}) get _currentFormData {
    final currentState = state;
    return switch (currentState) {
      AddExerciseFormState() => (
        alternativeCount: currentState.alternativeCount,
        correctIndex: currentState.correctIndex,
      ),
      AddExerciseErrorState() => (
        alternativeCount: currentState.alternativeCount,
        correctIndex: currentState.correctIndex,
      ),
      _ => (alternativeCount: 3, correctIndex: null),
    };
  }
}
