import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/supabase_service.dart';
import '../../services/sync_service.dart';
import '../../services/error_handling_service.dart';
import 'courses_event.dart';
import 'courses_state.dart';

/// Bloc لإدارة الكورسات
class CoursesBloc extends Bloc<CoursesEvent, CoursesState> {
  final SupabaseService _supabaseService;
  final SyncService _syncService;

  // عدد العناصر في كل صفحة
  static const int _pageSize = 10;

  CoursesBloc({
    required SupabaseService supabaseService,
    required SyncService syncService,
  })  : _supabaseService = supabaseService,
        _syncService = syncService,
        super(CoursesInitial()) {
    on<CoursesRequested>(_onCoursesRequested);
    on<CourseDetailsRequested>(_onCourseDetailsRequested);
    on<StudentCoursesRequested>(_onStudentCoursesRequested);
    on<InstructorCoursesRequested>(_onInstructorCoursesRequested);
    on<CourseCreated>(_onCourseCreated);
    on<CourseUpdated>(_onCourseUpdated);
    on<CourseDeleted>(_onCourseDeleted);
    on<CourseEnrollmentRequested>(_onCourseEnrollmentRequested);
    on<CourseProgressUpdated>(_onCourseProgressUpdated);
    on<CourseReviewAdded>(_onCourseReviewAdded);
    on<CourseReviewsRequested>(_onCourseReviewsRequested);
  }

  /// معالجة حدث طلب قائمة الكورسات
  Future<void> _onCoursesRequested(
    CoursesRequested event,
    Emitter<CoursesState> emit,
  ) async {
    try {
      // إذا كان هناك طلب تحديث أو حالة أولية، نبدأ من الصفر
      if (event.refresh || state is CoursesInitial) {
        emit(CoursesLoading());

        final courses = await _supabaseService.getCourses(
          category: event.category,
          level: event.level,
          search: event.search,
          instructorId: event.instructorId,
          limit: _pageSize,
        );

        emit(CoursesLoaded(
          courses: courses,
          hasReachedMax: courses.length < _pageSize,
          category: event.category,
          level: event.level,
          search: event.search,
          instructorId: event.instructorId,
        ));
      } else if (state is CoursesLoaded) {
        // تحميل المزيد من الكورسات (pagination)
        final currentState = state as CoursesLoaded;

        // إذا تغيرت معايير البحث، نبدأ من الصفر
        if (currentState.category != event.category ||
            currentState.level != event.level ||
            currentState.search != event.search ||
            currentState.instructorId != event.instructorId) {
          emit(CoursesLoading());

          final courses = await _supabaseService.getCourses(
            category: event.category,
            level: event.level,
            search: event.search,
            instructorId: event.instructorId,
            limit: _pageSize,
          );

          emit(CoursesLoaded(
            courses: courses,
            hasReachedMax: courses.length < _pageSize,
            category: event.category,
            level: event.level,
            search: event.search,
            instructorId: event.instructorId,
          ));
        } else if (!currentState.hasReachedMax) {
          // تحميل الصفحة التالية
          final courses = await _supabaseService.getCourses(
            category: event.category,
            level: event.level,
            search: event.search,
            instructorId: event.instructorId,
            limit: _pageSize,
            offset: currentState.courses.length,
          );

          emit(courses.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : currentState.copyWith(
                  courses: [...currentState.courses, ...courses],
                  hasReachedMax: courses.length < _pageSize,
                ));
        }
      }
    } catch (e) {
      emit(CourseOperationFailure('فشل تحميل الكورسات: ${e.toString()}'));
    }
  }

  /// معالجة حدث طلب تفاصيل كورس
  Future<void> _onCourseDetailsRequested(
    CourseDetailsRequested event,
    Emitter<CoursesState> emit,
  ) async {
    emit(CoursesLoading());
    try {
      final course = await _supabaseService.getCourseDetails(event.courseId);

      if (course != null) {
        emit(CourseDetailsLoaded(course));
      } else {
        emit(const CourseOperationFailure('لم يتم العثور على الكورس'));
      }
    } catch (e) {
      emit(CourseOperationFailure('فشل تحميل تفاصيل الكورس: ${e.toString()}'));
    }
  }

