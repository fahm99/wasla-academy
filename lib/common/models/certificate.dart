import 'course.dart';
import 'user.dart';

class Certificate {
  final String id;
  final String userId;
  final String courseId;
  final DateTime issuedAt;
  final String? certificateUrl;
  final String verificationCode;
  final Course? course;
  final User? user;

  const Certificate({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.issuedAt,
    this.certificateUrl,
    required this.verificationCode,
    this.course,
    this.user,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      courseId: json['course_id'] as String,
      issuedAt: DateTime.parse(json['issued_at'] as String),
      certificateUrl: json['certificate_url'] as String?,
      verificationCode: json['verification_code'] as String,
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
      'issued_at': issuedAt.toIso8601String(),
      'certificate_url': certificateUrl,
      'verification_code': verificationCode,
      'course': course?.toJson(),
      'user': user?.toJson(),
    };
  }

  Certificate copyWith({
    String? id,
    String? userId,
    String? courseId,
    DateTime? issuedAt,
    String? certificateUrl,
    String? verificationCode,
    Course? course,
    User? user,
  }) {
    return Certificate(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      issuedAt: issuedAt ?? this.issuedAt,
      certificateUrl: certificateUrl ?? this.certificateUrl,
      verificationCode: verificationCode ?? this.verificationCode,
      course: course ?? this.course,
      user: user ?? this.user,
    );
  }

  String get formattedDate {
    return '${issuedAt.day}/${issuedAt.month}/${issuedAt.year}';
  }

  String get verificationUrl {
    return 'https://wasla.edu/verify/$verificationCode';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Certificate && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Certificate(id: $id, courseId: $courseId, userId: $userId)';
  }
}

