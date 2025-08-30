import 'dart:async';
import 'package:flutter/foundation.dart';
import 'connectivity_service.dart';
import 'local_storage_service.dart';
import 'supabase_service.dart';

/// خدمة المزامنة بين التخزين المحلي وقاعدة البيانات
class SyncService {
  final ConnectivityService _connectivityService;
  final LocalStorageService _localStorageService;
  final SupabaseService _supabaseService;

  StreamSubscription? _connectivitySubscription;
  Timer? _syncTimer;

  // فترة المزامنة التلقائية (5 دقائق)
  static const Duration syncInterval = Duration(minutes: 5);

  SyncService({
    required ConnectivityService connectivityService,
    required LocalStorageService localStorageService,
    required SupabaseService supabaseService,
  })  : _connectivityService = connectivityService,
        _localStorageService = localStorageService,
        _supabaseService = supabaseService {
    // الاستماع لتغييرات حالة الاتصال
    _connectivitySubscription =
        _connectivityService.connectionStatus.listen(_handleConnectivityChange);

    // بدء المزامنة الدورية
    _startPeriodicSync();
  }

  /// معالجة تغيير حالة الاتصال
  void _handleConnectivityChange(bool isConnected) {
    if (isConnected) {
      // عند استعادة الاتصال، قم بمزامنة الإجراءات المعلقة
      syncPendingActions();
    }
  }

