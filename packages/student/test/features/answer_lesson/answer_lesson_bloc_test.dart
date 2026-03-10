import 'package:bloc_test/bloc_test.dart';
import 'package:common/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:student/src/features/answer_lesson/presentation/controller/answer_lesson_bloc.dart';
import 'package:student/src/features/answer_lesson/presentation/controller/answer_lesson_state.dart';
import 'package:student/src/features/answer_lesson/presentation/domain/update_lesson.dart';

class _MockUpdateLesson extends Mock implements UpdateLesson {}

class _MockFetchLessonById extends Mock implements FetchLessonById {}

void main() {
  late _MockUpdateLesson mockUpdate;
  late _MockFetchLessonById mockFetchLessonById;

  setUp(() {
    mockUpdate = _MockUpdateLesson();
    mockFetchLessonById = _MockFetchLessonById();
    registerFallbackValue(_lesson());
  });

  AnswerLessonBloc _build() =>
      AnswerLessonBloc(mockUpdate, mockFetchLessonById);

  group('AnswerLessonBloc', () {
    test('initial state is AnswerLessonInitialState', () {
      expect(_build().state, isA<AnswerLessonInitialState>());
    });

    // -----------------------------------------------------------------------
    // init
    // -----------------------------------------------------------------------

    blocTest<AnswerLessonBloc, AnswerLessonState>(
      'loadLesson emits Loading then FormState with the fetched lesson',
      build: () {
        when(() => mockFetchLessonById.execute(1))
            .thenAnswer((_) async => _lesson());
        return _build();
      },
      act: (bloc) => bloc.loadLesson(1),
      expect: () => [
        isA<AnswerLessonLoadingState>(),
        isA<AnswerLessonFormState>()
            .having((s) => s.lesson.id, 'lesson.id', 1)
            .having((s) => s.selectedAnswers, 'selectedAnswers', isEmpty),
      ],
    );

    // -----------------------------------------------------------------------
    // selectAnswer
    // -----------------------------------------------------------------------

    blocTest<AnswerLessonBloc, AnswerLessonState>(
      'selectAnswer stores the chosen answer for the given exercise index',
      build: () {
        when(() => mockFetchLessonById.execute(1))
            .thenAnswer((_) async => _lesson());
        return _build();
      },
      act: (bloc) async {
        await bloc.loadLesson(1);
        bloc.selectAnswer(0, 'Option A');
      },
      expect: () => [
        isA<AnswerLessonLoadingState>(),
        isA<AnswerLessonFormState>(),
        isA<AnswerLessonFormState>().having(
          (s) => s.selectedAnswers,
          'selectedAnswers',
          {0: 'Option A'},
        ),
      ],
    );

    blocTest<AnswerLessonBloc, AnswerLessonState>(
      'selectAnswer overwrites a previously selected answer',
      build: () {
        when(() => mockFetchLessonById.execute(1))
            .thenAnswer((_) async => _lesson());
        return _build();
      },
      act: (bloc) async {
        await bloc.loadLesson(1);
        bloc.selectAnswer(0, 'Option A');
        bloc.selectAnswer(0, 'Option B');
      },
      expect: () => [
        isA<AnswerLessonLoadingState>(),
        isA<AnswerLessonFormState>(),
        isA<AnswerLessonFormState>(),
        isA<AnswerLessonFormState>().having(
          (s) => s.selectedAnswers[0],
          'answer at index 0',
          'Option B',
        ),
      ],
    );

    // -----------------------------------------------------------------------
    // conclude — missing answers
    // -----------------------------------------------------------------------

    blocTest<AnswerLessonBloc, AnswerLessonState>(
      'conclude emits ErrorState when not all exercises are answered',
      build: () {
        when(() => mockFetchLessonById.execute(2))
            .thenAnswer((_) async => _twoExerciseLesson());
        return _build();
      },
      act: (bloc) async {
        await bloc.loadLesson(2);
        bloc.selectAnswer(0, 'A'); // only first answered
        bloc.conclude();
      },
      expect: () => [
        isA<AnswerLessonLoadingState>(),
        isA<AnswerLessonFormState>(),
        isA<AnswerLessonFormState>(),
        isA<AnswerLessonErrorState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Responda todos os exercícios antes de concluir',
        ),
      ],
    );

    blocTest<AnswerLessonBloc, AnswerLessonState>(
      'conclude emits ErrorState when no exercises are answered',
      build: () {
        when(() => mockFetchLessonById.execute(1))
            .thenAnswer((_) async => _lesson());
        return _build();
      },
      act: (bloc) async {
        await bloc.loadLesson(1);
        bloc.conclude();
      },
      expect: () => [
        isA<AnswerLessonLoadingState>(),
        isA<AnswerLessonFormState>(),
        isA<AnswerLessonErrorState>(),
      ],
    );

    // -----------------------------------------------------------------------
    // conclude — success
    // -----------------------------------------------------------------------

    blocTest<AnswerLessonBloc, AnswerLessonState>(
      'conclude calls UpdateLesson and emits DoneState when all exercises answered',
      build: () {
        when(() => mockFetchLessonById.execute(1))
            .thenAnswer((_) async => _lesson());
        when(() => mockUpdate.execute(any())).thenAnswer((_) async {});
        return _build();
      },
      act: (bloc) async {
        await bloc.loadLesson(1);
        bloc.selectAnswer(0, 'Correct');
        await bloc.conclude();
      },
      expect: () => [
        isA<AnswerLessonLoadingState>(),
        isA<AnswerLessonFormState>(),
        isA<AnswerLessonFormState>(),
        isA<AnswerLessonDoneState>(),
      ],
      verify: (_) {
        verify(() => mockUpdate.execute(any())).called(1);
      },
    );

    test('conclude saves lesson with answered=true', () async {
      Lesson? savedLesson;
      when(() => mockFetchLessonById.execute(1))
          .thenAnswer((_) async => _lesson());
      when(() => mockUpdate.execute(any())).thenAnswer((inv) async {
        savedLesson = inv.positionalArguments.first as Lesson;
      });

      final bloc = _build();
      await bloc.loadLesson(1);
      bloc.selectAnswer(0, 'Correct');
      await bloc.conclude();

      expect(savedLesson?.answered, isTrue);
      await bloc.close();
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Lesson _lesson() => Lesson(
  id: 1,
  name: 'Test Lesson',
  description: 'desc',
  exercises: [
    ExerciseEntity(
      title: 'Q1',
      correctAnswer: 'Correct',
      wrongAnswers: ['Wrong 1', 'Wrong 2'],
    ),
  ],
);

Lesson _twoExerciseLesson() => Lesson(
  id: 2,
  name: 'Two Exercise Lesson',
  description: 'desc',
  exercises: [
    ExerciseEntity(
      title: 'Q1',
      correctAnswer: 'A',
      wrongAnswers: ['B', 'C'],
    ),
    ExerciseEntity(
      title: 'Q2',
      correctAnswer: 'X',
      wrongAnswers: ['Y', 'Z'],
    ),
  ],
);
