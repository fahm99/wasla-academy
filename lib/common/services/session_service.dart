import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// خدمة إدارة جلسات المستخدم
class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  static const String _sessionKey = 'user_session';
  static const String _sessionExpiryKey = 'session_expiry';
  static const String _userRoleKey = 'user_role';
  static const String _userStatusKey = 'user_status';

  // مدة صلاحية الجلسة (24 ساعة)
  static const int _sessionDuration = 24 * 60 * 60 * 1000;

  SharedPreferences? _prefs;

  /// تهيئة الخدمة
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// بدء جلسة جديدة للمستخدم
  Future<void> startSession(User user) async {
    if (_prefs == null) await init();

    final expiryTime = DateTime.now().millisecondsSinceEpoch + _sessionDuration;

    await _prefs?.setString(_sessionKey, user.id);
    await _prefs?.setInt(_sessionExpiryKey, expiryTime);
    await _prefs?.setString(_userRoleKey, user.role.name);
    await _prefs?.setString(_userStatusKey, _getUserStatus(user));
  }

  /// التحقق من صلاحية الجلسة
  Future<bool> isSessionValid() async {
    if (_prefs == null) await init();

    final sessionExists = _prefs?.containsKey(_sessionKey) ?? false;
    if (!sessionExists) return false;

    final expiryTime = _prefs?.getInt(_sessionExpiryKey) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    return currentTime < expiryTime;
  }

  /// الحصول على معرف المستخدم الحالي
  String? getCurrentUserId() {
    return _prefs?.getString(_sessionKey);
  }

  /// الحصول على دور المستخدم الحالي
  String? getCurrentUserRole() {
    return _prefs?.getString(_userRoleKey);
  }

  /// الحصول على حالة المستخدم الحالي
  String? getCurrentUserStatus() {
    return _prefs?.getString(_userStatusKey);
  }

  /// تحديث حالة المستخدم في الجلسة
  Future<void> updateUserStatus(User user) async {
    await _prefs?.setString(_userStatusKey, _getUserStatus(user));
  }

  /// إنهاء الجلسة الحالية
  Future<void> endSession() async {
    if (_prefs == null) await init();

    await _prefs?.remove(_sessionKey);
    await _prefs?.remove(_sessionExpiryKey);
    await _prefs?.remove(_userRoleKey);
    await _prefs?.remove(_userStatusKey);
  }

  /// تمديد صلاحية الجلسة
  Future<void> extendSession() async {
    if (_prefs == null) await init();

    final expiryTime = DateTime.now().millisecondsSinceEpoch + _sessionDuration;
    await _prefs?.setInt(_sessionExpiryKey, expiryTime);
  }

  /// الحصول على حالة المستخدم كنص
  String _getUserStatus(User user) {
    // للمدربين، نتحقق من حالة التحقق
    if (user.role == UserRole.instructor) {
      // هنا يمكن التحقق من حالة التحقق من المستندات
      // في الوقت الحالي نستخدم قيمة افتراضية
      return 'pending'; // أو 'verified' أو 'rejected'
    }

    // للطلاب، نتحقق من تفعيل الحساب
    return user.isActive ? 'active' : 'inactive';
  }

  /// التحقق من قيود الوصول حسب الدور
  bool canAccessFeature(String feature, String? userRole, String? userStatus) {
    // تنفيذ منطق التحقق من القيود حسب الدور والحالة
    // هذا مثال بسيط ويمكن توسيعه حسب الحاجة

    if (userRole == null || userStatus == null) return false;

    switch (feature) {
      case 'create_course':
        // فقط المدربون المفعلون يمكنهم إنشاء كورسات
        return userRole == 'instructor' && userStatus == 'verified';

      case 'enroll_course':
        // فقط الطلاب المفعلون يمكنهم التسجيل في كورسات
        return userRole == 'student' && userStatus == 'active';

      case 'access_dashboard':
        // جميع المستخدمين المفعلون يمكنهم الوصول للوحة التحكم
        return userStatus == 'active' || userStatus == 'verified';

      default:
        return false;
    }
  }
}
