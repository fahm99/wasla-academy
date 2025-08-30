import 'course.dart';
import 'user.dart';

class Favorite {
  final String id;
  final String userId;
  final String courseId;
  final DateTime createdAt;
  final Course? course;
  final User? user;

  const Favorite({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.createdAt,
    this.course,
    this.user,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      courseId: json['course_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      course: json['course'] != null
          ? Course.fromJson(json['course'] as Map<String, dynamic>)
          : null,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'course_id': courseId,
      'created_at': createdAt.toIso8601String(),
      'course': course?.toJson(),
      'user': user?.toJson(),
    };
  }

  Favorite copyWith({
    String? id,
    String? userId,
    String? courseId,
    DateTime? createdAt,
    Course? course,
    User? user,
  }) {
    return Favorite(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      createdAt: createdAt ?? this.createdAt,
      course: course ?? this.course,
      user: user ?? this.user,
    );
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Favorite && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Favorite(id: $id, courseId: $courseId, userId: $userId)';
  }
}

