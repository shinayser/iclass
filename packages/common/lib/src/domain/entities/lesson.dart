import 'package:common/src/domain/entities/sync_status.dart';
import 'package:equatable/equatable.dart';

class Lesson with EquatableMixin {
  final int id;
  final String name;
  final String description;
  final List<ExerciseEntity> exercises;
  final bool answered;
  final SyncStatus syncStatus;
  final String? imageUrl;
  final String? localImagePath;

  Lesson({
    this.id = 0,
    required this.name,
    required this.description,
    required this.exercises,
    this.answered = false,
    this.syncStatus = SyncStatus.synced,
    this.imageUrl,
    this.localImagePath,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final syncStatusStr = json['syncStatus'] as String?;
    return Lesson(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => ExerciseEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      answered: json['answered'] as bool? ?? false,
      syncStatus: syncStatusStr != null
          ? SyncStatus.values.byName(syncStatusStr)
          : SyncStatus.synced,
      imageUrl: json['image_url'] as String?,
      localImagePath: json['localImagePath'] as String?,
    );
  }

  Lesson copyWith({
    int? id,
    String? name,
    String? description,
    List<ExerciseEntity>? exercises,
    bool? answered,
    SyncStatus? syncStatus,
    String? Function()? imageUrl,
    String? Function()? localImagePath,
  }) {
    return Lesson(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      answered: answered ?? this.answered,
      syncStatus: syncStatus ?? this.syncStatus,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
      localImagePath:
          localImagePath != null ? localImagePath() : this.localImagePath,
    );
  }

  @override
  List<Object?> get props =>
      [name, description, exercises, syncStatus, imageUrl, localImagePath];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'answered': answered,
    'syncStatus': syncStatus.name,
    'image_url': imageUrl,
    'localImagePath': localImagePath,
  };
}

class ExerciseEntity with EquatableMixin {
  final int id;
  final String title;
  final List<String> wrongAnswers;
  final String correctAnswer;

  ExerciseEntity({
    this.id = 0,
    required this.title,
    required this.correctAnswer,
    required this.wrongAnswers,
  });

  factory ExerciseEntity.fromJson(Map<String, dynamic> json) {
    return ExerciseEntity(
      title: json['title'] as String,
      correctAnswer: json['correct_answer'] as String,
      wrongAnswers: (json['wrong_answers'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );
  }

  @override
  List<Object?> get props => [title, correctAnswer, wrongAnswers];

  Map<String, dynamic> toJson() => {
    'title': title,
    'correct_answer': correctAnswer,
    'wrong_answers': wrongAnswers,
  };
}
