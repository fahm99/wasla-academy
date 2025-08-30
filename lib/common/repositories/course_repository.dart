import '../models/course.dart';
import '../models/review.dart';
import '../models/category.dart';
import '../services/supabase_service.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';

class CourseRepository {
  final SupabaseService _supabaseService;
  final LocalStorageService _localStorageService;
  final SyncService _syncService;

  CourseRepository({
    required SupabaseService supabaseService,
    required LocalStorageService localStorageService,
    required SyncService syncService,
  })  : _supabaseService = supabaseService,
        _localStorageService = localStorageService,
        _syncService = syncService;

  // جلب جميع الكورسات
  Future<List<Course>> getAllCourses({
    int limit = 20,
    int offset = 0,
    String? categoryId,
    String? searchQuery,
    String? sortBy,
    bool ascending = false,
  }) async {
    try {
      final courses = await _supabaseService.getCourses(
        category: categoryId,
        search: searchQuery,
        limit: limit,
        offset: offset,
      );

      // حفظ الكورسات محلياً
      final coursesData = courses.map((c) => c.toJson()).toList();
      await _localStorageService.saveCoursesData(coursesData);
      return courses;
    } catch (e) {
      // جلب الكورسات من التخزين المحلي
      final cachedCourses = _localStorageService.getCoursesData() ?? [];
      return cachedCourses.map((data) => Course.fromJson(data)).toList();
    }
  }

  // جلب كورس واحد
  Future<Course?> getCourseById(String courseId) async {
    try {
      final course = await _supabaseService.getCourseDetails(courseId);
      // حفظ الكورس محلياً
      if (course != null) {
        await _localStorageService.saveCourse(course.toJson());
      }
      return course;
    } catch (e) {
      // جلب الكورس من التخزين المحلي
      final cachedCourse = _localStorageService.getCourseById(courseId);
      return cachedCourse != null ? Course.fromJson(cachedCourse) : null;
    }
  }

  // جلب كورسات المدرب
  Future<List<Course>> getInstructorCourses(String instructorId) async {
    try {
      final courses =
          await _supabaseService.getCourses(instructorId: instructorId);
      // حفظ الكورسات محلياً
      final coursesData = courses.map((c) => c.toJson()).toList();
      await _localStorageService.saveCoursesData(coursesData);
      return courses;
    } catch (e) {
      // جلب الكورسات من التخزين المحلي
      final cachedCourses =
          _localStorageService.getInstructorCourses(instructorId);
      return cachedCourses.map((data) => Course.fromJson(data)).toList();
    }
  }

  // جلب كورسات الطالب
  Future<List<Course>> getStudentCourses(String studentId) async {
    try {
      // Use the correct method that returns List<Course>
      final courses = await _supabaseService.getStudentCourses(studentId);
      // حفظ الكورسات محلياً
      final coursesData = courses.map((c) => c.toJson()).toList();
      await _localStorageService.saveCoursesData(coursesData);
      return courses;
    } catch (e) {
      // جلب الكورسات من التخزين المحلي
      final cachedCoursesData =
          _localStorageService.getStudentCourses(studentId);
      final cachedCourses =
          cachedCoursesData.map((data) => Course.fromJson(data)).toList();
      return cachedCourses;
    }
  }

