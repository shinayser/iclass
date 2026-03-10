import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:common/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teacher/src/features/home/presentation/controller/home_bloc.dart';
import 'package:teacher/src/features/home/presentation/controller/home_state.dart';

class _MockFetchLessons extends Mock implements FetchLessons {}

class _MockDeleteLesson extends Mock implements DeleteLesson {}

class _MockLogoutUseCase extends Mock implements LogoutUseCase {}

class _MockSyncService extends Mock implements SyncService {}

void main() {
  late _MockFetchLessons mockFetch;
  late _MockDeleteLesson mockDelete;
  late _MockLogoutUseCase mockLogout;
  late _MockSyncService mockSync;

  setUp(() {
    mockFetch = _MockFetchLessons();
    mockDelete = _MockDeleteLesson();
    mockLogout = _MockLogoutUseCase();
    mockSync = _MockSyncService();

    when(() => mockSync.stateStream).thenAnswer((_) => Stream.empty());
    when(() => mockSync.currentState).thenReturn(SyncState.idle);
  });

  TeacherHomeBloc _build() =>
      TeacherHomeBloc(mockFetch, mockDelete, mockLogout, mockSync);

  group('HomeBloc', () {
    test('initial state is HomeInitialState', () {
      expect(_build().state, isA<HomeInitialState>());
    });

    // -----------------------------------------------------------------------
    // loadLessons
    // -----------------------------------------------------------------------

    blocTest<TeacherHomeBloc, HomeState>(
      'emits [Loading, Loaded] with the returned lessons on success',
      build: () {
        when(() => mockFetch.execute()).thenAnswer(
          (_) async => [_lesson(1), _lesson(2)],
        );
        return _build();
      },
      act: (bloc) => bloc.loadLessons(),
      expect: () => [
        isA<HomeLoadingState>(),
        isA<HomeLoadedState>().having(
          (s) => s.lessons,
          'lessons',
          hasLength(2),
        ),
      ],
    );

    blocTest<TeacherHomeBloc, HomeState>(
      'emits [Loading, Error] when fetchLessons throws',
      build: () {
        when(() => mockFetch.execute()).thenThrow(Exception('error'));
        return _build();
      },
      act: (bloc) => bloc.loadLessons(),
      expect: () => [
        isA<HomeLoadingState>(),
        isA<HomeErrorState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Erro ao carregar lições',
        ),
      ],
    );

    // -----------------------------------------------------------------------
    // deleteLesson
    // -----------------------------------------------------------------------

    blocTest<TeacherHomeBloc, HomeState>(
      'emits [Loading, Loaded] after deleting a lesson successfully',
      build: () {
        when(() => mockDelete.execute(any())).thenAnswer((_) async {});
        when(() => mockFetch.execute()).thenAnswer(
          (_) async => [_lesson(2)],
        );
        return _build();
      },
      act: (bloc) => bloc.deleteLesson(1),
      expect: () => [
        isA<HomeLoadingState>(),
        isA<HomeLoadedState>().having(
          (s) => s.lessons,
          'lessons',
          hasLength(1),
        ),
      ],
    );

    blocTest<TeacherHomeBloc, HomeState>(
      'emits [Error] when deleteLesson throws',
      build: () {
        when(() => mockDelete.execute(any())).thenThrow(Exception('error'));
        return _build();
      },
      act: (bloc) => bloc.deleteLesson(1),
      expect: () => [
        isA<HomeErrorState>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Erro ao apagar lição',
        ),
      ],
    );

    // -----------------------------------------------------------------------
    // logout
    // -----------------------------------------------------------------------

    blocTest<TeacherHomeBloc, HomeState>(
      'emits HomeLoggedOutState after logout',
      build: () {
        when(() => mockLogout.logout(any(), any())).thenAnswer((_) async {});
        return _build();
      },
      act: (bloc) => bloc.logout(),
      expect: () => [isA<HomeLoggedOutState>()],
    );

    // -----------------------------------------------------------------------
    // Sync state propagation
    // -----------------------------------------------------------------------

    test('isSyncing becomes true when SyncService emits syncing', () async {
      final controller = StreamController<SyncState>.broadcast();
      when(() => mockSync.stateStream).thenAnswer((_) => controller.stream);
      when(() => mockFetch.execute()).thenAnswer((_) async => []);

      final bloc = _build();
      await bloc.loadLessons();

      expect((bloc.state as HomeLoadedState).isSyncing, isFalse);

      controller.add(SyncState.syncing);
      await Future.delayed(Duration.zero);

      expect((bloc.state as HomeLoadedState).isSyncing, isTrue);

      controller.add(SyncState.idle);
      await Future.delayed(Duration.zero);

      expect((bloc.state as HomeLoadedState).isSyncing, isFalse);

      await bloc.close();
      await controller.close();
    });

    test(
      'isSyncing reflects currentState at the moment of loadLessons',
      () async {
        when(() => mockSync.currentState).thenReturn(SyncState.syncing);
        when(() => mockFetch.execute()).thenAnswer((_) async => []);

        final bloc = _build();
        await bloc.loadLessons();

        expect((bloc.state as HomeLoadedState).isSyncing, isTrue);
        await bloc.close();
      },
    );
  });
}

Lesson _lesson(int id) => Lesson(
  id: id,
  name: 'Lesson $id',
  description: 'desc',
  exercises: [],
);
