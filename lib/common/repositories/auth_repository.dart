import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;
import '../services/supabase_service.dart';
import '../services/local_storage_service.dart';

class AuthRepository {
  final SupabaseService _supabaseService;
  final LocalStorageService _localStorageService;

  AuthRepository({
    required SupabaseService supabaseService,
    required LocalStorageService localStorageService,
  })  : _supabaseService = supabaseService,
        _localStorageService = localStorageService;

  // تسجيل الدخول بالبريد الإلكتروني وكلمة المرور
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.signInWithEmail(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // حفظ بيانات المستخدم محلياً
        await _localStorageService.saveUserData(response.user!.toJson());
        await _localStorageService.saveAuthToken(response.session!.accessToken);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // إنشاء حساب جديد
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _supabaseService.signUp(
        email: email,
        password: password,
        name: fullName,
        role: app_user.UserRole.student,
      );

      if (response.user != null) {
        // حفظ بيانات المستخدم محلياً
        final userData = {
          'id': response.user!.id,
          'name': fullName,
          'email': email,
          'phone': phone,
          'role': app_user.UserRole.student.name,
          'created_at': DateTime.now().toIso8601String(),
        };
        await _localStorageService.saveUserData(userData);
        if (response.session != null) {
          await _localStorageService
              .saveAuthToken(response.session!.accessToken);
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // تسجيل الدخول بـ Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Simulate Google Sign-in process
      await Future.delayed(const Duration(seconds: 2));

      // Mock Google sign-in response
      final googleUser = {
        'id': 'google_${DateTime.now().millisecondsSinceEpoch}',
        'email': 'user.google@example.com',
        'name': 'مستخدم جوجل',
        'avatar': 'https://lh3.googleusercontent.com/a/default-user=s96-c',
        'provider': 'google',
      };

      // Create user in our system
      final userData = {
        'id': googleUser['id'],
        'name': googleUser['name'],
        'email': googleUser['email'],
        'avatar': googleUser['avatar'],
        'role': app_user.UserRole.student.name,
        'provider': 'google',
        'created_at': DateTime.now().toIso8601String(),
      };

      // Save user data locally
      await _localStorageService.saveUserData(userData);

      // Generate mock session token
      final sessionToken =
          'google_token_${DateTime.now().millisecondsSinceEpoch}';
      await _localStorageService.saveAuthToken(sessionToken);

      // Create mock AuthResponse
      final user = app_user.User.fromJson(userData);

      return AuthResponse(
        user: User(
          id: user.id,
          aud: '',
          role: '',
          email: user.email,
          phone: user.phone,
          confirmationSentAt: null,
          confirmedAt: DateTime.now().toIso8601String(),
          lastSignInAt: DateTime.now().toIso8601String(),
          appMetadata: {},
          userMetadata: {
            'name': user.name,
            'avatar': user.avatar,
          },
          identities: [],
          createdAt: user.createdAt.toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          isAnonymous: false,
        ),
        session: Session(
          accessToken: sessionToken,
          tokenType: 'bearer',
          user: User(
            id: user.id,
            aud: '',
            role: '',
            email: user.email,
            phone: user.phone,
            confirmationSentAt: null,
            confirmedAt: DateTime.now().toIso8601String(),
            lastSignInAt: DateTime.now().toIso8601String(),
            appMetadata: {},
            userMetadata: {
              'name': user.name,
              'avatar': user.avatar,
            },
            identities: [],
            createdAt: user.createdAt.toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
            isAnonymous: false,
          ),
          refreshToken: 'refresh_$sessionToken',
          expiresIn: 3600,
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
      await _localStorageService.clearUserData();
    } catch (e) {
      rethrow;
    }
  }

  // إعادة تعيين كلمة المرور
  Future<void> resetPassword(String email) async {
    try {
      await _supabaseService.client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // تحديث كلمة المرور
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabaseService.client.auth
          .updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      rethrow;
    }
  }

  // تحديث الملف الشخصي
  Future<app_user.User?> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? avatar,
    String? bio,
  }) async {
    try {
      final userData = <String, dynamic>{};
      if (fullName != null) userData['name'] = fullName;
      if (phone != null) userData['phone'] = phone;
      if (avatar != null) userData['avatar'] = avatar;
      if (bio != null) userData['bio'] = bio;

      final success =
          await _supabaseService.updateUserProfile(userId, userData);

      if (success) {
        // تحديث البيانات المحلية
        final currentUserData = _localStorageService.getUserData();
        if (currentUserData != null) {
          currentUserData.addAll(userData);
          await _localStorageService.saveUserData(currentUserData);
        }

        return _supabaseService.getCurrentUser();
      }

      return null;
    } catch (e) {
      rethrow;
    }
  }

  // الحصول على المستخدم الحالي
  Future<app_user.User?> getCurrentUser() async {
    try {
      // محاولة الحصول من التخزين المحلي أولاً
      final localUserData = _localStorageService.getUserData();
      if (localUserData != null) {
        return app_user.User.fromJson(localUserData);
      }

      // إذا لم يكن موجود محلياً، جلب من Supabase
      final user = _supabaseService.getCurrentUser();
      if (user != null) {
        await _localStorageService.saveUserData(user.toJson());
      }

      return user;
    } catch (e) {
      return null;
    }
  }

  // التحقق من حالة الجلسة
  Future<bool> isAuthenticated() async {
    try {
      final token = _localStorageService.getAuthToken();
      if (token != null) {
        // التحقق من صلاحية الجلسة
        final currentUser = _supabaseService.getCurrentUser();
        if (currentUser == null) {
          await _localStorageService.clearUserData();
          return false;
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // الحصول على نوع المستخدم
  Future<String?> getUserRole(String userId) async {
    try {
      final user = await _supabaseService.getUserDetails(userId);
      return user?.role.name;
    } catch (e) {
      return null;
    }
  }

  // التحقق من تأكيد البريد الإلكتروني
  Future<bool> isEmailConfirmed() async {
    try {
      final user = await getCurrentUser();
      // Note: emailConfirmedAt not available in our User model
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // إرسال رابط تأكيد البريد الإلكتروني
  Future<void> resendEmailConfirmation() async {
    try {
      await _supabaseService.client.auth.resend(
        type: OtpType.signup,
        email: _supabaseService.getCurrentUser()?.email ?? '',
      );
    } catch (e) {
      rethrow;
    }
  }

  // حذف الحساب
  Future<void> deleteAccount() async {
    try {
      await _supabaseService.client.auth.admin.deleteUser(
        _supabaseService.getCurrentUser()?.id ?? '',
      );
      await _localStorageService.clearUserData();
    } catch (e) {
      rethrow;
    }
  }
}
