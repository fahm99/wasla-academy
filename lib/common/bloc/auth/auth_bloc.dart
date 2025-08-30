import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User, AuthState;
import '../../services/supabase_service.dart';
import '../../services/local_storage_service.dart';
import '../../models/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Bloc لإدارة حالة مصادقة المستخدم
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SupabaseService _supabaseService;
  final LocalStorageService _localStorageService;

  AuthBloc({
    required SupabaseService supabaseService,
    required LocalStorageService localStorageService,
  })  : _supabaseService = supabaseService,
        _localStorageService = localStorageService,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthResetPasswordRequested>(_onAuthResetPasswordRequested);
    on<AuthUserUpdated>(_onAuthUserUpdated);
    on<AuthResendEmailConfirmationRequested>(
        _onAuthResendEmailConfirmationRequested);
    on<AuthCheckEmailConfirmationRequested>(
        _onAuthCheckEmailConfirmationRequested);
    on<AuthSendVerificationCodeRequested>(_onAuthSendVerificationCodeRequested);
    on<AuthVerifyCodeRequested>(_onAuthVerifyCodeRequested);
  }

  /// التحقق من حالة المصادقة الحالية
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // التحقق من وجود مستخدم حالي
      final currentUser = _supabaseService.getCurrentUser();

      if (currentUser != null) {
        // الحصول على بيانات المستخدم الكاملة
        final userDetails =
            await _supabaseService.getUserDetails(currentUser.id);

        if (userDetails != null) {
          // التحقق من حالة المستخدم
          if (userDetails.role == UserRole.instructor &&
              userDetails.metadata?['verification_status'] == 'pending') {
            // للمدربين المعلقين، نعرض رسالة انتظار
            emit(const AuthSuccess(
                'حسابك قيد المراجعة. سيتم تفعيله بعد اكتمال عملية المراجعة.'));
          } else if (!userDetails.isActive) {
            // للمستخدمين غير المفعلين
            emit(const AuthFailure('حسابك غير مفعل. يرجى التواصل مع الإدارة.'));
          } else {
            emit(AuthAuthenticated(userDetails));
          }
        } else {
          emit(const AuthFailure('فشل في الحصول على بيانات المستخدم'));
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthFailure('حدث خطأ: ${e.toString()}'));
    }
  }

  /// تسجيل الدخول
  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // محاولة تسجيل الدخول
      final response = await _supabaseService.signInWithEmail(
        email: event.email,
        password: event.password,
      );

      if (response.user != null) {
        // الحصول على بيانات المستخدم الكاملة
        try {
          final userDetails =
              await _supabaseService.getUserDetails(response.user!.id);

          if (userDetails != null) {
            // التحقق من حالة المستخدم
            if (userDetails.role == UserRole.instructor &&
                userDetails.metadata?['verification_status'] == 'pending') {
              // للمدربين المعلقين، نعرض رسالة انتظار
              emit(const AuthSuccess(
                  'حسابك قيد المراجعة. سيتم تفعيله بعد اكتمال عملية المراجعة.'));
              return;
            } else if (!userDetails.isActive) {
              // للمستخدمين غير المفعلين
              emit(const AuthFailure(
                  'حسابك غير مفعل. يرجى التواصل مع الإدارة.'));
              return;
            }

            // حفظ بيانات المستخدم محلياً
            await _localStorageService.saveUserData(userDetails.toJson());

            // حفظ رمز المصادقة
            await _localStorageService
                .saveAuthToken(response.session!.accessToken);

            emit(AuthAuthenticated(userDetails));
          } else {
            // إذا لم نتمكن من الحصول على تفاصيل المستخدم، ننشئ مستخدم من البيانات المتاحة
            final fallbackUser = User(
              id: response.user!.id,
              name: response.user!.userMetadata?['name'] ??
                  response.user!.email?.split('@')[0] ??
                  'مستخدم',
              email: response.user!.email ?? '',
              role: _parseUserRole(response.user!.userMetadata?['role']),
              createdAt: DateTime.now(),
              isActive: true,
            );

            // حفظ بيانات المستخدم محلياً
            await _localStorageService.saveUserData(fallbackUser.toJson());

            // حفظ رمز المصادقة
            await _localStorageService
                .saveAuthToken(response.session!.accessToken);

            emit(AuthAuthenticated(fallbackUser));
          }
        } catch (userDetailsError) {
          print('Error getting user details: $userDetailsError');

          // إذا فشل في الحصول على تفاصيل المستخدم، ننشئ مستخدم من البيانات المتاحة
          final fallbackUser = User(
            id: response.user!.id,
            name: response.user!.userMetadata?['name'] ??
                response.user!.email?.split('@')[0] ??
                'مستخدم',
            email: response.user!.email ?? '',
            role: _parseUserRole(response.user!.userMetadata?['role']),
            createdAt: DateTime.now(),
            isActive: true,
          );

          try {
            // حفظ بيانات المستخدم محلياً
            await _localStorageService.saveUserData(fallbackUser.toJson());

            // حفظ رمز المصادقة
            await _localStorageService
                .saveAuthToken(response.session!.accessToken);

            emit(AuthAuthenticated(fallbackUser));
          } catch (e) {
            emit(const AuthFailure(
                'تم تسجيل الدخول بنجاح ولكن حدث خطأ في حفظ البيانات. يرجى إعادة تسجيل الدخول.'));
          }
        }
      } else {
        emit(const AuthFailure('فشل تسجيل الدخول'));
      }
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('حدث خطأ: ${e.toString()}'));
    }
  }

  /// تسجيل مستخدم جديد
  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // التسجيل المباشر بدلاً من النظام المعلق
      final response = await _supabaseService.signUp(
        email: event.email,
        password: event.password,
        name: event.name,
        role: event.role,
      );

      if (response.user != null) {
        // حفظ بيانات المستخدم محلياً
        final user = User(
          id: response.user!.id,
          name: event.name,
          email: event.email,
          role: event.role,
          createdAt: DateTime.now(),
        );

        await _localStorageService.saveUserData(user.toJson());
        if (response.session != null) {
          await _localStorageService
              .saveAuthToken(response.session!.accessToken);
        }

        // إرسال رمز التحقق للطلاب
        if (event.role == UserRole.student) {
          final success =
              await _supabaseService.sendVerificationCode(event.email);
          if (success) {
            emit(AuthVerificationCodeSent(
              event.email,
              'تم إرسال رمز التحقق إلى ${event.email}',
            ));
          } else {
            emit(const AuthFailure('فشل في إرسال رمز التحقق'));
          }
        } else {
          // للمدربين والمؤسسات، نعرض رسالة انتظار المراجعة
          emit(const AuthSuccess(
              'تم إنشاء حسابك بنجاح وقيد المراجعة. سيتم تفعيله بعد اكتمال عملية المراجعة.'));
        }
      } else {
        // للمدربين والمؤسسات، التسجيل المعلق
        if (event.role == UserRole.instructor) {
          emit(const AuthSuccess(
              'تم إرسال طلب التسجيل بنجاح. سيتم مراجعة المستندات والموافقة على الحساب قريباً.'));
        } else {
          emit(const AuthFailure('فشل في إنشاء الحساب'));
        }
      }
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('حدث خطأ أثناء التسجيل: ${e.toString()}'));
    }
  }

  /// تسجيل الخروج
  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // تسجيل الخروج من Supabase
      await _supabaseService.signOut();

      // مسح بيانات المستخدم المحلية
      await _localStorageService.clearUserData();

      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure('حدث خطأ أثناء تسجيل الخروج: ${e.toString()}'));
    }
  }

  /// إعادة تعيين كلمة المرور
  Future<void> _onAuthResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // إرسال رابط إعادة تعيين كلمة المرور
      await _supabaseService.client.auth.resetPasswordForEmail(event.email);

      emit(const AuthResetPasswordSuccess(
          'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني'));
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure('حدث خطأ: ${e.toString()}'));
    }
  }

  /// تحديث بيانات المستخدم
  Future<void> _onAuthUserUpdated(
    AuthUserUpdated event,
    Emitter<AuthState> emit,
  ) async {
    // تحديث حالة المصادقة بالمستخدم المحدث
    emit(AuthAuthenticated(event.user));

    // تحديث البيانات المحلية
    await _localStorageService.saveUserData(event.user.toJson());
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

  /// إعادة إرسال رابط تأكيد البريد الإلكتروني
  Future<void> _onAuthResendEmailConfirmationRequested(
    AuthResendEmailConfirmationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // الحصول على البريد الإلكتروني للمستخدم الحالي
      final currentAuthUser = _supabaseService.client.auth.currentUser;
      if (currentAuthUser?.email != null) {
        // إعادة إرسال رابط التأكيد
        await _supabaseService.client.auth.resend(
          type: OtpType.signup,
          email: currentAuthUser!.email!,
        );
        emit(const AuthResendEmailSuccess());
      } else {
        emit(const AuthFailure('لم يتم العثور على بريد إلكتروني للمستخدم'));
      }
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(AuthFailure(
          'حدث خطأ أثناء إعادة إرسال رابط التأكيد: ${e.toString()}'));
    }
  }

  /// التحقق من تأكيد البريد الإلكتروني
  Future<void> _onAuthCheckEmailConfirmationRequested(
    AuthCheckEmailConfirmationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      // التحقق من حالة المستخدم الحالي
      final currentAuthUser = _supabaseService.client.auth.currentUser;
      if (currentAuthUser != null) {
        // تحديث بيانات المستخدم للحصول على أحدث حالة
        await _supabaseService.client.auth.refreshSession();
        final updatedAuthUser = _supabaseService.client.auth.currentUser;

        if (updatedAuthUser?.emailConfirmedAt != null) {
          // البريد الإلكتروني مؤكد
          emit(const AuthEmailConfirmed());
        } else {
          // البريد الإلكتروني غير مؤكد بعد
          emit(const AuthFailure('البريد الإلكتروني لم يتم تأكيده بعد'));
        }
      } else {
        emit(const AuthFailure('لم يتم العثور على مستخدم'));
      }
    } on AuthException catch (e) {
      emit(AuthFailure(e.message));
    } catch (e) {
      emit(
          AuthFailure('حدث خطأ أثناء التحقق من تأكيد البريد: ${e.toString()}'));
    }
  }

  /// إرسال رمز التحقق
  Future<void> _onAuthSendVerificationCodeRequested(
    AuthSendVerificationCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final success = await _supabaseService.sendVerificationCode(event.email);

      if (success) {
        emit(AuthVerificationCodeSent(
          event.email,
          'تم إرسال رمز التحقق إلى ${event.email}',
        ));
      } else {
        emit(const AuthFailure('فشل في إرسال رمز التحقق'));
      }
    } catch (e) {
      emit(AuthFailure('حدث خطأ أثناء إرسال رمز التحقق: ${e.toString()}'));
    }
  }

  /// التحقق من رمز التأكيد
  Future<void> _onAuthVerifyCodeRequested(
    AuthVerifyCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isValid =
          await _supabaseService.verifyCode(event.email, event.code);

      if (isValid) {
        // إنهاء عملية التسجيل بعد التحقق
        final user =
            await _supabaseService.completeSignupAfterVerification(event.email);

        if (user != null) {
          // حفظ بيانات المستخدم محلياً
          await _localStorageService.saveUserData(user.toJson());

          // حفظ حالة التحقق من البريد
          await _localStorageService.setEmailVerified(true);

          emit(AuthCodeVerified(
            'مرحباً بك في منصة وصلة! تم إنشاء حسابك بنجاح.',
            user: user,
          ));
        } else {
          emit(const AuthCodeVerified('تم تأكيد بريدك الإلكتروني بنجاح!'));
        }
      } else {
        emit(const AuthFailure('رمز التحقق غير صحيح أو منتهي الصلاحية'));
      }
    } catch (e) {
      emit(AuthFailure('حدث خطأ أثناء التحقق من الرمز: ${e.toString()}'));
    }
  }
}
