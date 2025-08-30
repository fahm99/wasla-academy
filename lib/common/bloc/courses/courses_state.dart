import 'package:equatable/equatable.dart';
import '../../models/course.dart';

/// حالات إدارة الكورسات
abstract class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object?> get props => [];
}

/// حالة التحميل الأولي
class CoursesInitial extends CoursesState {}

/// حالة جاري تحميل الكورسات
class CoursesLoading extends CoursesState {}

/// حالة تحميل الكورسات بنجاح
class CoursesLoaded extends CoursesState {
  final List<Course> courses;
  final bool hasReachedMax;
  final String? category;
  final CourseLevel? level;
  final String? search;
  final String? instructorId;

  const CoursesLoaded({
    required this.courses,
    this.hasReachedMax = false,
    this.category,
    this.level,
    this.search,
    this.instructorId,
  });

  @override
  List<Object?> get props => [courses, hasReachedMax, category, level, search, instructorId];

  CoursesLoaded copyWith({
    List<Course>? courses,
    bool? hasReachedMax,
    String? category,
    CourseLevel? level,
    String? search,
    String? instructorId,
  }) {
    return CoursesLoaded(
      courses: courses ?? this.courses,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      category: category ?? this.category,
      level: level ?? this.level,
      search: search ?? this.search,
      instructorId: instructorId ?? this.instructorId,
    );
  }
}

/// حالة تحميل تفاصيل كورس بنجاح
class CourseDetailsLoaded extends CoursesState {
  final Course course;

  const CourseDetailsLoaded(this.course);

  @override
  List<Object> get props => [course];
}

/// حالة تحميل كورسات الطالب بنجاح
class StudentCoursesLoaded extends CoursesState {
  final List<Course> courses;
  final String userId;

  const StudentCoursesLoaded({
    required this.courses,
    required this.userId,
  });

  @override
  List<Object> get props => [courses, userId];
}

/// حالة تحميل كورسات المدرب بنجاح
class InstructorCoursesLoaded extends CoursesState {
  final List<Course> courses;
  final String instructorId;

  const InstructorCoursesLoaded({
    required this.courses,
    required this.instructorId,
  });

  @override
  List<Object> get props => [courses, instructorId];
}

/// حالة تحميل تقييمات كورس بنجاح
class CourseReviewsLoaded extends CoursesState {
  final String courseId;
  final List<Map<String, dynamic>> reviews;

  const CourseReviewsLoaded({
    required this.courseId,
    required this.reviews,
  });

  @override
  List<Object> get props => [courseId, reviews];
}

/// حالة نجاح العملية
class CourseOperationSuccess extends CoursesState {
  final String message;
  final String operationType;

  const CourseOperationSuccess({
    required this.message,
    required this.operationType,
  });

  @override
  List<Object> get props => [message, operationType];
}

/// حالة فشل العملية
class CourseOperationFailure extends CoursesState {
  final String message;

  const CourseOperationFailure(this.message);

  @override
  List<Object> get props => [message];
}

