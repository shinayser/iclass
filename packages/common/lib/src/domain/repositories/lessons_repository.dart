import 'dart:convert';
import 'dart:developer';

import 'package:common/common.dart';
import 'package:common/src/domain/datasources/image_storage_data_source.dart';

abstract interface class LessonsRepository {
  Future<List<Lesson>> fetchLessons();

  Future<Lesson> fetchLessonById(int id);

  Future<void> saveLesson(Lesson lesson);

  Future<void> deleteLesson(int id);

  /// Pushes all locally-pending lessons to the remote server.
  Future<void> syncPending();
}

/// Offline-first repository with automatic background sync.
///
/// Writes are always persisted locally first (as [SyncStatus.pending]).
/// If the device is online the write is immediately forwarded to the remote.
/// On reconnection, [SyncService] calls [syncPending] to flush any queued edits.
class SyncAwareLessonsRepository implements LessonsRepository {
  static const _kLessonsList = 'lessons_list';

  final LocalDatabase _localDatabase;
  final RemoteLessonsDataSource _remoteDataSource;
  final ConnectivityService _connectivity;
  final ImageStorageDataSource _imageStorage;

  SyncAwareLessonsRepository(
    this._localDatabase,
    this._remoteDataSource,
    this._connectivity,
    this._imageStorage,
  );

  @override
  Future<Lesson> fetchLessonById(int id) async {
    final lessons = await fetchLessons();
    return lessons.firstWhere(
      (l) => l.id == id,
      orElse: () => throw Exception('Lesson not found: $id'),
    );
  }

  @override
  Future<List<Lesson>> fetchLessons() async {
    final jsonString = await _localDatabase.getData(_kLessonsList);
    final localLessons = _parseLessons(jsonString);

    try {
      final remoteLessons = await _remoteDataSource.fetchLessons();
      final mergedLessons = _mergeLessons(localLessons, remoteLessons);

      final encoded = jsonEncode(
        mergedLessons.map((l) => l.toJson()).toList(),
      );
      await _localDatabase.saveData(_kLessonsList, encoded);

      return mergedLessons;
    } catch (e) {
      log('Error fetching lessons from remote: $e');
      return localLessons;
    }
  }

  List<Lesson> _parseLessons(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty || jsonString == '[]') {
      return [];
    }
    final decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded
        .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<Lesson> _mergeLessons(
    List<Lesson> localLessons,
    List<Lesson> remoteLessons,
  ) {
    final remoteIds = remoteLessons.map((l) => l.id).toSet();
    final mergedMap = <int, Lesson>{};

    // Keep only local lessons that are pending (not yet synced)
    // or still exist on the remote. This ensures that remotely-deleted
    // lessons are cleaned up from local storage.
    for (final lesson in localLessons) {
      if (lesson.syncStatus == SyncStatus.pending ||
          remoteIds.contains(lesson.id)) {
        mergedMap[lesson.id] = lesson;
      }
    }

    for (final lesson in remoteLessons) {
      mergedMap[lesson.id] = lesson.copyWith(syncStatus: SyncStatus.synced);
    }

    return mergedMap.values.toList();
  }

  @override
  Future<void> saveLesson(Lesson lesson) async {
    await _persistLocally(
      lesson.copyWith(syncStatus: SyncStatus.pending),
    );
  }

  @override
  Future<void> syncPending() async {
    final lessons = await fetchLessons();
    final pending = lessons.where(
      (l) => l.syncStatus == SyncStatus.pending,
    );
    for (final lesson in pending) {
      await _syncLesson(lesson);
    }
  }

  // ---------------------------------------------------------------------------

  Future<void> _syncLesson(Lesson lesson) async {
    try {
      var synced = lesson;

      // Upload pending local image before syncing the lesson.
      if (lesson.localImagePath != null && lesson.imageUrl == null) {
        final url = await _imageStorage.uploadLessonImage(
          lesson.localImagePath!,
        );
        synced = synced.copyWith(
          imageUrl: () => url,
          localImagePath: () => null,
        );
      }

      final remoteId = await _remoteDataSource.saveLesson(synced);

      // Replace the old local entry (which may have id: 0 for new lessons)
      // with the server-assigned ID.
      final jsonString = await _localDatabase.getData(_kLessonsList);
      final lessons = _parseLessons(jsonString);
      lessons.removeWhere(
        (l) => l.id == lesson.id && l.name == lesson.name,
      );
      lessons.add(
        synced.copyWith(id: remoteId, syncStatus: SyncStatus.synced),
      );
      final encoded = jsonEncode(lessons.map((l) => l.toJson()).toList());
      await _localDatabase.saveData(_kLessonsList, encoded);
    } catch (_) {
      // Remote failed — keep the lesson as pending for the next retry.
    }
  }

  @override
  Future<void> deleteLesson(int id) async {
    // Read only from local storage — avoids a remote round-trip.
    final jsonString = await _localDatabase.getData(_kLessonsList);
    final lessons = _parseLessons(jsonString);
    lessons.removeWhere((l) => l.id == id);
    final encoded = jsonEncode(lessons.map((l) => l.toJson()).toList());
    await _localDatabase.saveData(_kLessonsList, encoded);

    // Await remote delete so the next fetchLessons won't re-merge it.
    if (await _connectivity.isOnline()) {
      await _remoteDataSource.deleteLesson(id);
    }
  }

  Future<void> _persistLocally(Lesson lesson) async {
    // Read only from local storage — avoids a remote round-trip.
    final jsonString = await _localDatabase.getData(_kLessonsList);
    final lessons = _parseLessons(jsonString);
    lessons.removeWhere((l) => l.id == lesson.id && l.name == lesson.name);
    lessons.add(lesson);
    final encoded = jsonEncode(lessons.map((l) => l.toJson()).toList());
    await _localDatabase.saveData(_kLessonsList, encoded);
  }
}