  /// معالجة حدث طلب كورسات الطالب
  Future<void> _onStudentCoursesRequested(
    StudentCoursesRequested event,
    Emitter<CoursesState> emit,
  ) async {
    emit(CoursesLoading());
    try {
      final courses = await _supabaseService.getStudentCourses(event.userId);
      emit(StudentCoursesLoaded(courses: courses, userId: event.userId));
    } catch (e) {
      emit(CourseOperationFailure('فشل تحميل كورسات الطالب: ${e.toString()}'));
    }
  }

  /// معالجة حدث طلب كورسات المدرب
  Future<void> _onInstructorCoursesRequested(
    InstructorCoursesRequested event,
    Emitter<CoursesState> emit,
  ) async {
    emit(CoursesLoading());
    try {
      final courses = await _supabaseService.getCourses(
        instructorId: event.instructorId,
      );

      emit(InstructorCoursesLoaded(
        courses: courses,
        instructorId: event.instructorId,
      ));
    } catch (e) {
      emit(CourseOperationFailure('فشل تحميل كورسات المدرب: ${e.toString()}'));
    }
  }

  /// معالجة حدث إنشاء كورس جديد
  Future<void> _onCourseCreated(
    CourseCreated event,
    Emitter<CoursesState> emit,
  ) async {
    emit(CoursesLoading());
    try {
      final courseId = await _supabaseService.createCourse(event.courseData);

      if (courseId != null) {
        // إضافة إجراء معلق للمزامنة في حالة عدم الاتصال
        await _syncService.addPendingAction({
          'type': 'create',
          'entity': 'course',
          'data': event.courseData,
        });

        emit(const CourseOperationSuccess(
          message: 'تم إنشاء الكورس بنجاح',
          operationType: 'create',
        ));
      } else {
        emit(const CourseOperationFailure('فشل إنشاء الكورس'));
      }
    } catch (e) {
      emit(CourseOperationFailure('فشل إنشاء الكورس: ${e.toString()}'));
    }
  }

  /// معالجة حدث تحديث كورس
  Future<void> _onCourseUpdated(
    CourseUpdated event,
    Emitter<CoursesState> emit,
  ) async {
    emit(CoursesLoading());
    try {
      final success = await _supabaseService.updateCourse(
        event.courseId,
        event.courseData,
      );

      if (success) {
        // إضافة إجراء معلق للمزامنة في حالة عدم الاتصال
        await _syncService.addPendingAction({
          'type': 'update',
          'entity': 'course',
          'id': event.courseId,
          'data': event.courseData,
        });

        emit(const CourseOperationSuccess(
          message: 'تم تحديث الكورس بنجاح',
          operationType: 'update',
        ));
      } else {
        emit(const CourseOperationFailure('فشل تحديث الكورس'));
      }
    } catch (e) {
      emit(CourseOperationFailure('فشل تحديث الكورس: ${e.toString()}'));
    }
  }

  /// معالجة حدث حذف كورس
  Future<void> _onCourseDeleted(
    CourseDeleted event,
    Emitter<CoursesState> emit,
  ) async {
    emit(CoursesLoading());
    try {
      final success = await _supabaseService.deleteCourse(event.courseId);

      if (success) {
        // إضافة إجراء معلق للمزامنة في حالة عدم الاتصال
        await _syncService.addPendingAction({
          'type': 'delete',
          'entity': 'course',
          'id': event.courseId,
        });

        emit(const CourseOperationSuccess(
          message: 'تم حذف الكورس بنجاح',
          operationType: 'delete',
        ));
      } else {
        emit(const CourseOperationFailure('فشل حذف الكورس'));
      }
    } catch (e) {
      emit(CourseOperationFailure('فشل حذف الكورس: ${e.toString()}'));
    }
  }