  // إنشاء كورس جديد
  Future<Course?> createCourse({
    required String title,
    required String description,
    required String instructorId,
    required String categoryId,
    double? price,
    String? thumbnail,
    List<String>? tags,
    String? requirements,
    String? objectives,
  }) async {
    try {
      final courseData = {
        'title': title,
        'description': description,
        'instructor_id': instructorId,
        'category_id': categoryId,
        'price': price,
        'thumbnail': thumbnail,
        'tags': tags,
        'requirements': requirements,
        'objectives': objectives,
        'status': 'draft',
        'level': 'beginner',
        'duration': 0,
        'lessons_count': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final courseId = await _supabaseService.createCourse(courseData);
      if (courseId != null) {
        return await _supabaseService.getCourseDetails(courseId);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // تحديث كورس
  Future<Course?> updateCourse({
    required String courseId,
    String? title,
    String? description,
    String? categoryId,
    double? price,
    String? thumbnail,
    List<String>? tags,
    String? requirements,
    String? objectives,
    bool? isPublished,
  }) async {
    try {
      final courseData = <String, dynamic>{};
      if (title != null) courseData['title'] = title;
      if (description != null) courseData['description'] = description;
      if (categoryId != null) courseData['category_id'] = categoryId;
      if (price != null) courseData['price'] = price;
      if (thumbnail != null) courseData['thumbnail'] = thumbnail;
      if (tags != null) courseData['tags'] = tags;
      if (requirements != null) courseData['requirements'] = requirements;
      if (objectives != null) courseData['objectives'] = objectives;
      if (isPublished != null) {
        courseData['status'] = isPublished ? 'published' : 'draft';
      }
      courseData['updated_at'] = DateTime.now().toIso8601String();

      final success = await _supabaseService.updateCourse(courseId, courseData);
      if (success) {
        return await _supabaseService.getCourseDetails(courseId);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // حذف كورس
  Future<bool> deleteCourse(String courseId) async {
    try {
      final success = await _supabaseService.deleteCourse(courseId);
      // حذف الكورس من التخزين المحلي
      if (success) {
        await _localStorageService.deleteCourse(courseId);
      }
      return success;
    } catch (e) {
      rethrow;
    }
  }

  // الاشتراك في كورس
  Future<bool> enrollInCourse({
    required String courseId,
    required String studentId,
    String? paymentMethod,
  }) async {
    try {
      final success =
          await _supabaseService.enrollInCourse(studentId, courseId);
      // حفظ الاشتراك محلياً
      if (success) {
        await _localStorageService.saveEnrollment({
          'student_id': studentId,
          'course_id': courseId,
          'enrolled_at': DateTime.now().toIso8601String(),
          'progress': 0,
        });
      }
      return success;
    } catch (e) {
      rethrow;
    }
  }

  // إلغاء الاشتراك في كورس
  Future<bool> unenrollFromCourse({
    required String courseId,
    required String studentId,
  }) async {
    try {
      final success =
          await _supabaseService.unenrollFromCourse(studentId, courseId);

      // حذف الاشتراك من التخزين المحلي
      if (success) {
        await _localStorageService.removeEnrollment(studentId, courseId);
      }

      return success;
    } catch (e) {
      rethrow;
    }
  }

  // التحقق من الاشتراك في كورس
  Future<bool> isEnrolled({
    required String courseId,
    required String studentId,
  }) async {
    try {
      return await _supabaseService.isUserEnrolled(studentId, courseId);
    } catch (e) {
      // التحقق من التخزين المحلي
      return _localStorageService.isEnrolled(studentId, courseId);
    }
  }

  // إضافة تقييم
  Future<bool> addReview({
    required String courseId,
    required String studentId,
    required double rating,
    required String comment,
  }) async {
    try {
      await _supabaseService.addCourseReview(
        studentId,
        courseId,
        rating,
        comment,
      );
      // حفظ التقييم محلياً
      await _localStorageService.saveReview({
        'user_id': studentId,
        'course_id': courseId,
        'rating': rating,
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      rethrow;
    }
  }

  // جلب تقييمات كورس
  Future<List<Review>> getCourseReviews(String courseId) async {
    try {
      final reviewsData = await _supabaseService.getCourseReviews(courseId);
      final reviews = reviewsData.map((data) => Review.fromJson(data)).toList();
      // حفظ التقييمات محلياً
      await _localStorageService.saveReviews(reviewsData);
      return reviews;
    } catch (e) {
      // جلب التقييمات من التخزين المحلي
      final cachedReviews = _localStorageService.getCourseReviews(courseId);
      return cachedReviews.map((data) => Review.fromJson(data)).toList();
    }
  }

  // جلب الفئات
  Future<List<Category>> getCategories() async {
    try {
      final categoriesData = await _supabaseService.getCategories();
      final categories =
          categoriesData.map((data) => Category.fromJson(data)).toList();

      // حفظ الفئات محلياً
      await _localStorageService.saveCategories(categoriesData);

      return categories;
    } catch (e) {
      // جلب الفئات من التخزين المحلي
      final cachedCategories = _localStorageService.getCategories();
      return cachedCategories.map((data) => Category.fromJson(data)).toList();
    }
  }

  // جلب الكورسات الموصى بها
  Future<List<Course>> getRecommendedCourses(String userId) async {
    try {
      final courses = await _supabaseService.getRecommendedCourses(userId);

      // حفظ الكورسات محلياً
      final coursesData = courses.map((c) => c.toJson()).toList();
      await _localStorageService.saveCoursesData(coursesData);

      return courses;
    } catch (e) {
      // جلب الكورسات من التخزين المحلي
      final cachedCourses = _localStorageService.getRecommendedCourses(userId);
      return cachedCourses.map((data) => Course.fromJson(data)).toList();
    }
  }

  // البحث في الكورسات
  Future<List<Course>> searchCourses(String query) async {
    try {
      final courses = await _supabaseService.getCourses(search: query);
      // حفظ الكورسات محلياً
      final coursesData = courses.map((c) => c.toJson()).toList();
      await _localStorageService.saveCoursesData(coursesData);
      return courses;
    } catch (e) {
      // جلب الكورسات من التخزين المحلي
      final cachedCourses = _localStorageService.searchCourses(query);
      return cachedCourses.map((data) => Course.fromJson(data)).toList();
    }
  }

  // جلب إحصائيات الكورس
  Future<Map<String, dynamic>> getCourseStats(String courseId) async {
    try {
      return await _supabaseService.getCourseStats(courseId);
    } catch (e) {
      return {};
    }
  }

  // مزامنة البيانات
  Future<void> syncData() async {
    await _syncService.syncCourses();
    await _syncService.syncPendingActions();
  }
}