  /// بدء المزامنة الدورية
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(syncInterval, (_) {
      if (_connectivityService.isConnected) {
        syncPendingActions();
      }
    });
  }

  /// مزامنة الإجراءات المعلقة
  Future<void> syncPendingActions() async {
    if (!_connectivityService.isConnected) {
      if (kDebugMode) {
        print('No internet connection. Sync skipped.');
      }
      return;
    }

    final pendingActions = _localStorageService.getPendingActions();
    if (pendingActions == null || pendingActions.isEmpty) {
      if (kDebugMode) {
        print('No pending actions to sync.');
      }
      return;
    }

    if (kDebugMode) {
      print('Syncing ${pendingActions.length} pending actions...');
    }

    // معالجة كل إجراء معلق
    for (final action in pendingActions) {
      await _processPendingAction(action);
    }

    // مسح الإجراءات المعلقة بعد المزامنة
    await _localStorageService.clearPendingActions();

    // تحديث وقت آخر مزامنة
    await _localStorageService.saveLastSyncTime(DateTime.now());

    if (kDebugMode) {
      print('Sync completed successfully.');
    }
  }

  /// معالجة إجراء معلق واحد
  Future<void> _processPendingAction(Map<String, dynamic> action) async {
    final String type = action['type'] as String;
    final String entity = action['entity'] as String;
    final Map<String, dynamic> data = action['data'] as Map<String, dynamic>;

    try {
      switch (type) {
        case 'create':
          await _handleCreateAction(entity, data);
          break;
        case 'update':
          final String id = action['id'] as String;
          await _handleUpdateAction(entity, id, data);
          break;
        case 'delete':
          final String id = action['id'] as String;
          await _handleDeleteAction(entity, id);
          break;
        default:
          if (kDebugMode) {
            print('Unknown action type: $type');
          }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing action $type on $entity: $e');
      }
    }
  }

  /// معالجة إجراء إنشاء
  Future<void> _handleCreateAction(
      String entity, Map<String, dynamic> data) async {
    switch (entity) {
      case 'course':
        await _supabaseService.createCourse(data);
        break;
      case 'enrollment':
        await _supabaseService.enrollInCourse(
          data['user_id'] as String,
          data['course_id'] as String,
        );
        break;
      case 'review':
        await _supabaseService.addCourseReview(
          data['user_id'] as String,
          data['course_id'] as String,
          data['rating'] as double,
          data['comment'] as String,
        );
        break;
      case 'message':
      case 'send_message':
        await _supabaseService.sendMessage(
          fromUserId: data['fromUserId'] as String,
          toUserId: data['toUserId'] as String,
          message: data['message'] as String,
        );
        break;
      default:
        if (kDebugMode) {
          print('Unknown entity for create action: $entity');
        }
    }
  }

  /// معالجة إجراء تحديث
  Future<void> _handleUpdateAction(
      String entity, String id, Map<String, dynamic> data) async {
    switch (entity) {
      case 'user':
        await _supabaseService.updateUserProfile(id, data);
        break;
      case 'course':
        await _supabaseService.updateCourse(id, data);
        break;
      case 'progress':
        await _supabaseService.updateCourseProgress(
          data['user_id'] as String,
          id, // course_id
          data['progress'] as int,
        );
        break;
      default:
        if (kDebugMode) {
          print('Unknown entity for update action: $entity');
        }
    }
  }

  /// معالجة إجراء حذف
  Future<void> _handleDeleteAction(String entity, String id) async {
    switch (entity) {
      case 'course':
        await _supabaseService.deleteCourse(id);
        break;
      default:
        if (kDebugMode) {
          print('Unknown entity for delete action: $entity');
        }
    }
  }

  /// إضافة إجراء معلق للمزامنة
  Future<void> addPendingAction(Map<String, dynamic> action) async {
    await _localStorageService.addPendingAction(action);

    // محاولة المزامنة الفورية إذا كان هناك اتصال
    if (_connectivityService.isConnected) {
      syncPendingActions();
    }
  }

  /// مزامنة بيانات المستخدمين
  Future<void> syncUsers() async {
    if (!_connectivityService.isConnected) {
      if (kDebugMode) {
        print('No internet connection. Users sync skipped.');
      }
      return;
    }

    try {
      // جلب المستخدمين من الخادم
      final serverUsers = await _supabaseService.getUsers();

      // حفظ البيانات محلياً
      final usersData = serverUsers.map((user) => user.toJson()).toList();
      await _localStorageService.saveUsers(usersData);

      if (kDebugMode) {
        print('Users sync completed successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing users: $e');
      }
    }
  }

  /// مزامنة بيانات الكورسات
  Future<void> syncCourses() async {
    if (!_connectivityService.isConnected) {
      if (kDebugMode) {
        print('No internet connection. Courses sync skipped.');
      }
      return;
    }

    try {
      // جلب الكورسات من الخادم
      final serverCourses = await _supabaseService.getCourses();

      // حفظ البيانات محلياً
      final coursesData =
          serverCourses.map((course) => course.toJson()).toList();
      await _localStorageService.saveCoursesData(coursesData);

      if (kDebugMode) {
        print('Courses sync completed successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing courses: $e');
      }
    }
  }

  /// مزامنة بيانات الفئات
  Future<void> syncCategories() async {
    if (!_connectivityService.isConnected) {
      if (kDebugMode) {
        print('No internet connection. Categories sync skipped.');
      }
      return;
    }

    try {
      // جلب الفئات من الخادم
      final serverCategories = await _supabaseService.getCategories();

      // حفظ البيانات محلياً
      await _localStorageService.saveCategories(serverCategories);

      if (kDebugMode) {
        print('Categories sync completed successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing categories: $e');
      }
    }
  }

  /// مزامنة شاملة لجميع البيانات
  Future<void> syncAllData() async {
    if (!_connectivityService.isConnected) {
      if (kDebugMode) {
        print('No internet connection. Full sync skipped.');
      }
      return;
    }

    try {
      await Future.wait([
        syncUsers(),
        syncCourses(),
        syncCategories(),
        syncPendingActions(),
      ]);

      if (kDebugMode) {
        print('Full data sync completed successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during full sync: $e');
      }
    }
  }

  /// Compatibility wrapper: بعض أجزاء الكود تستخدم الاسم addPendingOperation
  /// لذا نضيف غطاءً يوجّه النداء إلى addPendingAction
  Future<void> addPendingOperation(
      String type, Map<String, dynamic> payload) async {
    final action = {
      'type': type,
      'entity': payload['entity'] ?? payload['e'] ?? '',
      'id': payload['id'],
      'data': payload['data'] ?? payload,
    };
    await addPendingAction(action);
  }

  /// إيقاف المزامنة وتحرير الموارد
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
  }
}
