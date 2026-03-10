import 'dart:convert';
import 'dart:developer';

import 'package:common/common.dart';

abstract interface class LessonsRepository {
  Future<List<Lesson>> fetchLessons();

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

  SyncAwareLessonsRepository(
    this._localDatabase,
    this._remoteDataSource,
    this._connectivity,
  );

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
    final mergedMap = <int, Lesson>{};

    // Adiciona lições locais primeiro
    for (final lesson in localLessons) {
      mergedMap[lesson.id] = lesson;
    }

    // Mescla com remotas, priorizando versões síncronizadas
    for (final lesson in remoteLessons) {
      mergedMap[lesson.id] = lesson.copyWith(syncStatus: SyncStatus.synced);
    }

    return mergedMap.values.toList();
  }

  Future<List<Lesson>> _loadFromRemote() async {
    final remoteLessons = await _remoteDataSource.fetchLessons();
    final encoded = jsonEncode(
      remoteLessons
          .map(
            (l) => l.copyWith(syncStatus: SyncStatus.synced).toJson(),
          )
          .toList(),
    );
    await _localDatabase.saveData(_kLessonsList, encoded);
    return remoteLessons;
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
      await _remoteDataSource.saveLesson(lesson);
      await _persistLocally(lesson.copyWith(syncStatus: SyncStatus.synced));
    } catch (_) {
      // Remote failed — keep the lesson as pending for the next retry.
    }
  }

  @override
  Future<void> deleteLesson(int id) async {
    final lessons = await fetchLessons();
    lessons.removeWhere((l) => l.id == id);
    final encoded = jsonEncode(lessons.map((l) => l.toJson()).toList());
    await _localDatabase.saveData(_kLessonsList, encoded);

    _connectivity.isOnline().then((isOnline) {
      if (isOnline) _remoteDataSource.deleteLesson(id);
    });
  }

  Future<void> _persistLocally(Lesson lesson) async {
    final lessons = await fetchLessons();
    lessons.removeWhere((l) => l.id == lesson.id && l.name == lesson.name);
    lessons.add(lesson);
    final encoded = jsonEncode(lessons.map((l) => l.toJson()).toList());
    await _localDatabase.saveData(_kLessonsList, encoded);
  }
}
