import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../services/local_storage_service.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import '../models/user.dart';
import '../models/course.dart';

/// مستودع التطبيق لتوحيد الوصول إلى الخدمات
class AppRepository {
  final SupabaseService _supabaseService;
  final LocalStorageService _localStorageService;
  final ConnectivityService _connectivityService;
  final SyncService _syncService;

  AppRepository({
    required SupabaseService supabaseService,
    required LocalStorageService localStorageService,
    required ConnectivityService connectivityService,
    required SyncService syncService,
  })  : _supabaseService = supabaseService,
        _localStorageService = localStorageService,
        _connectivityService = connectivityService,
        _syncService = syncService;

  /// الحصول على حالة الاتصال
  bool get isConnected => _connectivityService.isConnected;

  /// تدفق حالة الاتصال
  Stream<bool> get connectionStatus => _connectivityService.connectionStatus;

  /// مزامنة الإجراءات المعلقة
  Future<void> syncPendingActions() async {
    await _syncService.syncPendingActions();
  }

  /// إضافة إجراء معلق للمزامنة
  Future<void> addPendingAction(Map<String, dynamic> action) async {
    await _syncService.addPendingAction(action);
  }

  /// تسجيل الدخول
  Future<User?> signIn({required String email, required String password}) async {
    try {
      final response = await _supabaseService.signInWithEmail(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        final userDetails = await _supabaseService.getUserDetails(response.user!.id);
        
        if (userDetails != null) {
          // حفظ بيانات المستخدم محلياً
          await _localStorageService.saveUserData(userDetails.toJson());
          
          // حفظ رمز المصادقة
          await _localStorageService.saveAuthToken(response.session!.accessToken);
          
          return userDetails;
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in: $e');
      }
      rethrow;
    }
  }

  /// تسجيل مستخدم جديد
  Future<User?> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      
      if (response.user != null) {
        final user = User(
          id: response.user!.id,
          name: name,
          email: email,
          role: role,
          createdAt: DateTime.now(),
        );
        
        // حفظ بيانات المستخدم محلياً
        await _localStorageService.saveUserData(user.toJson());
        
        // حفظ رمز المصادقة
        await _localStorageService.saveAuthToken(response.session!.accessToken);
        
        return user;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error signing up: $e');
      }
      rethrow;
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      await _localStorageService.clearUserData();
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
      rethrow;
    }
  }

  /// الحصول على المستخدم الحالي
  User? getCurrentUser() {
    try {
      // محاولة الحصول على المستخدم من Supabase
      final supabaseUser = _supabaseService.getCurrentUser();
      if (supabaseUser != null) {
        return supabaseUser;
      }
      
      // إذا لم يكن هناك مستخدم في Supabase، نحاول الحصول عليه من التخزين المحلي
      final userData = _localStorageService.getUserData();
      if (userData != null) {
        return User.fromJson(userData);
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting current user: $e');
      }
      return null;
    }
  }

  /// الحصول على تفاصيل المستخدم
  Future<User?> getUserDetails(String userId) async {
    try {
      if (_connectivityService.isConnected) {
        // إذا كان هناك اتصال، نحصل على البيانات من Supabase
        return await _supabaseService.getUserDetails(userId);
      } else {
        // إذا لم يكن هناك اتصال، نحاول الحصول على البيانات من التخزين المحلي
        final userData = _localStorageService.getUserData();
        if (userData != null && userData['id'] == userId) {
          return User.fromJson(userData);
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user details: $e');
      }
      return null;
    }
  }

  /// تحديث بيانات المستخدم
  Future<bool> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      if (_connectivityService.isConnected) {
        // إذا كان هناك اتصال، نحدث البيانات في Supabase
        final success = await _supabaseService.updateUserProfile(userId, data);
        
        if (success) {
          // تحديث البيانات المحلية
          final userData = _localStorageService.getUserData();
          if (userData != null && userData['id'] == userId) {
            userData.addAll(data);
            await _localStorageService.saveUserData(userData);
          }
        }
        
        return success;
      } else {
        // إذا لم يكن هناك اتصال، نحدث البيانات محلياً ونضيف إجراء معلق للمزامنة
        final userData = _localStorageService.getUserData();
        if (userData != null && userData['id'] == userId) {
          userData.addAll(data);
          await _localStorageService.saveUserData(userData);
          
          // إضافة إجراء معلق للمزامنة
          await _syncService.addPendingAction({
            'type': 'update',
            'entity': 'user',
            'id': userId,
            'data': data,
          });
          
          return true;
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
      return false;
    }
  }

  /// الحصول على قائمة الكورسات
  Future<List<Course>> getCourses({
    String? category,
    CourseLevel? level,
    String? search,
    String? instructorId,
    int? limit,
    int? offset,
  }) async {
    try {
      if (_connectivityService.isConnected) {
        // إذا كان هناك اتصال، نحصل على البيانات من Supabase
        return await _supabaseService.getCourses(
          category: category,
          level: level,
          search: search,
          instructorId: instructorId,
          limit: limit,
          offset: offset,
        );
      } else {
        // إذا لم يكن هناك اتصال، نحاول الحصول على البيانات من التخزين المحلي
        final coursesData = _localStorageService.getCoursesData();
        if (coursesData != null) {
          List<Course> courses = coursesData.map((data) => Course.fromJson(data)).toList();
          
          // تطبيق الفلاتر
          if (category != null) {
            courses = courses.where((course) => course.category == category).toList();
          }
          
          if (level != null) {
            courses = courses.where((course) => course.level == level).toList();
          }
          
          if (search != null && search.isNotEmpty) {
            courses = courses.where((course) => 
              course.title.toLowerCase().contains(search.toLowerCase()) ||
              course.description.toLowerCase().contains(search.toLowerCase())
            ).toList();
          }
          
          if (instructorId != null) {
            courses = courses.where((course) => course.instructorId == instructorId).toList();
          }
          
          // تطبيق الحد والإزاحة
          if (offset != null && limit != null) {
            final end = offset + limit;
            if (end <= courses.length) {
              courses = courses.sublist(offset, end);
            } else if (offset < courses.length) {
              courses = courses.sublist(offset);
            } else {
              courses = [];
            }
          } else if (limit != null && courses.length > limit) {
            courses = courses.sublist(0, limit);
          }
          
          return courses;
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting courses: $e');
      }
      return [];
    }
  }

  /// الحصول على تفاصيل كورس
  Future<Course?> getCourseDetails(String courseId) async {
    try {
      if (_connectivityService.isConnected) {
        // إذا كان هناك اتصال، نحصل على البيانات من Supabase
        return await _supabaseService.getCourseDetails(courseId);
      } else {
        // إذا لم يكن هناك اتصال، نحاول الحصول على البيانات من التخزين المحلي
        final coursesData = _localStorageService.getCoursesData();
        if (coursesData != null) {
          final courseData = coursesData.firstWhere(
            (data) => data['id'] == courseId,
            orElse: () => <String, dynamic>{},
          );
          
          if (courseData.isNotEmpty) {
            return Course.fromJson(courseData);
          }
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting course details: $e');
      }
      return null;
    }
  }

  /// إنشاء كورس جديد
  Future<String?> createCourse(Map<String, dynamic> courseData) async {
    try {
      if (_connectivityService.isConnected) {
        // إذا كان هناك اتصال، ننشئ الكورس في Supabase
        return await _supabaseService.createCourse(courseData);
      } else {
        // إذا لم يكن هناك اتصال، نضيف إجراء معلق للمزامنة
        await _syncService.addPendingAction({
          'type': 'create',
          'entity': 'course',
          'data': courseData,
        });
        
        // إنشاء معرف مؤقت للكورس
        final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        
        // إضافة الكورس إلى التخزين المحلي
        final coursesData = _localStorageService.getCoursesData() ?? [];
        courseData['id'] = tempId;
        coursesData.add(courseData);
        await _localStorageService.saveCoursesData(coursesData);
        
        return tempId;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating course: $e');
      }
      return null;
    }
  }

  /// تحديث بيانات كورس
  Future<bool> updateCourse(String courseId, Map<String, dynamic> data) async {
    try {
      if (_connectivityService.isConnected) {
        // إذا كان هناك اتصال، نحدث البيانات في Supabase
        return await _supabaseService.updateCourse(courseId, data);
      } else {
        // إذا لم يكن هناك اتصال، نضيف إجراء معلق للمزامنة
        await _syncService.addPendingAction({
          'type': 'update',
          'entity': 'course',
          'id': courseId,
          'data': data,
        });
        
        // تحديث البيانات المحلية
        final coursesData = _localStorageService.getCoursesData();
        if (coursesData != null) {
          final index = coursesData.indexWhere((course) => course['id'] == courseId);
          if (index != -1) {
            coursesData[index].addAll(data);
            await _localStorageService.saveCoursesData(coursesData);
            return true;
          }
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating course: $e');
      }
      return false;
    }
  }

  /// التسجيل في كورس
  Future<bool> enrollInCourse(String userId, String courseId) async {
    try {
      if (_connectivityService.isConnected) {
        // إذا كان هناك اتصال، نسجل في الكورس في Supabase
        return await _supabaseService.enrollInCourse(userId, courseId);
      } else {
        // إذا لم يكن هناك اتصال، نضيف إجراء معلق للمزامنة
        await _syncService.addPendingAction({
          'type': 'create',
          'entity': 'enrollment',
          'data': {
            'user_id': userId,
            'course_id': courseId,
          },
        });
        
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error enrolling in course: $e');
      }
      return false;
    }
  }

  /// تحديث تقدم الطالب في كورس
  Future<bool> updateCourseProgress(String userId, String courseId, int progress) async {
    try {
      if (_connectivityService.isConnected) {
        // إذا كان هناك اتصال، نحدث التقدم في Supabase
        return await _supabaseService.updateCourseProgress(userId, courseId, progress);
      } else {
        // إذا لم يكن هناك اتصال، نضيف إجراء معلق للمزامنة
        await _syncService.addPendingAction({
          'type': 'update',
          'entity': 'progress',
          'id': courseId,
          'data': {
            'user_id': userId,
            'progress': progress,
          },
        });
        
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating course progress: $e');
      }
      return false;
    }
  }

  /// إضافة تقييم لكورس
  Future<bool> addCourseReview(String userId, String courseId, double rating, String comment) async {
    try {
      if (_connectivityService.isConnected) {
        // إذا كان هناك اتصال، نضيف التقييم في Supabase
        return await _supabaseService.addCourseReview(userId, courseId, rating, comment);
      } else {
        // إذا لم يكن هناك اتصال، نضيف إجراء معلق للمزامنة
        await _syncService.addPendingAction({
          'type': 'create',
          'entity': 'review',
          'data': {
            'user_id': userId,
            'course_id': courseId,
            'rating': rating,
            'comment': comment,
          },
        });
        
        return true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding course review: $e');
      }
      return false;
    }
  }
}

