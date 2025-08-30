import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة إدارة الإشعارات
class NotificationService {
  static NotificationService? _instance;
  final SupabaseClient _supabaseClient;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final StreamController<Map<String, dynamic>> _notificationStreamController;

  // مفاتيح التخزين المحلي
  static const String _lastNotificationTimeKey = 'last_notification_time';
  static const String _notificationsKey = 'cached_notifications';

  // معرف قناة الإشعارات
  static const String _channelId = 'wasla_notifications';
  static const String _channelName = 'إشعارات وصلة';
  static const String _channelDescription = 'إشعارات منصة وصلة التعليمية';

  /// الحصول على مثيل الخدمة (Singleton)
  static Future<NotificationService> getInstance() async {
    if (_instance == null) {
      final supabaseClient = Supabase.instance.client;
      final localNotifications = FlutterLocalNotificationsPlugin();

      // تهيئة الإشعارات المحلية
      const initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // معالجة النقر على الإشعار
          if (kDebugMode) {
            print('Notification clicked: ${response.payload}');
          }
        },
      );

      _instance = NotificationService._internal(
        supabaseClient,
        localNotifications,
        StreamController<Map<String, dynamic>>.broadcast(),
      );

      // بدء الاستماع للإشعارات الجديدة
      _instance!._startListeningToNotifications();
    }

    return _instance!;
  }

  NotificationService._internal(
    this._supabaseClient,
    this._localNotifications,
    this._notificationStreamController,
  );

  /// تدفق الإشعارات الجديدة
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationStreamController.stream;

  /// بدء الاستماع للإشعارات الجديدة
  void _startListeningToNotifications() {
    // الاستماع للإشعارات الجديدة من Supabase Realtime
    _supabaseClient
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          callback: (payload) {
            _handleNewNotification(payload.newRecord);
          },
        )
        .subscribe();
  }

  /// معالجة إشعار جديد
  void _handleNewNotification(Map<String, dynamic> notification) {
    // إرسال الإشعار إلى التدفق
    _notificationStreamController.add(notification);

    // عرض الإشعار المحلي
    _showLocalNotification(notification);

    // تخزين الإشعار محلياً
    _cacheNotification(notification);
  }

  /// عرض إشعار محلي
  Future<void> _showLocalNotification(Map<String, dynamic> notification) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification['id'].hashCode,
      notification['title'] as String,
      notification['message'] as String,
      notificationDetails,
      payload: jsonEncode(notification),
    );
  }

  /// تخزين الإشعار محلياً
  Future<void> _cacheNotification(Map<String, dynamic> notification) async {
    final prefs = await SharedPreferences.getInstance();

    // الحصول على الإشعارات المخزنة
    final cachedNotificationsJson =
        prefs.getStringList(_notificationsKey) ?? [];
    final cachedNotifications = cachedNotificationsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();

    // إضافة الإشعار الجديد
    cachedNotifications.insert(0, notification);

    // تحديد عدد الإشعارات المخزنة (الاحتفاظ بآخر 50 إشعار)
    if (cachedNotifications.length > 50) {
      cachedNotifications.removeRange(50, cachedNotifications.length);
    }

    // حفظ الإشعارات المحدثة
    final updatedNotificationsJson = cachedNotifications
        .map((notification) => jsonEncode(notification))
        .toList();

    await prefs.setStringList(_notificationsKey, updatedNotificationsJson);

    // تحديث وقت آخر إشعار
    await prefs.setString(
        _lastNotificationTimeKey, DateTime.now().toIso8601String());
  }

  /// الحصول على قائمة الإشعارات
  Future<List<Map<String, dynamic>>> getNotifications({
    required String userId,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _supabaseClient
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List<dynamic>)
          .map((json) => json as Map<String, dynamic>)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting notifications: $e');
      }

      // في حالة الفشل، استخدام الإشعارات المخزنة محلياً
      return _getCachedNotifications(userId);
    }
  }

  /// الحصول على الإشعارات المخزنة محلياً
  Future<List<Map<String, dynamic>>> _getCachedNotifications(
      String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedNotificationsJson =
        prefs.getStringList(_notificationsKey) ?? [];

    return cachedNotificationsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .where((notification) => notification['user_id'] == userId)
        .toList();
  }

  /// الحصول على عدد الإشعارات غير المقروءة
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _supabaseClient
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      return (response as List<dynamic>).length;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting unread count: $e');
      }

      // في حالة الفشل، استخدام الإشعارات المخزنة محلياً
      final cachedNotifications = await _getCachedNotifications(userId);
      return cachedNotifications
          .where((notification) => notification['is_read'] == false)
          .length;
    }
  }

  /// تحديد إشعار كمقروء
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _supabaseClient
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);

      // تحديث الإشعار المخزن محلياً
      await _updateCachedNotification(notificationId, {'is_read': true});

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error marking notification as read: $e');
      }
      return false;
    }
  }

  /// تحديد جميع الإشعارات كمقروءة
  Future<bool> markAllAsRead(String userId) async {
    try {
      await _supabaseClient
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      // تحديث الإشعارات المخزنة محلياً
      await _updateAllCachedNotifications(userId, {'is_read': true});

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error marking all notifications as read: $e');
      }
      return false;
    }
  }

  /// حذف إشعار
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _supabaseClient
          .from('notifications')
          .delete()
          .eq('id', notificationId);

      // حذف الإشعار من التخزين المحلي
      await _removeCachedNotification(notificationId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting notification: $e');
      }
      return false;
    }
  }

  /// حذف جميع الإشعارات
  Future<bool> deleteAllNotifications(String userId) async {
    try {
      await _supabaseClient
          .from('notifications')
          .delete()
          .eq('user_id', userId);

      // حذف الإشعارات من التخزين المحلي
      await _removeAllCachedNotifications(userId);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting all notifications: $e');
      }
      return false;
    }
  }

  /// إنشاء إشعار جديد
  Future<bool> createNotification(Map<String, dynamic> notificationData) async {
    try {
      await _supabaseClient.from('notifications').insert(notificationData);

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating notification: $e');
      }
      return false;
    }
  }

  /// تحديث إشعار مخزن محلياً
  Future<void> _updateCachedNotification(
      String notificationId, Map<String, dynamic> updates) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedNotificationsJson =
        prefs.getStringList(_notificationsKey) ?? [];

    final cachedNotifications = cachedNotificationsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();

    for (int i = 0; i < cachedNotifications.length; i++) {
      if (cachedNotifications[i]['id'] == notificationId) {
        cachedNotifications[i].addAll(updates);
        break;
      }
    }

    final updatedNotificationsJson = cachedNotifications
        .map((notification) => jsonEncode(notification))
        .toList();

    await prefs.setStringList(_notificationsKey, updatedNotificationsJson);
  }

  /// تحديث جميع الإشعارات المخزنة محلياً
  Future<void> _updateAllCachedNotifications(
      String userId, Map<String, dynamic> updates) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedNotificationsJson =
        prefs.getStringList(_notificationsKey) ?? [];

    final cachedNotifications = cachedNotificationsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();

    for (int i = 0; i < cachedNotifications.length; i++) {
      if (cachedNotifications[i]['user_id'] == userId) {
        cachedNotifications[i].addAll(updates);
      }
    }

    final updatedNotificationsJson = cachedNotifications
        .map((notification) => jsonEncode(notification))
        .toList();

    await prefs.setStringList(_notificationsKey, updatedNotificationsJson);
  }

  /// حذف إشعار من التخزين المحلي
  Future<void> _removeCachedNotification(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedNotificationsJson =
        prefs.getStringList(_notificationsKey) ?? [];

    final cachedNotifications = cachedNotificationsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();

    cachedNotifications
        .removeWhere((notification) => notification['id'] == notificationId);

    final updatedNotificationsJson = cachedNotifications
        .map((notification) => jsonEncode(notification))
        .toList();

    await prefs.setStringList(_notificationsKey, updatedNotificationsJson);
  }

  /// حذف جميع الإشعارات من التخزين المحلي
  Future<void> _removeAllCachedNotifications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedNotificationsJson =
        prefs.getStringList(_notificationsKey) ?? [];

    final cachedNotifications = cachedNotificationsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .where((notification) => notification['user_id'] != userId)
        .toList();

    final updatedNotificationsJson = cachedNotifications
        .map((notification) => jsonEncode(notification))
        .toList();

    await prefs.setStringList(_notificationsKey, updatedNotificationsJson);
  }

  /// إيقاف الخدمة وتحرير الموارد
  void dispose() {
    _notificationStreamController.close();
  }
}
