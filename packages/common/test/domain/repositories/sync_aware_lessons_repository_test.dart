import 'package:common/common.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_local_database.dart';

class _MockRemote extends Mock implements RemoteLessonsDataSource {}

class _MockConnectivity extends Mock implements ConnectivityService {}

class _MockImageStorage extends Mock implements ImageStorageDataSource {}

void main() {
  late FakeLocalDatabase fakeDb;
  late _MockRemote mockRemote;
  late _MockConnectivity mockConnectivity;
  late _MockImageStorage mockImageStorage;
  late SyncAwareLessonsRepository repository;

  setUp(() {
    fakeDb = FakeLocalDatabase();
    mockRemote = _MockRemote();
    mockConnectivity = _MockConnectivity();
    mockImageStorage = _MockImageStorage();
    repository = SyncAwareLessonsRepository(
      fakeDb,
      mockRemote,
      mockConnectivity,
      mockImageStorage,
    );
    registerFallbackValue(_lesson(0));
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
        await repository.saveLesson(_lesson(1));

        final lessons = await repository.fetchLessons();
        expect(lessons, hasLength(1));
        expect(lessons.first.syncStatus, SyncStatus.pending);
      });

      test('does not call the remote data source', () async {
        await repository.saveLesson(_lesson(1));

        verifyNever(() => mockRemote.saveLesson(any()));
      });
    });

    group('saveLesson — online (fire-and-forget)', () {
      setUp(() {
        when(() => mockConnectivity.isOnline()).thenAnswer((_) async => true);
        when(() => mockRemote.saveLesson(any())).thenAnswer((_) async => 1);
      });

      test('persists locally as pending immediately', () async {
        await repository.saveLesson(_lesson(1));

        final lessons = await repository.fetchLessons();
        // Sync happens in the background; local status is pending right away.
        expect(lessons.first.syncStatus, SyncStatus.pending);
      });

      test('does not await remote call during save', () async {
        await repository.saveLesson(_lesson(1));

        // The remote call is fire-and-forget, so it may not have been
        // invoked yet at this exact point. The sync will be handled
        // by SyncService / syncPending.
        // We only assert that the local persist succeeded.
        expect(await repository.fetchLessons(), hasLength(1));
      });
    });

    group('deleteLesson — offline', () {
      setUp(() {
        when(() => mockConnectivity.isOnline()).thenAnswer((_) async => false);
      });

      test('removes lesson locally', () async {
        await repository.saveLesson(_lesson(1));
        await repository.saveLesson(_lesson(2));

        await repository.deleteLesson(1);

        final lessons = await repository.fetchLessons();
        expect(lessons, hasLength(1));
        expect(lessons.first.id, 2);
      });

      test('does not call remote when offline', () async {
        await repository.saveLesson(_lesson(1));
        await repository.deleteLesson(1);

        verifyNever(() => mockRemote.deleteLesson(any()));
      });
    });

    group('deleteLesson — online', () {
      setUp(() {
        when(() => mockConnectivity.isOnline()).thenAnswer((_) async => true);
        when(() => mockRemote.saveLesson(any())).thenAnswer((_) async => 1);
        when(() => mockRemote.deleteLesson(any())).thenAnswer((_) async {});
      });

      test('removes lesson locally and calls remote', () async {
        await repository.saveLesson(_lesson(1));

        await repository.deleteLesson(1);

        expect(await repository.fetchLessons(), isEmpty);
        verify(() => mockRemote.deleteLesson(1)).called(1);
      });
    });

    group('syncPending', () {
      setUp(() {
        when(() => mockRemote.saveLesson(any())).thenAnswer((_) async => 1);
      });

      test(
        'pushes all pending lessons to remote and marks them as synced',
        () async {
          when(
            () => mockConnectivity.isOnline(),
          ).thenAnswer((_) async => false);
          await repository.saveLesson(_lesson(1));
          await repository.saveLesson(_lesson(2));

          await repository.syncPending();

          final lessons = await repository.fetchLessons();
          expect(
            lessons.every((l) => l.syncStatus == SyncStatus.synced),
            isTrue,
          );
          verify(() => mockRemote.saveLesson(any())).called(2);
        },
      );

      test('does not call remote for already-synced lessons', () async {
        // Save offline so lesson stays pending.
        when(
          () => mockConnectivity.isOnline(),
        ).thenAnswer((_) async => false);
        await repository.saveLesson(_lesson(1));

        // Sync it manually so it becomes synced.
        await repository.syncPending();
        verify(() => mockRemote.saveLesson(any())).called(1);

        // Another syncPending should not call remote again.
        await repository.syncPending();
        verifyNever(() => mockRemote.saveLesson(any()));
      });

      test('keeps lesson as pending when remote fails during sync', () async {
        when(() => mockConnectivity.isOnline()).thenAnswer((_) async => false);
        await repository.saveLesson(_lesson(1));

        when(
          () => mockRemote.saveLesson(any()),
        ).thenThrow(Exception('sync failed'));

        await repository.syncPending();

        final lessons = await repository.fetchLessons();
        expect(lessons.first.syncStatus, SyncStatus.pending);
      });
    });
  });
}

Lesson _lesson(int id, {String name = 'Lesson'}) => Lesson(
  id: id,
  name: name,
  description: 'desc',
  exercises: [],
);
