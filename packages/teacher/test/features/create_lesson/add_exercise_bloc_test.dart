import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teacher/src/features/create_lesson/presentation/controller/add_exercise_bloc.dart';
import 'package:teacher/src/features/create_lesson/presentation/controller/add_exercise_state.dart';

void main() {
  AddExerciseBloc _build() => AddExerciseBloc();

  group('AddExerciseBloc', () {
    test('initial state has alternativeCount=3 and no correctIndex', () {
      final state = _build().state as AddExerciseFormState;
      expect(state.alternativeCount, 3);
      expect(state.correctIndex, isNull);
    });

    // -----------------------------------------------------------------------
    // addAlternative
    // -----------------------------------------------------------------------

    blocTest<AddExerciseBloc, AddExerciseState>(
      'addAlternative increments alternativeCount',
      build: _build,
      act: (bloc) => bloc.addAlternative(),
      expect: () => [
        isA<AddExerciseFormState>().having(
          (s) => s.alternativeCount,
          'alternativeCount',
          4,
        ),
      ],
    );

    blocTest<AddExerciseBloc, AddExerciseState>(
      'addAlternative does not exceed 5',
      build: _build,
      act: (bloc) {
        bloc.addAlternative(); // 4
        bloc.addAlternative(); // 5
        bloc.addAlternative(); // no-op, stays at 5
      },
      expect: () => [
        isA<AddExerciseFormState>().having((s) => s.alternativeCount, 'count', 4),
        isA<AddExerciseFormState>().having((s) => s.alternativeCount, 'count', 5),
        // third call is a no-op, no new state emitted
      ],
    );

    // -----------------------------------------------------------------------
    // removeAlternative
    // -----------------------------------------------------------------------

    blocTest<AddExerciseBloc, AddExerciseState>(
      'removeAlternative decrements alternativeCount',
      build: _build,
      act: (bloc) {
        bloc.addAlternative(); // 4
        bloc.removeAlternative(3); // back to 3
      },
      expect: () => [
        isA<AddExerciseFormState>().having((s) => s.alternativeCount, 'count', 4),
        isA<AddExerciseFormState>().having((s) => s.alternativeCount, 'count', 3),
      ],
    );

    blocTest<AddExerciseBloc, AddExerciseState>(
      'removeAlternative does not go below 3',
      build: _build,
      act: (bloc) => bloc.removeAlternative(2), // already at 3 — no-op
      expect: () => [], // no state emitted
    );

    blocTest<AddExerciseBloc, AddExerciseState>(
      'removeAlternative clears correctIndex when the correct alternative is removed',
      build: _build,
      act: (bloc) {
        bloc.addAlternative(); // 4 alternatives
        bloc.selectCorrectAnswer(2); // mark index 2 as correct
        bloc.removeAlternative(2); // remove that index
      },
      expect: () => [
        isA<AddExerciseFormState>().having((s) => s.alternativeCount, 'count', 4),
        isA<AddExerciseFormState>().having((s) => s.correctIndex, 'correctIndex', 2),
        isA<AddExerciseFormState>().having(
          (s) => s.correctIndex,
          'correctIndex after removal',
          isNull,
        ),
      ],
    );

    blocTest<AddExerciseBloc, AddExerciseState>(
      'removeAlternative shifts correctIndex when a prior index is removed',
      build: _build,
      act: (bloc) {
        bloc.addAlternative(); // 4
        bloc.selectCorrectAnswer(3); // correct = 3
        bloc.removeAlternative(1); // remove index 1 — correct shifts to 2
      },
      expect: () => [
        isA<AddExerciseFormState>(),
        isA<AddExerciseFormState>().having((s) => s.correctIndex, 'ci', 3),
        isA<AddExerciseFormState>().having((s) => s.correctIndex, 'ci', 2),
      ],
    );

    // -----------------------------------------------------------------------
    // selectCorrectAnswer
    // -----------------------------------------------------------------------

    blocTest<AddExerciseBloc, AddExerciseState>(
      'selectCorrectAnswer sets the correctIndex',
      build: _build,
      act: (bloc) => bloc.selectCorrectAnswer(1),
      expect: () => [
        isA<AddExerciseFormState>().having(
          (s) => s.correctIndex,
          'correctIndex',
          1,
        ),
      ],
    );

    // -----------------------------------------------------------------------
    // save — validation errors
    // -----------------------------------------------------------------------

    blocTest<AddExerciseBloc, AddExerciseState>(
      'save emits ErrorState when question is empty',
      build: _build,
      act: (bloc) => bloc.save('  ', ['A', 'B', 'C']),
      expect: () => [
        isA<AddExerciseErrorState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Informe a questão',
        ),
      ],
    );

    blocTest<AddExerciseBloc, AddExerciseState>(
      'save emits ErrorState when an alternative is empty',
      build: _build,
      act: (bloc) {
        bloc.selectCorrectAnswer(0);
        bloc.save('Q?', ['A', '', 'C']); // blank alternative
      },
      expect: () => [
        isA<AddExerciseFormState>(),
        isA<AddExerciseErrorState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Preencha todas as alternativas',
        ),
      ],
    );

    blocTest<AddExerciseBloc, AddExerciseState>(
      'save emits ErrorState when no correct answer is selected',
      build: _build,
      act: (bloc) => bloc.save('Question?', ['A', 'B', 'C']),
      expect: () => [
        isA<AddExerciseErrorState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Selecione a alternativa correta',
        ),
      ],
    );

    // -----------------------------------------------------------------------
    // save — success
    // -----------------------------------------------------------------------

    blocTest<AddExerciseBloc, AddExerciseState>(
      'save emits DoneState with ExerciseFormData on valid input',
      build: _build,
      act: (bloc) {
        bloc.selectCorrectAnswer(0);
        bloc.save('What is 2+2?', ['4', '3', '5']);
      },
      expect: () => [
        isA<AddExerciseFormState>(), // after selectCorrectAnswer
        isA<AddExerciseDoneState>().having(
          (s) => s.form.question,
          'question',
          'What is 2+2?',
        ),
      ],
    );

    test('save trims whitespace from question and alternatives', () async {
      final bloc = _build()..selectCorrectAnswer(1);
      bloc.save('  My Question  ', ['  A  ', '  B  ', '  C  ']);

      final state = bloc.state as AddExerciseDoneState;
      expect(state.form.question, 'My Question');
      expect(state.form.alternatives, ['A', 'B', 'C']);

      await bloc.close();
    });
  });
}
