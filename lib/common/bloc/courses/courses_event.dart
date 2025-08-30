import 'package:equatable/equatable.dart';
import '../../models/course.dart';

/// أحداث إدارة الكورسات
abstract class CoursesEvent extends Equatable {
  const CoursesEvent();

  @override
  List<Object?> get props => [];
}

/// حدث طلب قائمة الكورسات
class CoursesRequested extends CoursesEvent {
  final String? category;
  final CourseLevel? level;
  final String? search;
  final String? instructorId;
  final bool refresh;

  const CoursesRequested({
    this.category,
    this.level,
    this.search,
    this.instructorId,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [category, level, search, instructorId, refresh];
}

/// حدث طلب تفاصيل كورس
class CourseDetailsRequested extends CoursesEvent {
  final String courseId;

  const CourseDetailsRequested(this.courseId);

  @override
  List<Object> get props => [courseId];
}

/// حدث طلب كورسات الطالب
class StudentCoursesRequested extends CoursesEvent {
  final String userId;
  final bool refresh;

  const StudentCoursesRequested({
    required this.userId,
    this.refresh = false,
  });

  @override
  List<Object> get props => [userId, refresh];
}

/// حدث طلب كورسات المدرب
class InstructorCoursesRequested extends CoursesEvent {
  final String instructorId;
  final bool refresh;

  const InstructorCoursesRequested({
    required this.instructorId,
    this.refresh = false,
  });

  @override
  List<Object> get props => [instructorId, refresh];
}

/// حدث إنشاء كورس جديد
class CourseCreated extends CoursesEvent {
  final Map<String, dynamic> courseData;

  const CourseCreated(this.courseData);

  @override
  List<Object> get props => [courseData];
}

/// حدث تحديث كورس
class CourseUpdated extends CoursesEvent {
  final String courseId;
  final Map<String, dynamic> courseData;

  const CourseUpdated({
    required this.courseId,
    required this.courseData,
  });

  @override
  List<Object> get props => [courseId, courseData];
}

/// حدث حذف كورس
class CourseDeleted extends CoursesEvent {
  final String courseId;

  const CourseDeleted(this.courseId);

  @override
  List<Object> get props => [courseId];
}

/// حدث التسجيل في كورس
class CourseEnrollmentRequested extends CoursesEvent {
  final String userId;
  final String courseId;

  const CourseEnrollmentRequested({
    required this.userId,
    required this.courseId,
  });

  @override
  List<Object> get props => [userId, courseId];
}

/// حدث تحديث تقدم الطالب في كورس
class CourseProgressUpdated extends CoursesEvent {
  final String userId;
  final String courseId;
  final int progress;

  const CourseProgressUpdated({
    required this.userId,
    required this.courseId,
    required this.progress,
  });

  @override
  List<Object> get props => [userId, courseId, progress];
}

/// حدث إضافة تقييم لكورس
class CourseReviewAdded extends CoursesEvent {
  final String userId;
  final String courseId;
  final double rating;
  final String comment;

  const CourseReviewAdded({
    required this.userId,
    required this.courseId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object> get props => [userId, courseId, rating, comment];
}

/// حدث طلب تقييمات كورس
class CourseReviewsRequested extends CoursesEvent {
  final String courseId;

  const CourseReviewsRequested(this.courseId);

  @override
  List<Object> get props => [courseId];
}

