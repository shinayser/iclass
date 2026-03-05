import 'dart:convert';

import 'package:common/common.dart';

abstract interface class LessonsRepository {
  Future<List<Lesson>> fetchLessons();

  Future<void> saveLesson(Lesson lesson);

  Future<void> deleteLesson(String id);

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

  final LocalDatabase _database;
  final RemoteLessonsDataSource _remote;
  final ConnectivityService _connectivity;

  SyncAwareLessonsRepository(
    this._database,
    this._remote,
    this._connectivity,
  );

  @override
  Future<List<Lesson>> fetchLessons() async {
    final jsonString = await _database.getData(_kLessonsList);
    if (jsonString == null) return [];
    final decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded
        .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveLesson(Lesson lesson) async {
    // 1. Persist locally as pending immediately.
    await _persistLocally(
      lesson.copyWith(syncStatus: SyncStatus.pending),
    );

    // 2. Attempt remote sync if online.
    if (await _connectivity.isOnline()) {
      await _syncLesson(lesson);
    }
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
      await _remote.saveLesson(lesson);
      await _persistLocally(lesson.copyWith(syncStatus: SyncStatus.synced));
    } catch (_) {
      // Remote failed — keep the lesson as pending for the next retry.
    }
  }

  @override
  Future<void> deleteLesson(String id) async {
    final lessons = await fetchLessons();
    lessons.removeWhere((l) => l.id == id);
    final encoded = jsonEncode(lessons.map((l) => l.toJson()).toList());
    await _database.saveData(_kLessonsList, encoded);

    _connectivity.isOnline().then((isOnline) {
      if (isOnline) _remote.deleteLesson(id);
    });
  }

  Future<void> _persistLocally(Lesson lesson) async {
    final lessons = await fetchLessons();
    lessons.removeWhere((l) => l.id == lesson.id);
    lessons.add(lesson);
    final encoded = jsonEncode(lessons.map((l) => l.toJson()).toList());
    await _database.saveData(_kLessonsList, encoded);
  }
}
