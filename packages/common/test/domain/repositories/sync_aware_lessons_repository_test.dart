import 'package:common/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_local_database.dart';

class _MockRemote extends Mock implements RemoteLessonsDataSource {}

class _MockConnectivity extends Mock implements ConnectivityService {}

void main() {
  late FakeLocalDatabase fakeDb;
  late _MockRemote mockRemote;
  late _MockConnectivity mockConnectivity;
  late SyncAwareLessonsRepository repository;

  setUp(() {
    fakeDb = FakeLocalDatabase();
    mockRemote = _MockRemote();
    mockConnectivity = _MockConnectivity();
    repository = SyncAwareLessonsRepository(
      fakeDb,
      mockRemote,
      mockConnectivity,
    );
    registerFallbackValue(_lesson('fallback'));
  });

  group('SyncAwareLessonsRepository', () {
    group('fetchLessons', () {
      test('returns empty list when the local database is empty', () async {
        expect(await repository.fetchLessons(), isEmpty);
      });
    });

    group('saveLesson — offline', () {
      setUp(() {
        when(() => mockConnectivity.isOnline()).thenAnswer((_) async => false);
      });

      test('persists lesson locally with syncStatus.pending', () async {
        await repository.saveLesson(_lesson('1'));

        final lessons = await repository.fetchLessons();
        expect(lessons, hasLength(1));
        expect(lessons.first.syncStatus, SyncStatus.pending);
      });

      test('does not call the remote data source', () async {
        await repository.saveLesson(_lesson('1'));

        verifyNever(() => mockRemote.saveLesson(any()));
      });
    });

    group('saveLesson — online', () {
      setUp(() {
        when(() => mockConnectivity.isOnline()).thenAnswer((_) async => true);
        when(() => mockRemote.saveLesson(any())).thenAnswer((_) async {});
      });

      test('marks lesson as synced after remote success', () async {
        await repository.saveLesson(_lesson('1'));

        final lessons = await repository.fetchLessons();
        expect(lessons.first.syncStatus, SyncStatus.synced);
      });

      test('calls the remote data source once', () async {
        await repository.saveLesson(_lesson('1'));

        verify(() => mockRemote.saveLesson(any())).called(1);
      });
    });

    group('saveLesson — online, remote fails', () {
      setUp(() {
        when(() => mockConnectivity.isOnline()).thenAnswer((_) async => true);
        when(() => mockRemote.saveLesson(any()))
            .thenThrow(Exception('network error'));
      });

      test('lesson stays as pending when remote throws', () async {
        await repository.saveLesson(_lesson('1'));

        final lessons = await repository.fetchLessons();
        expect(lessons.first.syncStatus, SyncStatus.pending);
      });
    });

    group('syncPending', () {
      setUp(() {
        when(() => mockRemote.saveLesson(any())).thenAnswer((_) async {});
      });

      test('pushes all pending lessons to remote and marks them as synced',
          () async {
        when(() => mockConnectivity.isOnline()).thenAnswer((_) async => false);
        await repository.saveLesson(_lesson('1'));
        await repository.saveLesson(_lesson('2'));

        await repository.syncPending();

        final lessons = await repository.fetchLessons();
        expect(lessons.every((l) => l.syncStatus == SyncStatus.synced), isTrue);
        verify(() => mockRemote.saveLesson(any())).called(2);
      });

      test('does not call remote for already-synced lessons', () async {
        when(() => mockConnectivity.isOnline()).thenAnswer((_) async => true);
        await repository.saveLesson(_lesson('1')); // synced online

        // Remote was called once during saveLesson itself.
        // After syncPending, total should still be 1 (no duplicate call).
        await repository.syncPending();

        verify(() => mockRemote.saveLesson(any())).called(1);
      });

      test('keeps lesson as pending when remote fails during sync', () async {
        when(() => mockConnectivity.isOnline()).thenAnswer((_) async => false);
        await repository.saveLesson(_lesson('1'));

        when(() => mockRemote.saveLesson(any()))
            .thenThrow(Exception('sync failed'));

        await repository.syncPending();

        final lessons = await repository.fetchLessons();
        expect(lessons.first.syncStatus, SyncStatus.pending);
      });
    });
  });
}

Lesson _lesson(String id, {String name = 'Lesson'}) => Lesson(
      id: id,
      name: name,
      description: 'desc',
      exercises: [],
    );
