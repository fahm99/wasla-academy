import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة التخزين المحلي باستخدام SharedPreferences
class LocalStorageService {
  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;

  // مفاتيح التخزين
  static const String userKey = 'user_data';
  static const String coursesKey = 'courses_data';
  static const String tokenKey = 'auth_token';
  static const String lastSyncKey = 'last_sync_time';
  static const String pendingActionsKey = 'pending_actions';
  static const String paymentsKey = 'payments_data';
  static const String walletKey = 'wallet_data';
  static const String usersKey = 'users_data';
  static const String enrollmentsKey = 'enrollments_data';
  static const String reviewsKey = 'reviews_data';
  static const String categoriesKey = 'categories_data';
  static const String messagesKey = 'messages_data';

  /// الحصول على مثيل الخدمة (Singleton)
  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  /// حفظ بيانات المستخدم
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    return await _preferences!.setString(userKey, jsonEncode(userData));
  }

  /// الحصول على بيانات المستخدم
  Map<String, dynamic>? getUserData() {
    final String? userDataString = _preferences!.getString(userKey);
    if (userDataString == null) return null;
    return jsonDecode(userDataString) as Map<String, dynamic>;
  }

  /// حفظ بيانات الكورسات
  Future<bool> saveCoursesData(List<Map<String, dynamic>> coursesData) async {
    return await _preferences!.setString(coursesKey, jsonEncode(coursesData));
  }

  /// الحصول على بيانات الكورسات
  List<Map<String, dynamic>>? getCoursesData() {
    final String? coursesDataString = _preferences!.getString(coursesKey);
    if (coursesDataString == null) return null;
    final List<dynamic> decodedData =
        jsonDecode(coursesDataString) as List<dynamic>;
    return decodedData.map((item) => item as Map<String, dynamic>).toList();
  }

  /// حفظ رمز المصادقة
  Future<bool> saveAuthToken(String token) async {
    return await _preferences!.setString(tokenKey, token);
  }

  /// الحصول على رمز المصادقة
  String? getAuthToken() {
    return _preferences!.getString(tokenKey);
  }

  /// حفظ وقت آخر مزامنة
  Future<bool> saveLastSyncTime(DateTime time) async {
    return await _preferences!.setString(lastSyncKey, time.toIso8601String());
  }

  /// الحصول على وقت آخر مزامنة
  DateTime? getLastSyncTime() {
    final String? timeString = _preferences!.getString(lastSyncKey);
    if (timeString == null) return null;
    return DateTime.parse(timeString);
  }

  /// حفظ الإجراءات المعلقة للمزامنة
  Future<bool> savePendingActions(List<Map<String, dynamic>> actions) async {
    return await _preferences!
        .setString(pendingActionsKey, jsonEncode(actions));
  }

  /// الحصول على الإجراءات المعلقة للمزامنة
  List<Map<String, dynamic>>? getPendingActions() {
    final String? actionsString = _preferences!.getString(pendingActionsKey);
    if (actionsString == null) return null;
    final List<dynamic> decodedData =
        jsonDecode(actionsString) as List<dynamic>;
    return decodedData.map((item) => item as Map<String, dynamic>).toList();
  }

  /// إضافة إجراء معلق للمزامنة
  Future<bool> addPendingAction(Map<String, dynamic> action) async {
    List<Map<String, dynamic>> actions = getPendingActions() ?? [];
    actions.add(action);
    return await savePendingActions(actions);
  }

  /// حفظ بيانات المحفظة
  Future<bool> saveWalletData(Map<String, dynamic> walletData) async {
    return await _preferences!.setString(walletKey, jsonEncode(walletData));
  }

  /// استرجاع بيانات المحفظة
  Map<String, dynamic>? getWalletData() {
    final String? data = _preferences!.getString(walletKey);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  /// حفظ بيانات المدفوعات
  Future<bool> savePaymentsData(List<Map<String, dynamic>> payments) async {
    return await _preferences!.setString(paymentsKey, jsonEncode(payments));
  }

  /// استرجاع بيانات المدفوعات
  List<Map<String, dynamic>> getPaymentsData() {
    final String? data = _preferences!.getString(paymentsKey);
    if (data == null) return [];
    final List<dynamic> decoded = jsonDecode(data) as List<dynamic>;
    return decoded.map((item) => item as Map<String, dynamic>).toList();
  }

  /// إضافة دفعة جديدة
  Future<bool> addPayment(Map<String, dynamic> payment) async {
    final payments = getPaymentsData();
    payments.add(payment);
    return await savePaymentsData(payments);
  }

  /// تحديث رصيد المحفظة
  Future<bool> updateWalletBalance(double newBalance) async {
    final walletData = getWalletData() ?? {};
    walletData['balance'] = newBalance;
    walletData['last_updated'] = DateTime.now().toIso8601String();
    return await saveWalletData(walletData);
  }

  /// الحصول على رصيد المحفظة
  double getWalletBalance() {
    final walletData = getWalletData();
    if (walletData == null) return 0.0;
    return (walletData['balance'] as num?)?.toDouble() ?? 0.0;
  }

  /// مسح الإجراءات المعلقة
  Future<bool> clearPendingActions() async {
    return await _preferences!.remove(pendingActionsKey);
  }

  /// مسح بيانات المستخدم عند تسجيل الخروج
  Future<bool> clearUserData() async {
    await _preferences!.remove(userKey);
    await _preferences!.remove(tokenKey);
    return true;
  }

  /// مسح جميع البيانات المخزنة
  Future<bool> clearAll() async {
    return await _preferences!.clear();
  }

  /// حفظ حالة التحقق من البريد الإلكتروني
  Future<bool> setEmailVerified(bool isVerified) async {
    return await _preferences!.setBool('email_verified', isVerified);
  }

  /// الحصول على حالة التحقق من البريد الإلكتروني
  bool getEmailVerified() {
    return _preferences!.getBool('email_verified') ?? false;
  }

  // ===============================
  // طرق خاصة بالكورسات
  // ===============================

  /// حفظ كورس واحد
  Future<bool> saveCourse(Map<String, dynamic> course) async {
    final courses = getCoursesData() ?? [];
    final index = courses.indexWhere((c) => c['id'] == course['id']);

    if (index != -1) {
      courses[index] = course;
    } else {
      courses.add(course);
    }

    return await saveCoursesData(courses);
  }

  /// حفظ قائمة كورسات
  Future<bool> saveCourses(List<Map<String, dynamic>> courses) async {
    return await saveCoursesData(courses);
  }

  /// جلب كورس بالمعرف
  Map<String, dynamic>? getCourseById(String courseId) {
    final courses = getCoursesData();
    if (courses == null) return null;

    try {
      return courses.firstWhere((course) => course['id'] == courseId);
    } catch (e) {
      return null;
    }
  }

  /// جلب كورسات مدرب
  List<Map<String, dynamic>> getInstructorCourses(String instructorId) {
    final courses = getCoursesData();
    if (courses == null) return [];

    return courses
        .where((course) => course['instructor_id'] == instructorId)
        .toList();
  }

  /// جلب كورسات طالب
  List<Map<String, dynamic>> getStudentCourses(String studentId) {
    final enrollments = getEnrollments();
    final courses = getCoursesData() ?? [];

    final enrolledCourseIds = enrollments
        .where((enrollment) => enrollment['student_id'] == studentId)
        .map((enrollment) => enrollment['course_id'])
        .toList();

    return courses
        .where((course) => enrolledCourseIds.contains(course['id']))
        .toList();
  }

  /// حذف كورس بالمعرف
  Future<bool> deleteCourse(String courseId) async {
    final courses = getCoursesData() ?? [];
    courses.removeWhere((course) => course['id'] == courseId);
    return await saveCoursesData(courses);
  }

  /// البحث في الكورسات
  List<Map<String, dynamic>> searchCourses(String query) {
    final courses = getCoursesData();
    if (courses == null) return [];

    final lowercaseQuery = query.toLowerCase();
    return courses.where((course) {
      final title = (course['title'] as String?)?.toLowerCase() ?? '';
      final description =
          (course['description'] as String?)?.toLowerCase() ?? '';
      return title.contains(lowercaseQuery) ||
          description.contains(lowercaseQuery);
    }).toList();
  }

  // ===============================
  // طرق خاصة بالمستخدمين
  // ===============================

  /// حفظ قائمة مستخدمين
  Future<bool> saveUsers(List<Map<String, dynamic>> users) async {
    return await _preferences!.setString(usersKey, jsonEncode(users));
  }

  /// جلب قائمة مستخدمين
  List<Map<String, dynamic>> getUsers() {
    final String? usersString = _preferences!.getString(usersKey);
    if (usersString == null) return [];
    final List<dynamic> decodedData = jsonDecode(usersString) as List<dynamic>;
    return decodedData.map((item) => item as Map<String, dynamic>).toList();
  }

  /// حفظ مستخدم واحد
  Future<bool> saveUser(Map<String, dynamic> user) async {
    final users = getUsers();
    final index = users.indexWhere((u) => u['id'] == user['id']);

    if (index != -1) {
      users[index] = user;
    } else {
      users.add(user);
    }

    return await saveUsers(users);
  }

  /// جلب مستخدم بالمعرف
  Map<String, dynamic>? getUserById(String userId) {
    final users = getUsers();
    try {
      return users.firstWhere((user) => user['id'] == userId);
    } catch (e) {
      return null;
    }
  }

  /// جلب طلاب
  List<Map<String, dynamic>> getStudents() {
    final users = getUsers();
    return users.where((user) => user['role'] == 'student').toList();
  }

  /// جلب مدربين
  List<Map<String, dynamic>> getInstructors() {
    final users = getUsers();
    return users.where((user) => user['role'] == 'instructor').toList();
  }

  /// البحث في المستخدمين
  List<Map<String, dynamic>> searchUsers(String query) {
    final users = getUsers();
    final lowercaseQuery = query.toLowerCase();
    return users.where((user) {
      final name = (user['name'] as String?)?.toLowerCase() ?? '';
      final email = (user['email'] as String?)?.toLowerCase() ?? '';
      return name.contains(lowercaseQuery) || email.contains(lowercaseQuery);
    }).toList();
  }

  // ===============================
  // طرق خاصة بالتسجيلات
  // ===============================

  /// حفظ قائمة تسجيلات
  Future<bool> saveEnrollments(List<Map<String, dynamic>> enrollments) async {
    return await _preferences!
        .setString(enrollmentsKey, jsonEncode(enrollments));
  }

  /// جلب قائمة تسجيلات
  List<Map<String, dynamic>> getEnrollments() {
    final String? enrollmentsString = _preferences!.getString(enrollmentsKey);
    if (enrollmentsString == null) return [];
    final List<dynamic> decodedData =
        jsonDecode(enrollmentsString) as List<dynamic>;
    return decodedData.map((item) => item as Map<String, dynamic>).toList();
  }

  /// حفظ تسجيل في كورس
  Future<bool> saveEnrollment(Map<String, dynamic> enrollment) async {
    final enrollments = getEnrollments();
    enrollments.add(enrollment);
    return await saveEnrollments(enrollments);
  }

  /// التحقق من تسجيل طالب في كورس
  bool isEnrolled(String studentId, String courseId) {
    final enrollments = getEnrollments();
    return enrollments.any((enrollment) =>
        enrollment['student_id'] == studentId &&
        enrollment['course_id'] == courseId);
  }

  /// حذف تسجيل معين
  Future<bool> removeEnrollment(String studentId, String courseId) async {
    final enrollments = getEnrollments();
    enrollments.removeWhere((enrollment) =>
        enrollment['student_id'] == studentId &&
        enrollment['course_id'] == courseId);
    return await saveEnrollments(enrollments);
  }

  /// جلب طلاب كورس
  List<Map<String, dynamic>> getCourseStudents(String courseId) {
    final enrollments = getEnrollments();
    final users = getUsers();

    final enrolledStudentIds = enrollments
        .where((enrollment) => enrollment['course_id'] == courseId)
        .map((enrollment) => enrollment['student_id'])
        .toList();

    return users
        .where((user) => enrolledStudentIds.contains(user['id']))
        .toList();
  }

  // ===============================
  // طرق خاصة بالمراجعات
  // ===============================

  /// حفظ قائمة مراجعات
  Future<bool> saveReviews(List<Map<String, dynamic>> reviews) async {
    return await _preferences!.setString(reviewsKey, jsonEncode(reviews));
  }

  /// جلب قائمة مراجعات
  List<Map<String, dynamic>> getReviews() {
    final String? reviewsString = _preferences!.getString(reviewsKey);
    if (reviewsString == null) return [];
    final List<dynamic> decodedData =
        jsonDecode(reviewsString) as List<dynamic>;
    return decodedData.map((item) => item as Map<String, dynamic>).toList();
  }

  /// حفظ مراجعة واحدة
  Future<bool> saveReview(Map<String, dynamic> review) async {
    final reviews = getReviews();
    reviews.add(review);
    return await saveReviews(reviews);
  }

  /// جلب مراجعات كورس
  List<Map<String, dynamic>> getCourseReviews(String courseId) {
    final reviews = getReviews();
    return reviews.where((review) => review['course_id'] == courseId).toList();
  }

  // ===============================
  // طرق خاصة بالفئات
  // ===============================

  /// جلب الكورسات الموصى بها
  List<Map<String, dynamic>> getRecommendedCourses(String userId) {
    final allCourses = getCoursesData() ?? [];
    final enrollments = getEnrollments();
    final enrolledCourseIds = enrollments
        .where((enrollment) => enrollment['student_id'] == userId)
        .map((enrollment) => enrollment['course_id'])
        .toList();

    // استبعاد الكورسات المشترك فيها
    final recommendedCourses = allCourses
        .where((course) => !enrolledCourseIds.contains(course['id']))
        .take(10)
        .toList();

    return recommendedCourses;
  }

  // ===============================
  // طرق خاصة بالفئات
  // ===============================

  /// حفظ قائمة فئات
  Future<bool> saveCategories(List<Map<String, dynamic>> categories) async {
    return await _preferences!.setString(categoriesKey, jsonEncode(categories));
  }

  /// جلب قائمة فئات
  List<Map<String, dynamic>> getCategories() {
    final String? categoriesString = _preferences!.getString(categoriesKey);
    if (categoriesString == null) return [];
    final List<dynamic> decodedData =
        jsonDecode(categoriesString) as List<dynamic>;
    return decodedData.map((item) => item as Map<String, dynamic>).toList();
  }

  // ===============================
  // طرق خاصة بالرسائل
  // ===============================

  /// حفظ قائمة رسائل
  Future<bool> saveMessages(List<Map<String, dynamic>> messages) async {
    return await _preferences!.setString(messagesKey, jsonEncode(messages));
  }

  /// جلب قائمة رسائل
  List<Map<String, dynamic>> getMessages() {
    final String? messagesString = _preferences!.getString(messagesKey);
    if (messagesString == null) return [];
    final List<dynamic> decodedData =
        jsonDecode(messagesString) as List<dynamic>;
    return decodedData.map((item) => item as Map<String, dynamic>).toList();
  }

  /// حفظ رسالة واحدة
  Future<bool> saveMessage(Map<String, dynamic> message) async {
    final messages = getMessages();
    messages.add(message);
    return await saveMessages(messages);
  }

  /// جلب رسائل بين مستخدمين
  List<Map<String, dynamic>> getMessagesBetweenUsers(
      String userId1, String userId2) {
    final messages = getMessages();
    return messages
        .where((message) =>
            (message['from_user_id'] == userId1 &&
                message['to_user_id'] == userId2) ||
            (message['from_user_id'] == userId2 &&
                message['to_user_id'] == userId1))
        .toList();
  }
}
