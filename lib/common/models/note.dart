import 'section.dart';

class Note {
  final String id;
  final String userId;
  final String lessonId;
  final String content;
  final int? timestampSeconds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Lesson? lesson;

  const Note({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.content,
    this.timestampSeconds,
    required this.createdAt,
    required this.updatedAt,
    this.lesson,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      lessonId: json['lesson_id'] as String,
      content: json['content'] as String,
      timestampSeconds: json['timestamp_seconds'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      'content': content,
      'timestamp_seconds': timestampSeconds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'lesson': lesson?.toJson(),
    };
  }

  Note copyWith({
    String? id,
    String? userId,
    String? lessonId,
    String? content,
    int? timestampSeconds,
    DateTime? createdAt,
    DateTime? updatedAt,
    Lesson? lesson,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      content: content ?? this.content,
      timestampSeconds: timestampSeconds ?? this.timestampSeconds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lesson: lesson ?? this.lesson,
    );
  }

  String get formattedTimestamp {
    if (timestampSeconds == null) return '';
    
    final minutes = timestampSeconds! ~/ 60;
    final seconds = timestampSeconds! % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Note(id: $id, lessonId: $lessonId, timestamp: $formattedTimestamp)';
  }
}

