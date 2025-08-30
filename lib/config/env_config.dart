class EnvConfig {
  // إعدادات Supabase
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // إعدادات التطبيق
  static const String appName = 'وصلة - Wasla';
  static const String appVersion = '1.0.0';
  static const String appEnvironment = String.fromEnvironment(
    'APP_ENVIRONMENT',
    defaultValue: 'development',
  );

  // إعدادات التخزين
  static const String storageBucketAvatars = 'avatars';
  static const String storageBucketCourseThumbnails = 'course_thumbnails';
  static const String storageBucketCourseVideos = 'course_videos';
  static const String storageBucketAttachments = 'attachments';
  static const String storageBucketCertificates = 'certificates';

  // التحقق من صحة الإعدادات
  static bool get isConfigured {
    return supabaseUrl != 'YOUR_SUPABASE_URL' &&
        supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';
  }

  // الحصول على رسالة خطأ الإعداد
  static String get configurationErrorMessage {
    if (!isConfigured) {
      return '''
⚠️ تحذير: إعدادات Supabase غير مكتملة

يرجى تحديث الإعدادات في ملف lib/config/env_config.dart:

1. إنشاء مشروع في Supabase
2. نسخ URL و Anon Key
3. تحديث المتغيرات التالية:
   - supabaseUrl
   - supabaseAnonKey

أو استخدام متغيرات البيئة:
   flutter run --dart-define=SUPABASE_URL=your_url
   flutter run --dart-define=SUPABASE_ANON_KEY=your_key
''';
    }
    return '';
  }
}
