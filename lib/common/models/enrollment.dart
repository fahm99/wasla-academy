import 'course.dart';
import 'user.dart';

class Enrollment {
  final String id;
  final String userId;
  final String courseId;
  final DateTime enrolledAt;
  final DateTime? completedAt;
  final int progress;
  final DateTime? lastAccessedAt;
  final Course? course;
  final User? user;

  const Enrollment({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.enrolledAt,
    this.completedAt,
    required this.progress,
    this.lastAccessedAt,
    this.course,
    this.user,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      courseId: json['course_id'] as String,
      enrolledAt: DateTime.parse(json['enrolled_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      progress: json['progress'] as int,
      lastAccessedAt: json['last_accessed_at'] != null
          ? DateTime.parse(json['last_accessed_at'] as String)
          : null,
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
      'enrolled_at': enrolledAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'progress': progress,
      'last_accessed_at': lastAccessedAt?.toIso8601String(),
      'course': course?.toJson(),
      'user': user?.toJson(),
    };
  }

  Enrollment copyWith({
    String? id,
    String? userId,
    String? courseId,
    DateTime? enrolledAt,
    DateTime? completedAt,
    int? progress,
    DateTime? lastAccessedAt,
    Course? course,
    User? user,
  }) {
    return Enrollment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      enrolledAt: enrolledAt ?? this.enrolledAt,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      course: course ?? this.course,
      user: user ?? this.user,
    );
  }

  bool get isCompleted => completedAt != null || progress >= 100;

  String get statusText {
    if (isCompleted) {
      return 'مكتمل';
    } else if (progress > 0) {
      return 'قيد التقدم';
    } else {
      return 'لم يبدأ';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Enrollment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Enrollment(id: $id, userId: $userId, courseId: $courseId, progress: $progress%)';
  }
}

