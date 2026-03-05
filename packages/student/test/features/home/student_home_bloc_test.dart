import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:common/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:student/src/features/home/presentation/controller/student_home_bloc.dart';
import 'package:student/src/features/home/presentation/controller/student_home_state.dart';

class _MockFetchLessons extends Mock implements FetchLessons {}

class _MockLogoutUseCase extends Mock implements LogoutUseCase {}

class _MockSyncService extends Mock implements SyncService {}

// --------------------------------------------------------------------------

void main() {
  late _MockFetchLessons mockFetch;
  late _MockLogoutUseCase mockLogout;
  late _MockSyncService mockSync;

  setUp(() {
    mockFetch = _MockFetchLessons();
    mockLogout = _MockLogoutUseCase();
    mockSync = _MockSyncService();

    // Default stubs — overridden per test when needed.
    when(() => mockSync.stateStream).thenAnswer((_) => Stream.empty());
    when(() => mockSync.currentState).thenReturn(SyncState.idle);
  });

  StudentHomeBloc _build() =>
      StudentHomeBloc(mockFetch, mockLogout, mockSync);

  group('StudentHomeBloc', () {
    test('initial state is StudentHomeInitialState', () {
      expect(_build().state, isA<StudentHomeInitialState>());
    });

    // -----------------------------------------------------------------------
    // loadLessons
    // -----------------------------------------------------------------------

    blocTest<StudentHomeBloc, StudentHomeState>(
      'emits [Loading, Loaded] with sorted lessons on success',
      build: () {
        when(() => mockFetch.execute()).thenAnswer(
          (_) async => [
            _lesson('1', answered: true),
            _lesson('2', answered: false),
          ],
        );
        return _build();
      },
      act: (bloc) => bloc.loadLessons(),
      expect: () => [
        isA<StudentHomeLoadingState>(),
        isA<StudentHomeLoadedState>().having(
          (s) => s.lessons.map((l) => l.id).toList(),
          'sorted ids',
          ['2', '1'], // unanswered first
        ),
      ],
    );

    blocTest<StudentHomeBloc, StudentHomeState>(
      'emits [Loading, Error] when fetchLessons throws',
      build: () {
        when(() => mockFetch.execute()).thenThrow(Exception('db error'));
        return _build();
      },
      act: (bloc) => bloc.loadLessons(),
      expect: () => [
        isA<StudentHomeLoadingState>(),
        isA<StudentHomeErrorState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Erro ao carregar lições',
        ),
      ],
    );

    // -----------------------------------------------------------------------
    // logout
    // -----------------------------------------------------------------------

    blocTest<StudentHomeBloc, StudentHomeState>(
      'emits LoggedOut after logout',
      build: () {
        when(() => mockLogout.logout(any(), any())).thenAnswer((_) async {});
        return _build();
      },
      act: (bloc) => bloc.logout(),
      expect: () => [isA<StudentHomeLoggedOutState>()],
    );

    // -----------------------------------------------------------------------
    // Sync state propagation
    // -----------------------------------------------------------------------

    test('isSyncing is true when SyncService emits syncing', () async {
      final controller = StreamController<SyncState>.broadcast();
      when(() => mockSync.stateStream).thenAnswer((_) => controller.stream);
      when(() => mockFetch.execute()).thenAnswer((_) async => []);

      final bloc = _build();
      await bloc.loadLessons();

      expect(
        (bloc.state as StudentHomeLoadedState).isSyncing,
        isFalse,
      );

      controller.add(SyncState.syncing);
      await Future.delayed(Duration.zero); // allow stream event to propagate

      expect(
        (bloc.state as StudentHomeLoadedState).isSyncing,
        isTrue,
      );

      controller.add(SyncState.idle);
      await Future.delayed(Duration.zero);

      expect(
        (bloc.state as StudentHomeLoadedState).isSyncing,
        isFalse,
      );

      await bloc.close();
      await controller.close();
    });

    test('isSyncing reflects currentState at the moment of loadLessons', () async {
      when(() => mockSync.currentState).thenReturn(SyncState.syncing);
      when(() => mockFetch.execute()).thenAnswer((_) async => []);

      final bloc = _build();
      await bloc.loadLessons();

      expect((bloc.state as StudentHomeLoadedState).isSyncing, isTrue);
      await bloc.close();
    });
  });
}

Lesson _lesson(String id, {bool answered = false}) => Lesson(
      id: id,
      name: 'Lesson $id',
      description: 'desc',
      exercises: [],
      answered: answered,
    );