  /// معالجة حدث التسجيل في كورس
  Future<void> _onCourseEnrollmentRequested(
    CourseEnrollmentRequested event,
    Emitter<CoursesState> emit,
  ) async {
    emit(CoursesLoading());
    try {
      final success = await _supabaseService.enrollInCourse(
        event.userId,
        event.courseId,
      );

      if (success) {
        // إضافة إجراء معلق للمزامنة في حالة عدم الاتصال
        await _syncService.addPendingAction({
          'type': 'create',
          'entity': 'enrollment',
          'data': {
            'user_id': event.userId,
            'course_id': event.courseId,
          },
        });

        emit(const CourseOperationSuccess(
          message: 'تم التسجيل في الكورس بنجاح',
          operationType: 'enroll',
        ));
      } else {
        emit(const CourseOperationFailure('فشل التسجيل في الكورس'));
      }
    } catch (e) {
      emit(CourseOperationFailure('فشل التسجيل في الكورس: ${e.toString()}'));
    }
  }

  /// معالجة حدث تحديث تقدم الطالب في كورس
  Future<void> _onCourseProgressUpdated(
    CourseProgressUpdated event,
    Emitter<CoursesState> emit,
  ) async {
    try {
      final success = await _supabaseService.updateCourseProgress(
        event.userId,
        event.courseId,
        event.progress,
      );

      if (success) {
        // إضافة إجراء معلق للمزامنة في حالة عدم الاتصال
        await _syncService.addPendingAction({
          'type': 'update',
          'entity': 'progress',
          'id': event.courseId,
          'data': {
            'user_id': event.userId,
            'progress': event.progress,
          },
        });

        // لا نغير الحالة هنا لأن تحديث التقدم يحدث في الخلفية
      } else {
        // Log error using error handling service
        final error = ErrorHandlingService.handleError(
          'فشل تحديث تقدم الكورس',
        );
        if (kDebugMode) {
          print(error.message);
        }
      }
    } catch (e) {
      // Log error using error handling service
      final error = ErrorHandlingService.handleError(e);
      if (kDebugMode) {
        print('${error.message}: ${error.originalError}');
      }
    }
  }

  /// معالجة حدث إضافة تقييم لكورس
  Future<void> _onCourseReviewAdded(
    CourseReviewAdded event,
    Emitter<CoursesState> emit,
  ) async {
    emit(CoursesLoading());
    try {
      final success = await _supabaseService.addCourseReview(
        event.userId,
        event.courseId,
        event.rating,
        event.comment,
      );

      if (success) {
        // إضافة إجراء معلق للمزامنة في حالة عدم الاتصال
        await _syncService.addPendingAction({
          'type': 'create',
          'entity': 'review',
          'data': {
            'user_id': event.userId,
            'course_id': event.courseId,
            'rating': event.rating,
            'comment': event.comment,
          },
        });

        emit(const CourseOperationSuccess(
          message: 'تم إضافة التقييم بنجاح',
          operationType: 'review',
        ));
      } else {
        emit(const CourseOperationFailure('فشل إضافة التقييم'));
      }
    } catch (e) {
      emit(CourseOperationFailure('فشل إضافة التقييم: ${e.toString()}'));
    }
  }

  /// معالجة حدث طلب تقييمات كورس
  Future<void> _onCourseReviewsRequested(
    CourseReviewsRequested event,
    Emitter<CoursesState> emit,
  ) async {
    emit(CoursesLoading());
    try {
      final reviews = await _supabaseService.getCourseReviews(event.courseId);

      emit(CourseReviewsLoaded(
        courseId: event.courseId,
        reviews: reviews,
      ));
    } catch (e) {
      emit(CourseOperationFailure('فشل تحميل التقييمات: ${e.toString()}'));
    }
  }
}
