import 'package:bloc_test/bloc_test.dart';
import 'package:common/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teacher/src/features/create_lesson/data/model/exercise_form_data.dart';
import 'package:teacher/src/features/create_lesson/domain/use_case/persist_lesson.dart';
import 'package:teacher/src/features/create_lesson/presentation/controller/create_lesson_bloc.dart';
import 'package:teacher/src/features/create_lesson/presentation/controller/create_lesson_state.dart';

class _MockPersistLesson extends Mock implements PersistLesson {}

void main() {
  late _MockPersistLesson mockPersist;

  setUp(() {
    mockPersist = _MockPersistLesson();
    registerFallbackValue(
      Lesson(id: 'fb', name: 'fb', description: 'fb', exercises: []),
    );
  });

  CreateLessonBloc _build() => CreateLessonBloc(mockPersist);

  group('CreateLessonBloc', () {
    test('initial state is CreateLessonFormState with empty exercises', () {
      final state = _build().state;
      expect(state, isA<CreateLessonFormState>());
      expect((state as CreateLessonFormState).exercises, isEmpty);
    });

    // -----------------------------------------------------------------------
    // addExercise
    // -----------------------------------------------------------------------

    blocTest<CreateLessonBloc, CreateLessonState>(
      'addExercise appends an exercise to the list',
      build: _build,
      act: (bloc) => bloc.addExercise(_exercise('Q1')),
      expect: () => [
        isA<CreateLessonFormState>().having(
          (s) => s.exercises,
          'exercises',
          hasLength(1),
        ),
      ],
    );

    blocTest<CreateLessonBloc, CreateLessonState>(
      'addExercise accumulates multiple exercises',
      build: _build,
      act: (bloc) {
        bloc.addExercise(_exercise('Q1'));
        bloc.addExercise(_exercise('Q2'));
        bloc.addExercise(_exercise('Q3'));
      },
      expect: () => [
        isA<CreateLessonFormState>().having((s) => s.exercises, 'ex', hasLength(1)),
        isA<CreateLessonFormState>().having((s) => s.exercises, 'ex', hasLength(2)),
        isA<CreateLessonFormState>().having((s) => s.exercises, 'ex', hasLength(3)),
      ],
    );

    // -----------------------------------------------------------------------
    // removeExercise
    // -----------------------------------------------------------------------

    blocTest<CreateLessonBloc, CreateLessonState>(
      'removeExercise removes the exercise at the given index',
      build: _build,
      act: (bloc) {
        bloc.addExercise(_exercise('Q1'));
        bloc.addExercise(_exercise('Q2'));
        bloc.removeExercise(0); // remove Q1
      },
      expect: () => [
        isA<CreateLessonFormState>().having((s) => s.exercises, 'ex', hasLength(1)),
        isA<CreateLessonFormState>().having((s) => s.exercises, 'ex', hasLength(2)),
        isA<CreateLessonFormState>().having(
          (s) => s.exercises.first.question,
          'remaining question',
          'Q2',
        ),
      ],
    );

    // -----------------------------------------------------------------------
    // conclude — validation errors
    // -----------------------------------------------------------------------

    blocTest<CreateLessonBloc, CreateLessonState>(
      'conclude emits ErrorState when title is empty',
      build: _build,
      act: (bloc) {
        bloc.addExercise(_exercise('Q1'));
        bloc.conclude('  ', 'desc');
      },
      expect: () => [
        isA<CreateLessonFormState>(),
        isA<CreateLessonErrorState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Informe o título',
        ),
      ],
    );

    blocTest<CreateLessonBloc, CreateLessonState>(
      'conclude emits ErrorState when there are no exercises',
      build: _build,
      act: (bloc) => bloc.conclude('Valid Title', 'desc'),
      expect: () => [
        isA<CreateLessonErrorState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Adicione pelo menos um exercício',
        ),
      ],
    );

    // -----------------------------------------------------------------------
    // conclude — success
    // -----------------------------------------------------------------------

    blocTest<CreateLessonBloc, CreateLessonState>(
      'conclude calls PersistLesson and emits DoneState on success',
      build: () {
        when(() => mockPersist.execute(any())).thenAnswer((_) async {});
        return _build();
      },
      act: (bloc) {
        bloc.addExercise(_exercise('Q1'));
        bloc.conclude('My Lesson', 'Some description');
      },
      expect: () => [
        isA<CreateLessonFormState>(),
        isA<CreateLessonDoneState>(),
      ],
      verify: (_) {
        verify(() => mockPersist.execute(any())).called(1);
      },
    );

    test('conclude builds lesson with answered=false and correct exercises',
        () async {
      Lesson? saved;
      when(() => mockPersist.execute(any())).thenAnswer((inv) async {
        saved = inv.positionalArguments.first as Lesson;
      });

      final bloc = _build()
        ..addExercise(_exercise('Q1', correct: 'A', wrong: ['B', 'C']))
        ..conclude('Title', 'Desc');

      await Future.delayed(Duration.zero);

      expect(saved?.name, 'Title');
      expect(saved?.answered, isFalse);
      expect(saved?.exercises.first.correctAnswer, 'A');
      expect(saved?.exercises.first.wrongAnswers, containsAll(['B', 'C']));

      await bloc.close();
    });
  });
}

ExerciseFormData _exercise(
  String question, {
  String correct = 'Correct',
  List<String> wrong = const ['Wrong1', 'Wrong2'],
}) {
  final alternatives = [correct, ...wrong];
  return ExerciseFormData(
    question: question,
    alternatives: alternatives,
    correctIndex: 0, // correct is always first in this helper
  );
}
