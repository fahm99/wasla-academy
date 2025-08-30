import 'section.dart';

class LessonProgress {
  final String id;
  final String userId;
  final String lessonId;
  final bool completed;
  final int progress;
  final int watchedSeconds;
  final int lastPosition;
  final DateTime lastAccessedAt;
  final Lesson? lesson;

  const LessonProgress({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.completed,
    required this.progress,
    required this.watchedSeconds,
    required this.lastPosition,
    required this.lastAccessedAt,
    this.lesson,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      lessonId: json['lesson_id'] as String,
      completed: json['completed'] as bool,
      progress: json['progress'] as int,
      watchedSeconds: json['watched_seconds'] as int,
      lastPosition: json['last_position'] as int,
      lastAccessedAt: DateTime.parse(json['last_accessed_at'] as String),
      lesson: json['lesson'] != null
          ? Lesson.fromJson(json['lesson'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'lesson_id': lessonId,
      'completed': completed,
      'progress': progress,
      'watched_seconds': watchedSeconds,
      'last_position': lastPosition,
      'last_accessed_at': lastAccessedAt.toIso8601String(),
      'lesson': lesson?.toJson(),
    };
  }

  LessonProgress copyWith({
    String? id,
    String? userId,
    String? lessonId,
    bool? completed,
    int? progress,
    int? watchedSeconds,
    int? lastPosition,
    DateTime? lastAccessedAt,
    Lesson? lesson,
  }) {
    return LessonProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      completed: completed ?? this.completed,
      progress: progress ?? this.progress,
      watchedSeconds: watchedSeconds ?? this.watchedSeconds,
      lastPosition: lastPosition ?? this.lastPosition,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      lesson: lesson ?? this.lesson,
    );
  }

  String get formattedWatchedTime {
    final hours = watchedSeconds ~/ 3600;
    final minutes = (watchedSeconds % 3600) ~/ 60;
    final seconds = watchedSeconds % 60;
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String get formattedLastPosition {
    final minutes = lastPosition ~/ 60;
    final seconds = lastPosition % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LessonProgress && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LessonProgress(id: $id, lessonId: $lessonId, progress: $progress%)';
  }
}

