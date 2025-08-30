import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// أنواع الأخطاء المختلفة
enum ErrorType {
  network,
  authentication,
  authorization,
  validation,
  notFound,
  serverError,
  unknown,
}

/// كلاس لتمثيل الأخطاء المخصصة
class AppError {
  final ErrorType type;
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppError({
    required this.type,
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'AppError(type: $type, message: $message, code: $code)';
  }
}

/// خدمة معالجة الأخطاء
class ErrorHandlingService {
  /// معالجة الأخطاء العامة
  static AppError handleError(dynamic error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('Error occurred: $error');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }

    if (error is AuthException) {
      return _handleAuthError(error, stackTrace);
    } else if (error is PostgrestException) {
      return _handlePostgrestError(error, stackTrace);
    } else if (error is StorageException) {
      return _handleStorageError(error, stackTrace);
    } else if (error is AppError) {
      return error;
    } else {
      return AppError(
        type: ErrorType.unknown,
        message: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// معالجة أخطاء المصادقة
  static AppError _handleAuthError(
      AuthException error, StackTrace? stackTrace) {
    String message;
    ErrorType type = ErrorType.authentication;

    switch (error.message.toLowerCase()) {
      case 'invalid login credentials':
        message = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        break;
      case 'email not confirmed':
        message = 'يرجى تأكيد بريدك الإلكتروني أولاً';
        break;
      case 'user not found':
        message = 'المستخدم غير موجود';
        break;
      case 'email already registered':
        message = 'البريد الإلكتروني مسجل مسبقاً';
        break;
      case 'weak password':
        message = 'كلمة المرور ضعيفة. يرجى اختيار كلمة مرور أقوى';
        type = ErrorType.validation;
        break;
      case 'token expired':
        message = 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى';
        break;
      case 'invalid token':
        message = 'رمز المصادقة غير صحيح';
        break;
      case 'signup disabled':
        message = 'التسجيل معطل حالياً';
        type = ErrorType.authorization;
        break;
      default:
        message = 'خطأ في المصادقة: ${error.message}';
    }

    return AppError(
      type: type,
      message: message,
      code: error.statusCode,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// معالجة أخطاء قاعدة البيانات
  static AppError _handlePostgrestError(
      PostgrestException error, StackTrace? stackTrace) {
    String message;
    ErrorType type = ErrorType.serverError;

    // تحليل رسالة الخطأ لتحديد النوع والرسالة المناسبة
    if (error.message.contains('duplicate key')) {
      message = 'البيانات موجودة مسبقاً';
      type = ErrorType.validation;
    } else if (error.message.contains('foreign key')) {
      message = 'البيانات المرتبطة غير موجودة';
      type = ErrorType.validation;
    } else if (error.message.contains('not found')) {
      message = 'البيانات المطلوبة غير موجودة';
      type = ErrorType.notFound;
    } else if (error.message.contains('permission denied')) {
      message = 'ليس لديك صلاحية للوصول لهذه البيانات';
      type = ErrorType.authorization;
    } else if (error.message.contains('connection')) {
      message = 'مشكلة في الاتصال بالخادم';
      type = ErrorType.network;
    } else {
      message = 'خطأ في الخادم. يرجى المحاولة مرة أخرى';
    }

    return AppError(
      type: type,
      message: message,
      code: error.code,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// معالجة أخطاء التخزين
  static AppError _handleStorageError(
      StorageException error, StackTrace? stackTrace) {
    String message;
    ErrorType type = ErrorType.serverError;

    switch (error.statusCode) {
      case '404':
        message = 'الملف غير موجود';
        type = ErrorType.notFound;
        break;
      case '403':
        message = 'ليس لديك صلاحية للوصول لهذا الملف';
        type = ErrorType.authorization;
        break;
      case '413':
        message = 'حجم الملف كبير جداً';
        type = ErrorType.validation;
        break;
      case '422':
        message = 'نوع الملف غير مدعوم';
        type = ErrorType.validation;
        break;
      default:
        message = 'خطأ في تحميل الملف';
    }

    return AppError(
      type: type,
      message: message,
      code: error.statusCode,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// الحصول على رسالة خطأ مناسبة للمستخدم
  static String getUserFriendlyMessage(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى';
      case ErrorType.authentication:
        return 'مشكلة في تسجيل الدخول. تحقق من بياناتك';
      case ErrorType.authorization:
        return 'ليس لديك صلاحية للقيام بهذا الإجراء';
      case ErrorType.validation:
        return 'تحقق من البيانات المدخلة وحاول مرة أخرى';
      case ErrorType.notFound:
        return 'البيانات المطلوبة غير موجودة';
      case ErrorType.serverError:
        return 'مشكلة في الخادم. حاول مرة أخرى لاحقاً';
      case ErrorType.unknown:
        return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
    }
  }

  /// تحديد ما إذا كان يجب إعادة المحاولة
  static bool shouldRetry(ErrorType type) {
    switch (type) {
      case ErrorType.network:
      case ErrorType.serverError:
        return true;
      case ErrorType.authentication:
      case ErrorType.authorization:
      case ErrorType.validation:
      case ErrorType.notFound:
      case ErrorType.unknown:
        return false;
    }
  }

  /// تسجيل الأخطاء للمطورين
  static void logError(AppError error) {
    if (kDebugMode) {
      print('=== ERROR LOG ===');
      print('Type: ${error.type}');
      print('Message: ${error.message}');
      print('Code: ${error.code}');
      print('Original Error: ${error.originalError}');
      if (error.stackTrace != null) {
        print('Stack Trace: ${error.stackTrace}');
      }
      print('==================');
    }

    // في الإنتاج، يمكن إرسال الأخطاء لخدمة مراقبة مثل Crashlytics
    // FirebaseCrashlytics.instance.recordError(error.originalError, error.stackTrace);
  }

  /// إنشاء خطأ مخصص
  static AppError createCustomError({
    required ErrorType type,
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      type: type,
      message: message,
      code: code,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// معالجة أخطاء الشبكة
  static AppError handleNetworkError(dynamic error) {
    return AppError(
      type: ErrorType.network,
      message: 'مشكلة في الاتصال بالإنترنت. تحقق من اتصالك وحاول مرة أخرى.',
      originalError: error,
    );
  }

  /// معالجة أخطاء التحقق من البيانات
  static AppError handleValidationError(String message) {
    return AppError(
      type: ErrorType.validation,
      message: message,
    );
  }

  /// معالجة أخطاء الصلاحيات
  static AppError handleAuthorizationError([String? customMessage]) {
    return AppError(
      type: ErrorType.authorization,
      message: customMessage ?? 'ليس لديك صلاحية للقيام بهذا الإجراء',
    );
  }
}
