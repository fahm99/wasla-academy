import 'package:equatable/equatable.dart';
import '../../models/user.dart';

/// أحداث مصادقة المستخدم
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// حدث التحقق من حالة المصادقة
class AuthCheckRequested extends AuthEvent {}

/// حدث تسجيل الدخول
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// حدث تسجيل مستخدم جديد
class AuthSignUpRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final UserRole role;

  const AuthSignUpRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  List<Object> get props => [name, email, password, role];
}

/// حدث تسجيل الخروج
class AuthLogoutRequested extends AuthEvent {}

/// حدث إعادة تعيين كلمة المرور
class AuthResetPasswordRequested extends AuthEvent {
  final String email;

  const AuthResetPasswordRequested({
    required this.email,
  });

  @override
  List<Object> get props => [email];
}

/// حدث تحديث بيانات المستخدم
class AuthUserUpdated extends AuthEvent {
  final User user;

  const AuthUserUpdated(this.user);

  @override
  List<Object> get props => [user];
}

/// حدث إعادة إرسال رابط تأكيد البريد الإلكتروني
class AuthResendEmailConfirmationRequested extends AuthEvent {
  const AuthResendEmailConfirmationRequested();
}

/// حدث التحقق من تأكيد البريد الإلكتروني
class AuthCheckEmailConfirmationRequested extends AuthEvent {
  const AuthCheckEmailConfirmationRequested();
}

/// حدث إرسال رمز التحقق
class AuthSendVerificationCodeRequested extends AuthEvent {
  final String email;

  const AuthSendVerificationCodeRequested({
    required this.email,
  });

  @override
  List<Object> get props => [email];
}

/// حدث التحقق من رمز التأكيد
class AuthVerifyCodeRequested extends AuthEvent {
  final String email;
  final String code;

  const AuthVerifyCodeRequested({
    required this.email,
    required this.code,
  });

  @override
  List<Object> get props => [email, code];
}
