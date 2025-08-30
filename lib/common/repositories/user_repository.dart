import '../models/user.dart';
import '../services/supabase_service.dart';
import '../services/local_storage_service.dart';
import '../services/sync_service.dart';

class UserRepository {
  final SupabaseService _supabaseService;
  final LocalStorageService _localStorageService;
  final SyncService _syncService;

  UserRepository({
    required SupabaseService supabaseService,
    required LocalStorageService localStorageService,
    required SyncService syncService,
  })  : _supabaseService = supabaseService,
        _localStorageService = localStorageService,
        _syncService = syncService;

  // جلب جميع المستخدمين (للمدير)
  Future<List<User>> getAllUsers({
    int limit = 20,
    int offset = 0,
    String? role,
    String? searchQuery,
  }) async {
    try {
      final users = await _supabaseService.getUsers(
        role: role != null
            ? UserRole.values.firstWhere((r) => r.name == role)
            : null,
        search: searchQuery,
        limit: limit,
        offset: offset,
      );

      // حفظ المستخدمين محلياً
      final usersData = users.map((u) => u.toJson()).toList();
      await _localStorageService.saveUsers(usersData);
      return users;
    } catch (e) {
      // جلب المستخدمين من التخزين المحلي
      final cachedUsers = _localStorageService.getUsers();
      return cachedUsers.map((data) => User.fromJson(data)).toList();
    }
  }

  // جلب مستخدم واحد
  Future<User?> getUserById(String userId) async {
    try {
      final user = await _supabaseService.getUserDetails(userId);
      if (user != null) {
        // حفظ المستخدم محلياً
        await _localStorageService.saveUser(user.toJson());
      }
      return user;
    } catch (e) {
      // جلب المستخدم من التخزين المحلي
      final cachedUser = _localStorageService.getUserById(userId);
      return cachedUser != null ? User.fromJson(cachedUser) : null;
    }
  }

  // جلب الطلاب (للمدرب)
  Future<List<User>> getStudents({
    int limit = 20,
    int offset = 0,
    String? searchQuery,
  }) async {
    try {
      final students = await _supabaseService.getUsers(
        role: UserRole.student,
        search: searchQuery,
        limit: limit,
        offset: offset,
      );

      // حفظ الطلاب محلياً
      final studentsData = students.map((u) => u.toJson()).toList();
      await _localStorageService.saveUsers(studentsData);
      return students;
    } catch (e) {
      // جلب الطلاب من التخزين المحلي
      final cachedStudents = _localStorageService.getStudents();
      return cachedStudents.map((data) => User.fromJson(data)).toList();
    }
  }

  // جلب المدربين
  Future<List<User>> getInstructors({
    int limit = 20,
    int offset = 0,
    String? searchQuery,
  }) async {
    try {
      final instructors = await _supabaseService.getUsers(
        role: UserRole.instructor,
        search: searchQuery,
        limit: limit,
        offset: offset,
      );

      // حفظ المدربين محلياً
      final instructorsData = instructors.map((u) => u.toJson()).toList();
      await _localStorageService.saveUsers(instructorsData);
      return instructors;
    } catch (e) {
      // جلب المدربين من التخزين المحلي
      final cachedInstructors = _localStorageService.getInstructors();
      return cachedInstructors.map((data) => User.fromJson(data)).toList();
    }
  }

  // تحديث دور المستخدم (للمدير)
  Future<User?> updateUserRole({
    required String userId,
    required String newRole,
  }) async {
    try {
      final success = await _supabaseService.updateUserProfile(
        userId,
        {'role': newRole},
      );

      if (success) {
        return await _supabaseService.getUserDetails(userId);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // حظر/إلغاء حظر مستخدم (للمدير)
  Future<User?> toggleUserStatus({
    required String userId,
    required bool isActive,
  }) async {
    try {
      final success = await _supabaseService.updateUserStatus(userId, isActive);
      if (success) {
        return await _supabaseService.getUserDetails(userId);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // حذف مستخدم (للمدير)
  Future<bool> deleteUser(String userId) async {
    try {
      return await _supabaseService.deleteUser(userId);
    } catch (e) {
      rethrow;
    }
  }

  // جلب إحصائيات المستخدم
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      return await _supabaseService.getUserStats(userId);
    } catch (e) {
      return {};
    }
  }

  // جلب إحصائيات النظام (للمدير)
  Future<Map<String, dynamic>> getSystemStats() async {
    try {
      return await _supabaseService.getSystemStats();
    } catch (e) {
      return {};
    }
  }

  // البحث في المستخدمين
  Future<List<User>> searchUsers(String query) async {
    try {
      final users = await _supabaseService.getUsers(search: query);
      // حفظ المستخدمين محلياً
      final usersData = users.map((u) => u.toJson()).toList();
      await _localStorageService.saveUsers(usersData);
      return users;
    } catch (e) {
      // جلب المستخدمين من التخزين المحلي
      final cachedUsers = _localStorageService.searchUsers(query);
      return cachedUsers.map((data) => User.fromJson(data)).toList();
    }
  }

  // جلب طلاب كورس معين (للمدرب)
  Future<List<User>> getCourseStudents(String courseId) async {
    try {
      final students = await _supabaseService.getCourseStudents(courseId);
      // حفظ البيانات محلياً (قم بتنفيذه في LocalStorageService)
      final usersData = students.map((u) => u.toJson()).toList();
      await _localStorageService.saveUsers(usersData);
      return students;
    } catch (e) {
      // محاولة جلب البيانات من التخزين المحلي
      final cachedStudents =
          _localStorageService.getCourseStudents(courseId);
      return cachedStudents.map((data) => User.fromJson(data)).toList();
    }
  }

  // إرسال رسالة لمستخدم
  Future<bool> sendMessage({
    required String fromUserId,
    required String toUserId,
    required String message,
  }) async {
    try {
      final success = await _supabaseService.sendMessage(
        fromUserId: fromUserId,
        toUserId: toUserId,
        message: message,
      );

      // حفظ الرسالة محلياً
      if (success) {
        await _localStorageService.saveMessage({
          'sender_id': fromUserId,
          'receiver_id': toUserId,
          'message': message,
          'sent_at': DateTime.now().toIso8601String(),
          'is_read': false,
        });
      }

      return success;
    } catch (e) {
      // حفظ الرسالة في قائمة الإجراءات المعلقة
      await _localStorageService.addPendingAction({
        'type': 'send_message',
        'data': {
          'fromUserId': fromUserId,
          'toUserId': toUserId,
          'message': message,
        },
      });
      rethrow;
    }
  }

  // جلب الرسائل
  Future<List<Map<String, dynamic>>> getMessages({
    required String userId1,
    required String userId2,
    int limit = 50,
  }) async {
    try {
      final messages = await _supabaseService.getMessages(
        userId1: userId1,
        userId2: userId2,
        limit: limit,
      );

      // حفظ الرسائل محلياً
      for (final message in messages) {
        await _localStorageService.saveMessage(message);
      }

      return messages;
    } catch (e) {
      // جلب الرسائل من التخزين المحلي
      return _localStorageService.getMessagesBetweenUsers(
          userId1, userId2);
    }
  }

  // تحديث صورة الملف الشخصي
  Future<User?> updateProfileImage({
    required String userId,
    required String imageUrl,
  }) async {
    try {
      final success = await _supabaseService.updateUserProfile(
        userId,
        {'avatar': imageUrl},
      );

      if (success) {
        return await _supabaseService.getUserDetails(userId);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // مزامنة البيانات
  Future<void> syncData() async {
    await _syncService.syncUsers();
    await _syncService.syncPendingActions();
  }
}
