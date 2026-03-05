import 'package:common/src/domain/entities/sync_status.dart';
import 'package:equatable/equatable.dart';

class Lesson with EquatableMixin {
  final String id;
  final String name;
  final String description;
  final List<ExerciseEntity> exercises;
  final bool answered;
  final SyncStatus syncStatus;

  Lesson({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    this.answered = false,
    this.syncStatus = SyncStatus.synced,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final syncStatusStr = json['syncStatus'] as String?;
    return Lesson(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      answered: json['answered'] as bool? ?? false,
      syncStatus: syncStatusStr != null
          ? SyncStatus.values.byName(syncStatusStr)
          : SyncStatus.synced,
    );
  }

  Lesson copyWith({
    String? id,
    String? name,
    String? description,
    List<ExerciseEntity>? exercises,
    bool? answered,
    SyncStatus? syncStatus,
  }) {
    return Lesson(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      answered: answered ?? this.answered,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  List<Object?> get props => [name, description, exercises, syncStatus];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'answered': answered,
    'syncStatus': syncStatus.name,
  };
}

class ExerciseEntity with EquatableMixin {
  final String title;
  final List<String> wrongAnswers;
  final String correctAnswer;

  ExerciseEntity({
    required this.title,
    required this.correctAnswer,
    required this.wrongAnswers,
  });

  factory ExerciseEntity.fromJson(Map<String, dynamic> json) {
    return ExerciseEntity(
      title: json['title'] as String,
      correctAnswer: json['correctAnswer'] as String,
      wrongAnswers: (json['wrongAnswers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [title, correctAnswer, wrongAnswers];

  Map<String, dynamic> toJson() => {
    'title': title,
    'correctAnswer': correctAnswer,
    'wrongAnswers': wrongAnswers,
  };
}
