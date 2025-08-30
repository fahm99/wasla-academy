import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'dart:typed_data';
import '../models/user.dart';
import '../models/course.dart';

/// خدمة التعامل مع Supabase
class SupabaseService {
  static SupabaseService? _instance;
  late final SupabaseClient _client;

  // الجداول
  static const String usersTable = 'users';
  static const String coursesTable = 'courses';
  static const String enrollmentsTable = 'enrollments';
  static const String lessonsTable = 'lessons';
  static const String categoriesTable = 'categories';
  static const String reviewsTable = 'reviews';
  static const String verificationCodesTable = 'verification_codes';
  static const String pendingRegistrationsTable = 'pending_registrations';
  static const String userDocumentsTable = 'user_documents';

  /// الحصول على مثيل الخدمة (Singleton)
  static SupabaseService get instance {
    _instance ??= SupabaseService._();
    return _instance!;
  }

  /// إنشاء مثيل جديد وتهيئة الاتصال
  SupabaseService._() {
    _client = Supabase.instance.client;
  }

  /// تهيئة Supabase
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      debug: true,
    );
  }

  /// الحصول على عميل Supabase
  SupabaseClient get client => _client;

  /// معالج أخطاء RLS المحسن
  T _handleRLSError<T>(dynamic error, T fallbackValue, String operation) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('row-level security') ||
        errorStr.contains('rls') ||
        errorStr.contains('policy') ||
        errorStr.contains('insufficient_privilege') ||
        errorStr.contains('permission denied')) {
      print('RLS Policy Error in $operation: $error');
      throw const AuthException(
          'Access denied: You do not have permission to perform this action. '
          'Please check your authentication status and try again.');
    }

    if (errorStr.contains('jwt') ||
        errorStr.contains('token') ||
        errorStr.contains('unauthorized') ||
        errorStr.contains('authentication')) {
      print('Authentication Error in $operation: $error');
      throw const AuthException(
          'Authentication error: Please log in again and try again.');
    }

    // أخطاء أخرى
    print('Database Error in $operation: $error');
    return fallbackValue;
  }

  /// معالج تنفيذ مع معالجة أخطاء RLS
  Future<T> _executeWithRLSHandling<T>(
    Future<T> Function() operation,
    T fallbackValue,
    String operationName,
  ) async {
    try {
      return await operation();
    } catch (e) {
      return _handleRLSError(e, fallbackValue, operationName);
    }
  }

  /// تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// تسجيل مستخدم جديد مع دعم أنواع الحسابات المختلفة
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
    String? institutionName,
    String? licenseNumber,
    String? specialization,
    int? experienceYears,
  }) async {
    // للطلاب - التسجيل المباشر
    if (role == UserRole.student) {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': role.toString().split('.').last,
        },
      );

      if (response.user != null) {
        // إنشاء سجل المستخدم في جدول المستخدمين
        await _client.from(usersTable).insert({
          'id': response.user!.id,
          'name': name,
          'email': email,
          'phone': phone,
          'role': role.toString().split('.').last,
          'created_at': DateTime.now().toIso8601String(),
          'account_type': 'student',
        });
      }

      return response;
    }
    // للمؤسسات والمدربين - التسجيل المعلق
    else {
      // حفظ بيانات التسجيل المعلق
      final pendingData = {
        'email': email,
        'name': name,
        'phone': phone,
        'account_type': role == UserRole.instructor
            ? 'institution'
            : 'individual_instructor',
        'encrypted_password': password, // سيتم تشفيره لاحقاً
        'institution_name': institutionName,
        'institution_license': licenseNumber,
        'specialization': specialization != null ? [specialization] : [],
        'experience_years': experienceYears,
        'status': 'pending',
        'expires_at':
            DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };

      // إدراج البيانات في جدول التسجيلات المعلقة
      await _client.from(pendingRegistrationsTable).insert(pendingData);

      // إرجاع استجابة خاصة للتسجيل المعلق
      return AuthResponse(
        user: null,
        session: null,
      );
    }
  }

  /// إرسال رمز التحقق عبر البريد الإلكتروني
  Future<bool> sendVerificationCode(String email) async {
    try {
      // في بيئة حقيقية، هنا سيتم إرسال رمز عشوائي عبر خدمة البريد الإلكتروني
      // حالياً سنحاكي العملية بحفظ الرمز في قاعدة البيانات
      final code = _generateVerificationCode();

      // حفظ رمز التحقق في قاعدة البيانات مع انتهاء صلاحية
      await _client.from(verificationCodesTable).upsert({
        'email': email,
        'code': code,
        'expires_at':
            DateTime.now().add(const Duration(minutes: 10)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });

      // في التطبيق الحقيقي، سيتم إرسال الرمز عبر البريد الإلكتروني
      // هنا سنطبع الرمز للاختبار
      print('رمز التحقق لـ $email: $code');

      return true;
    } catch (e) {
      print('Error sending verification code: $e');
      return false;
    }
  }

  /// التحقق من رمز التأكيد
  Future<bool> verifyCode(String email, String code) async {
    try {
      final response = await _client
          .from(verificationCodesTable)
          .select()
          .eq('email', email)
          .eq('code', code)
          .gte('expires_at', DateTime.now().toIso8601String())
          .limit(1);

      if (response.isNotEmpty) {
        // حذف رمز التحقق بعد الاستخدام
        await _client.from(verificationCodesTable).delete().eq('email', email);

        // تفعيل المستخدم إذا لم يكن مفعلاً
        await _client
            .from(usersTable)
            .update({'email_verified': true}).eq('email', email);

        return true;
      }

      return false;
    } catch (e) {
      print('Error verifying code: $e');
      return false;
    }
  }

  /// توليد رمز تحقق عشوائي مكون من 6 أرقام
  String _generateVerificationCode() {
    final random = DateTime.now().millisecondsSinceEpoch;
    return (random % 1000000).toString().padLeft(6, '0');
  }

  /// إنهاء عملية التسجيل بعد التحقق من الرمز
  Future<User?> completeSignupAfterVerification(String email) async {
    try {
      // جلب بيانات التسجيل المعلقة
      final pendingResponse = await _client
          .from(pendingRegistrationsTable)
          .select()
          .eq('email', email)
          .eq('status', 'pending')
          .gte('expires_at', DateTime.now().toIso8601String())
          .limit(1);

      if (pendingResponse.isNotEmpty) {
        final pendingData = pendingResponse.first;

        // إنشاء حساب المصادقة
        final response = await _client.auth.signUp(
          email: pendingData['email'],
          password: pendingData['encrypted_password'],
          data: {
            'name': pendingData['name'],
            'role': 'instructor', // المؤسسات والمدربون يحصلون على دور المدرب
          },
        );

        if (response.user != null) {
          // إنشاء سجل المستخدم في جدول المستخدمين
          await _client.from(usersTable).insert({
            'id': response.user!.id,
            'name': pendingData['name'],
            'email': pendingData['email'],
            'phone': pendingData['phone'],
            'role': 'instructor',
            'account_type': pendingData['account_type'],
            'institution_name': pendingData['institution_name'],
            'institution_license': pendingData['institution_license'],
            'specialization': pendingData['specialization'],
            'experience_years': pendingData['experience_years'],
            'email_verified': true,
            'verification_status': 'pending', // بانتظار مراجعة المستندات
            'created_at': DateTime.now().toIso8601String(),
          });

          // تحديث حالة التسجيل المعلق
          await _client
              .from(pendingRegistrationsTable)
              .update({'status': 'completed'}).eq('email', email);

          // إرجاع بيانات المستخدم
          return User(
            id: response.user!.id,
            name: pendingData['name'],
            email: pendingData['email'],
            role: UserRole.instructor,
            phone: pendingData['phone'],
            createdAt: DateTime.now(),
          );
        }
      }

      return null;
    } catch (e) {
      print('Error completing signup: $e');
      return null;
    }
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// الحصول على المستخدم الحالي
  User? getCurrentUser() {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    // يجب استكمال بيانات المستخدم من جدول المستخدمين
    return User(
      id: authUser.id,
      name: authUser.userMetadata?['name'] ?? '',
      email: authUser.email ?? '',
      avatar: authUser.userMetadata?['avatar'] as String?,
      role: _parseUserRole(authUser.userMetadata?['role']),
      createdAt: DateTime.now(),
      lastLoginAt: null,
      isActive: true,
      metadata: authUser.userMetadata,
    );
  }

  /// تحويل نص الدور إلى نوع UserRole
  UserRole _parseUserRole(String? roleStr) {
    switch (roleStr) {
      case 'student':
        return UserRole.student;
      case 'instructor':
        return UserRole.instructor;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }

  /// الحصول على بيانات المستخدم الكاملة
  Future<User?> getUserDetails(String userId) async {
    return await _executeWithRLSHandling(
      () async {
        final response =
            await _client.from(usersTable).select().eq('id', userId).single();
        return User.fromJson(response);
      },
      null,
      'getUserDetails',
    );
  }

  /// تحديث بيانات المستخدم
  Future<bool> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    return await _executeWithRLSHandling(
      () async {
        await _client.from(usersTable).update(data).eq('id', userId);
        return true;
      },
      false,
      'updateUserProfile',
    );
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
    return await _executeWithRLSHandling(
      () async {
        dynamic query =
            _client.from(coursesTable).select('*, $usersTable(name, avatar)');

        // تطبيق الفلاتر
        if (category != null) {
          query = query.eq('category', category);
        }

        if (level != null) {
          query = query.eq('level', level.toString().split('.').last);
        }

        if (search != null && search.isNotEmpty) {
          query = query.ilike('title', '%$search%');
        }

        if (instructorId != null) {
          query = query.eq('instructor_id', instructorId);
        }

        // تطبيق الحد والإزاحة
        if (limit != null) {
          query = query.limit(limit);
        }

        if (offset != null) {
          query = query.range(offset, offset + (limit ?? 10) - 1);
        }

        final response = await query;

        return (response as List<dynamic>)
            .map((json) => Course.fromJson(json))
            .toList();
      },
      <Course>[],
      'getCourses',
    );
  }

  /// الحصول على تفاصيل كورس محدد
  Future<Course?> getCourseDetails(String courseId) async {
    try {
      final response = await _client
          .from(coursesTable)
          .select('*, $usersTable(name, avatar), $lessonsTable(*)')
          .eq('id', courseId)
          .single();

      return Course.fromJson(response);
    } catch (e) {
      print('Error getting course details: $e');
      return null;
    }
  }

  /// إنشاء كورس جديد
  Future<String?> createCourse(Map<String, dynamic> courseData) async {
    try {
      final response = await _client
          .from(coursesTable)
          .insert(courseData)
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      print('Error creating course: $e');
      return null;
    }
  }

  /// تحديث بيانات كورس
  Future<bool> updateCourse(String courseId, Map<String, dynamic> data) async {
    try {
      await _client.from(coursesTable).update(data).eq('id', courseId);
      return true;
    } catch (e) {
      print('Error updating course: $e');
      return false;
    }
  }

  /// حذف كورس
  Future<bool> deleteCourse(String courseId) async {
    try {
      await _client.from(coursesTable).delete().eq('id', courseId);
      return true;
    } catch (e) {
      print('Error deleting course: $e');
      return false;
    }
  }

  /// تسجيل طالب في كورس
  Future<bool> enrollInCourse(String userId, String courseId) async {
    return await _executeWithRLSHandling(
      () async {
        await _client.from(enrollmentsTable).insert({
          'user_id': userId,
          'course_id': courseId,
          'enrolled_at': DateTime.now().toIso8601String(),
          'progress': 0,
        });
        return true;
      },
      false,
      'enrollInCourse',
    );
  }

  /// إلغاء الاشتراك في كورس
  Future<bool> unenrollFromCourse(String userId, String courseId) async {
    return await _executeWithRLSHandling(
      () async {
        await _client
            .from(enrollmentsTable)
            .delete()
            .eq('user_id', userId)
            .eq('course_id', courseId);
        return true;
      },
      false,
      'unenrollFromCourse',
    );
  }

  /// التحقق من اشتراك المستخدم في كورس
  Future<bool> isUserEnrolled(String userId, String courseId) async {
    return await _executeWithRLSHandling(
      () async {
        final response = await _client
            .from(enrollmentsTable)
            .select()
            .eq('user_id', userId)
            .eq('course_id', courseId)
            .limit(1);

        return response.isNotEmpty;
      },
      false,
      'isUserEnrolled',
    );
  }

  /// الحصول على كورسات الطالب
  Future<List<Course>> getStudentCourses(String userId) async {
    return await _executeWithRLSHandling(
      () async {
        final response = await _client
            .from(enrollmentsTable)
            .select('*, $coursesTable(*)')
            .eq('user_id', userId);

        return (response as List<dynamic>)
            .map((json) => Course.fromJson(json[coursesTable]))
            .toList();
      },
      <Course>[],
      'getStudentCourses',
    );
  }

  /// تحديث تقدم الطالب في كورس
  Future<bool> updateCourseProgress(
      String userId, String courseId, int progress) async {
    try {
      await _client
          .from(enrollmentsTable)
          .update({'progress': progress})
          .eq('user_id', userId)
          .eq('course_id', courseId);
      return true;
    } catch (e) {
      print('Error updating course progress: $e');
      return false;
    }
  }

  /// إضافة تقييم لكورس
  Future<bool> addCourseReview(
      String userId, String courseId, double rating, String comment) async {
    try {
      await _client.from(reviewsTable).insert({
        'user_id': userId,
        'course_id': courseId,
        'rating': rating,
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error adding course review: $e');
      return false;
    }
  }

  /// الحصول على تقييمات كورس
  Future<List<Map<String, dynamic>>> getCourseReviews(String courseId) async {
    try {
      final response = await _client
          .from(reviewsTable)
          .select('*, $usersTable(name, avatar)')
          .eq('course_id', courseId);

      return response;
    } catch (e) {
      print('Error getting course reviews: $e');
      return [];
    }
  }

  /// الحصول على قائمة المستخدمين (للإدارة)
  Future<List<User>> getUsers({
    UserRole? role,
    String? search,
    int? limit,
    int? offset,
  }) async {
    try {
      dynamic query = _client.from(usersTable).select();

      // تطبيق الفلاتر
      if (role != null) {
        query = query.eq('role', role.toString().split('.').last);
      }

      if (search != null && search.isNotEmpty) {
        query = query.or('name.ilike.%$search%,email.ilike.%$search%');
      }

      // تطبيق الحد والإزاحة
      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;

      return (response as List<dynamic>)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  /// تحديث حالة المستخدم (تفعيل/تعطيل)
  Future<bool> updateUserStatus(String userId, bool isActive) async {
    try {
      await _client
          .from(usersTable)
          .update({'is_active': isActive}).eq('id', userId);
      return true;
    } catch (e) {
      print('Error updating user status: $e');
      return false;
    }
  }

  /// رفع ملف إلى تخزين Supabase
  Future<String?> uploadFile(String bucket, String path, List<int> fileBytes,
      String contentType) async {
    try {
      final Uint8List bytes =
          fileBytes is Uint8List ? fileBytes : Uint8List.fromList(fileBytes);
      await _client.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType),
          );

      // إرجاع رابط الملف
      return _client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  /// حذف ملف من تخزين Supabase
  Future<bool> deleteFile(String bucket, String path) async {
    try {
      await _client.storage.from(bucket).remove([path]);
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  /// الحصول على جميع المستخدمين
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _client.from(usersTable).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting all users: $e');
      return [];
    }
  }

  /// الحصول على كورسات المدرب
  Future<List<Map<String, dynamic>>> getInstructorCourses(String instructorId) async {
    try {
      final response = await _client
          .from(coursesTable)
          .select('*, $usersTable(name, avatar)')
          .eq('instructor_id', instructorId);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting instructor courses: $e');
      return [];
    }
  }

  /// الحصول على الكورسات المميزة
  Future<List<Map<String, dynamic>>> getFeaturedCourses() async {
    try {
      final response = await _client
          .from(coursesTable)
          .select('*, $usersTable(name, avatar)')
          .eq('is_featured', true)
          .eq('status', 'published')
          .limit(10);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting featured courses: $e');
      return [];
    }
  }

  /// الحصول على كورسات الطالب
  Future<List<Map<String, dynamic>>> getStudentCourses(String studentId) async {
    try {
      final response = await _client
          .from(enrollmentsTable)
          .select('*, courses(*, $usersTable(name, avatar))')
          .eq('user_id', studentId);
      
      final courses = <Map<String, dynamic>>[];
      for (final enrollment in response) {
        final course = enrollment['courses'] as Map<String, dynamic>;
        // Add progress information from enrollment
        course['progress'] = enrollment['progress'] as int? ?? 0;
        courses.add(course);
      }
      
      return courses;
    } catch (e) {
      print('Error getting student courses: $e');
      return [];
    }
  }

  /// الحصول على عمليات البحث الحديثة
  Future<List<String>> getRecentSearches(String userId) async {
    try {
      // This would typically be stored in a separate table
      // For now, we'll return an empty list and let the UI fallback to mock data
      return [];
    } catch (e) {
      print('Error getting recent searches: $e');
      return [];
    }
  }

  /// الحصول على عمليات البحث الشائعة
  Future<List<String>> getPopularSearches() async {
    try {
      // This would typically be stored in a separate table or calculated from search logs
      // For now, we'll return an empty list and let the UI fallback to mock data
      return [];
    } catch (e) {
      print('Error getting popular searches: $e');
      return [];
    }
  }

  /// الحصول على التصنيفات مع أعداد الكورسات
  Future<List<Map<String, dynamic>>> getCategoriesWithCounts() async {
    try {
      final response = await _client
          .from(categoriesTable)
          .select('*, courses(count)')
          .order('name');
      
      final result = <Map<String, dynamic>>[];
      for (final category in response) {
        result.add({
          'name': category['name'] as String,
          'count': category['courses']['count'] as int,
          'icon': null, // Icon would need to be mapped separately
        });
      }
      
      return result;
    } catch (e) {
      print('Error getting categories with counts: $e');
      return [];
    }
  }

  // ----------------------------
  // Payment / Bank accounts APIs
  // ----------------------------

  Future<List<Map<String, dynamic>>> getBankAccounts(String userId) async {
    try {
      final response =
          await _client.from('bank_accounts').select().eq('user_id', userId);
      return (response as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting bank accounts: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> addBankAccount(
      Map<String, dynamic> data) async {
    try {
      final response =
          await _client.from('bank_accounts').insert(data).select().single();
      return response;
    } catch (e) {
      print('Error adding bank account: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateBankAccount(
      String id, Map<String, dynamic> data) async {
    try {
      final response = await _client
          .from('bank_accounts')
          .update(data)
          .eq('id', id)
          .select()
          .single();
      return response;
    } catch (e) {
      print('Error updating bank account: $e');
      return null;
    }
  }

  Future<bool> deleteBankAccount(String id) async {
    try {
      await _client.from('bank_accounts').delete().eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting bank account: $e');
      return false;
    }
  }

  Future<bool> setBankAccountAsDefault(String id) async {
    try {
      // جلب الحساب لمعرفة user_id
      final account =
          await _client.from('bank_accounts').select().eq('id', id).single();
      final userId = account['user_id'];

      // إلغاء تعيين أي حساب افتراضي لهذا المستخدم
      await _client
          .from('bank_accounts')
          .update({'is_default': false}).eq('user_id', userId);

      // تعيين الحساب المطلوب كافتراضي
      await _client
          .from('bank_accounts')
          .update({'is_default': true}).eq('id', id);
      return true;
    } catch (e) {
      print('Error setting bank account as default: $e');
      return false;
    }
  }

  // ----------------------------
  // Transactions / Payments
  // ----------------------------

  Future<Map<String, dynamic>> getTransactions(String userId,
      {int page = 1, int limit = 20}) async {
    try {
      final from = (page - 1) * limit;
      final to = from + limit - 1;

      final response = await _client
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(from, to);

      // لاحقاً يمكن استخدام خيار count من Supabase إن كان مدعوماً في النسخة
      // حالياً نحدد العدد بطلب جميع المعاملات للمستخدم ثم حساب الطول (آمن كحل مؤقت)
      int totalCount = 0;
      try {
        final all =
            await _client.from('transactions').select().eq('user_id', userId);
        totalCount = (all as List).length;
      } catch (_) {
        totalCount = (response as List<dynamic>).length;
      }

      return {
        'data': (response as List<dynamic>)
            .map((e) => e as Map<String, dynamic>)
            .toList(),
        'total_pages': (totalCount / limit).ceil(),
        'total_count': totalCount,
      };
    } catch (e) {
      print('Error getting transactions: $e');
      return {'data': [], 'total_pages': 1, 'total_count': 0};
    }
  }

  Future<Map<String, dynamic>?> getTransactionDetails(
      String transactionId) async {
    try {
      final response = await _client
          .from('transactions')
          .select()
          .eq('id', transactionId)
          .single();
      return response;
    } catch (e) {
      print('Error getting transaction details: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createTransaction(
      Map<String, dynamic> data) async {
    try {
      final response =
          await _client.from('transactions').insert(data).select().single();
      return response;
    } catch (e) {
      print('Error creating transaction: $e');
      return null;
    }
  }

  Future<bool> cancelTransaction(String transactionId, {String? reason}) async {
    try {
      await _client.from('transactions').update(
          {'status': 'cancelled', 'notes': reason}).eq('id', transactionId);
      return true;
    } catch (e) {
      print('Error cancelling transaction: $e');
      return false;
    }
  }

  Future<bool> updateTransactionReceipt(
      String transactionId, String receiptUrl) async {
    try {
      await _client
          .from('transactions')
          .update({'receipt_url': receiptUrl}).eq('id', transactionId);
      return true;
    } catch (e) {
      print('Error updating transaction receipt: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> initiateCoursePayment(
      String userId, String courseId, double amount, String currency) async {
    try {
      final data = {
        'user_id': userId,
        'course_id': courseId,
        'amount': amount,
        'currency': currency,
        'type': 'purchase',
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response =
          await _client.from('transactions').insert(data).select().single();
      return {'transaction_id': response['id']};
    } catch (e) {
      print('Error initiating course payment: $e');
      return null;
    }
  }

  Future<bool> completeCoursePayment(
      String transactionId, String referenceNumber) async {
    try {
      await _client.from('transactions').update({
        'status': 'completed',
        'reference_number': referenceNumber,
        'completed_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', transactionId);
      return true;
    } catch (e) {
      print('Error completing course payment: $e');
      return false;
    }
  }

  // ----------------------------
  // Bank Transfer System - New APIs
  // ----------------------------

  /// تسجيل معاملة بنكية جديدة
  Future<String?> createBankTransaction({
    required String userId,
    required String courseId,
    required String fromAccount,
    required String toAccount,
    required double amount,
    String currency = 'SAR',
    String? description,
    String serviceType = 'simulation',
  }) async {
    try {
      final response = await _client
          .from('bank_transactions')
          .insert({
            'user_id': userId,
            'course_id': courseId,
            'from_account': fromAccount,
            'to_account': toAccount,
            'amount': amount,
            'currency': currency,
            'description': description ?? 'تحويل أموال لدفع رسوم الكورس',
            'service_type': serviceType,
            'status': 'pending',
            'created_at': DateTime.now().toIso8601String(),
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      print('Error creating bank transaction: $e');
      return null;
    }
  }

  /// تحديث حالة المعاملة البنكية
  Future<bool> updateBankTransactionStatus(
    String transactionId,
    String status, {
    String? errorMessage,
    String? referenceNumber,
    DateTime? completedAt,
  }) async {
    try {
      final updateData = {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (errorMessage != null) {
        updateData['error_message'] = errorMessage;
      }

      if (referenceNumber != null) {
        updateData['reference_number'] = referenceNumber;
      }

      if (completedAt != null) {
        updateData['completed_at'] = completedAt.toIso8601String();
      }

      await _client
          .from('bank_transactions')
          .update(updateData)
          .eq('id', transactionId);
      return true;
    } catch (e) {
      print('Error updating bank transaction status: $e');
      return false;
    }
  }

  /// الحصول على تاريخ المعاملات البنكية للمستخدم
  Future<List<Map<String, dynamic>>> getBankTransactions(
    String userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _client
          .from('bank_transactions')
          .select('*, courses(title, thumbnail_url)')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting bank transactions: $e');
      return [];
    }
  }

  /// الحصول على تفاصيل معاملة بنكية
  Future<Map<String, dynamic>?> getBankTransactionDetails(
    String transactionId,
  ) async {
    try {
      final response = await _client
          .from('bank_transactions')
          .select('*, courses(title, thumbnail_url), users(name, email)')
          .eq('id', transactionId)
          .single();

      return response;
    } catch (e) {
      print('Error getting bank transaction details: $e');
      return null;
    }
  }

  /// الحصول على حسابات المحاكاة
  Future<List<Map<String, dynamic>>> getSimulationAccounts() async {
    try {
      final response = await _client
          .from('simulation_accounts')
          .select()
          .eq('is_active', true)
          .order('account_number');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting simulation accounts: $e');
      return [];
    }
  }

  /// تحديث رصيد حساب المحاكاة
  Future<bool> updateSimulationAccountBalance(
    String accountNumber,
    double newBalance,
  ) async {
    try {
      await _client.from('simulation_accounts').update({
        'balance': newBalance,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('account_number', accountNumber);
      return true;
    } catch (e) {
      print('Error updating simulation account balance: $e');
      return false;
    }
  }

  /// التحقق من صحة حساب المحاكاة
  Future<bool> validateSimulationAccount(String accountNumber) async {
    try {
      final response = await _client
          .from('simulation_accounts')
          .select('account_number')
          .eq('account_number', accountNumber)
          .eq('is_active', true)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      print('Error validating simulation account: $e');
      return false;
    }
  }

  /// الحصول على رصيد حساب المحاكاة
  Future<double?> getSimulationAccountBalance(String accountNumber) async {
    try {
      final response = await _client
          .from('simulation_accounts')
          .select('balance')
          .eq('account_number', accountNumber)
          .eq('is_active', true)
          .single();

      return (response['balance'] as num).toDouble();
    } catch (e) {
      print('Error getting simulation account balance: $e');
      return null;
    }
  }

  // ----------------------------
  // Additional User Management
  // ----------------------------

  /// حذف مستخدم (للمدير)
  Future<bool> deleteUser(String userId) async {
    try {
      // حذف جميع الاشتراكات المرتبطة بالمستخدم
      await _client.from(enrollmentsTable).delete().eq('user_id', userId);

      // حذف جميع التقييمات المرتبطة بالمستخدم
      await _client.from(reviewsTable).delete().eq('user_id', userId);

      // حذف جميع الرسائل المرتبطة بالمستخدم
      await _client
          .from('messages')
          .delete()
          .or('sender_id.eq.$userId,receiver_id.eq.$userId');

      // حذف جميع المعاملات المرتبطة بالمستخدم
      await _client.from('transactions').delete().eq('user_id', userId);

      // حذف جميع الحسابات البنكية
      await _client.from('bank_accounts').delete().eq('user_id', userId);

      // حذف المستخدم من جدول المستخدمين
      await _client.from(usersTable).delete().eq('id', userId);

      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  /// الحصول على الفئات
  Future<List<Map<String, dynamic>>> getCategories() async {
    return await _executeWithRLSHandling(
      () async {
        final response = await _client.from(categoriesTable).select();
        return List<Map<String, dynamic>>.from(response);
      },
      <Map<String, dynamic>>[],
      'getCategories',
    );
  }

  /// الحصول على الكورسات الموصى بها
  Future<List<Course>> getRecommendedCourses(String userId) async {
    return await _executeWithRLSHandling(
      () async {
        // في الوقت الحالي نعيد قائمة عشوائية من الكورسات
        // يمكن تحسين هذا لاحقاً بناءً على اهتمامات المستخدم
        final response = await _client
            .from(coursesTable)
            .select('*, $usersTable(name, avatar)')
            .limit(10);

        return (response as List<dynamic>)
            .map((json) => Course.fromJson(json))
            .toList();
      },
      <Course>[],
      'getRecommendedCourses',
    );
  }

  /// الحصول على إحصائيات الكورس
  Future<Map<String, dynamic>> getCourseStats(String courseId) async {
    return await _executeWithRLSHandling(
      () async {
        // جلب عدد الطلاب المسجلين في الكورس
        final enrollmentCountResponse = await _client
            .from(enrollmentsTable)
            .select('count()')
            .eq('course_id', courseId)
            .single();

        // جلب متوسط التقييمات
        final avgRatingResponse = await _client
            .from(reviewsTable)
            .select('rating')
            .eq('course_id', courseId);

        final ratings =
            (avgRatingResponse as List<dynamic>).map((r) => r['rating'] as num);
        final avgRating = ratings.isEmpty
            ? 0.0
            : ratings.reduce((a, b) => a + b) / ratings.length;

        return {
          'enrollment_count': enrollmentCountResponse['count'] ?? 0,
          'average_rating': avgRating,
        };
      },
      {},
      'getCourseStats',
    );
  }

  /// الحصول على إحصائيات المستخدم
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    return await _executeWithRLSHandling(
      () async {
        // جلب عدد الكورسات التي سجل فيها المستخدم
        final enrollmentCountResponse = await _client
            .from(enrollmentsTable)
            .select('count()')
            .eq('user_id', userId)
            .single();

        // جلب عدد التقييمات التي قدمها المستخدم
        final reviewCountResponse = await _client
            .from(reviewsTable)
            .select('count()')
            .eq('user_id', userId)
            .single();

        return {
          'enrollment_count': enrollmentCountResponse['count'] ?? 0,
          'review_count': reviewCountResponse['count'] ?? 0,
        };
      },
      {},
      'getUserStats',
    );
  }

  /// الحصول على إحصائيات النظام (للمدير)
  Future<Map<String, dynamic>> getSystemStats() async {
    return await _executeWithRLSHandling(
      () async {
        // جلب عدد المستخدمين
        final userCountResponse =
            await _client.from(usersTable).select('count()').single();

        // جلب عدد الكورسات
        final courseCountResponse =
            await _client.from(coursesTable).select('count()').single();

        // جلب عدد التسجيلات المعلقة
        final pendingCountResponse = await _client
            .from(pendingRegistrationsTable)
            .select('count()')
            .eq('status', 'pending')
            .single();

        return {
          'user_count': userCountResponse['count'] ?? 0,
          'course_count': courseCountResponse['count'] ?? 0,
          'pending_registrations_count': pendingCountResponse['count'] ?? 0,
        };
      },
      {},
      'getSystemStats',
    );
  }

  /// الحصول على طلاب كورس معين
  Future<List<User>> getCourseStudents(String courseId) async {
    return await _executeWithRLSHandling(
      () async {
        final response = await _client
            .from(enrollmentsTable)
            .select('*, $usersTable(*)')
            .eq('course_id', courseId);

        return (response as List<dynamic>)
            .map((json) => User.fromJson(json[usersTable]))
            .toList();
      },
      <User>[],
      'getCourseStudents',
    );
  }

  /// إرسال رسالة
  Future<bool> sendMessage({
    required String fromUserId,
    required String toUserId,
    required String message,
  }) async {
    return await _executeWithRLSHandling(
      () async {
        await _client.from('messages').insert({
          'sender_id': fromUserId,
          'receiver_id': toUserId,
          'message': message,
          'sent_at': DateTime.now().toIso8601String(),
          'is_read': false,
        });
        return true;
      },
      false,
      'sendMessage',
    );
  }

  /// جلب الرسائل بين مستخدمين
  Future<List<Map<String, dynamic>>> getMessages({
    required String userId1,
    required String userId2,
    int limit = 50,
  }) async {
    return await _executeWithRLSHandling(
      () async {
        final response = await _client
            .from('messages')
            .select()
            .or('sender_id.eq.$userId1,and(receiver_id.eq.$userId2)')
            .or('sender_id.eq.$userId2,and(receiver_id.eq.$userId1)')
            .order('sent_at', ascending: false)
            .limit(limit);

        return List<Map<String, dynamic>>.from(response);
      },
      <Map<String, dynamic>>[],
      'getMessages',
    );
  }

  /// الحصول على جميع معاملات المستخدم
  Future<List<Map<String, dynamic>>> getUserTransactions(String userId) async {
    try {
      // الحصول على معاملات الدفع من جدول transactions
      final transactionsResponse = await _client
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // الحصول على معاملات البنك من جدول bank_transactions
      final bankTransactionsResponse = await _client
          .from('bank_transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // دمج المعاملات من الجدولين
      final allTransactions = <Map<String, dynamic>>[];

      allTransactions.addAll(transactionsResponse
          .map((e) => e)
          .toList());
    
      allTransactions.addAll(bankTransactionsResponse
          .map((e) => e)
          .toList());
    
      // ترتيب المعاملات حسب التاريخ
      allTransactions.sort((a, b) {
        final dateA = (a['created_at'] as String).isNotEmpty
            ? DateTime.parse(a['created_at'])
            : DateTime.now();
        final dateB = (b['created_at'] as String).isNotEmpty
            ? DateTime.parse(b['created_at'])
            : DateTime.now();
        return dateB.compareTo(dateA); // ترتيب تنازلي (الأحدث أولاً)
      });

      return allTransactions;
    } catch (e) {
      print('Error getting user transactions: $e');
      return [];
    }
  }
}
