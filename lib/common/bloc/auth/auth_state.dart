import 'package:equatable/equatable.dart';
import '../../models/user.dart';

/// حالات مصادقة المستخدم
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// حالة التحميل الأولي
class AuthInitial extends AuthState {}

/// حالة جاري التحميل
class AuthLoading extends AuthState {}

/// حالة المصادقة الناجحة
class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

/// حالة نجاح عملية المصادقة (للتسجيل والعمليات الأخرى)
class AuthSuccess extends AuthState {
  final String message;
  final User? user;

  const AuthSuccess(this.message, {this.user});

  @override
  List<Object?> get props => [message, user];
}

/// حالة عدم المصادقة
class AuthUnauthenticated extends AuthState {}

/// حالة نجاح إعادة تعيين كلمة المرور
class AuthResetPasswordSuccess extends AuthState {
  final String message;

  const AuthResetPasswordSuccess(this.message);

  @override
  List<Object> get props => [message];
}

/// حالة فشل المصادقة
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// حالة نجاح تأكيد البريد الإلكتروني
class AuthEmailConfirmed extends AuthState {
  const AuthEmailConfirmed();
}

/// حالة نجاح إعادة إرسال رابط تأكيد البريد
class AuthResendEmailSuccess extends AuthState {
  const AuthResendEmailSuccess();
}

/// حالة نجاح إرسال رمز التحقق
class AuthVerificationCodeSent extends AuthState {
  final String email;
  final String message;

  const AuthVerificationCodeSent(this.email, this.message);

  @override
  List<Object> get props => [email, message];
}

/// حالة نجاح التحقق من الرمز
class AuthCodeVerified extends AuthState {
  final User? user;
  final String message;

  const AuthCodeVerified(this.message, {this.user});

  @override
  List<Object?> get props => [message, user];
}
