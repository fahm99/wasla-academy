import 'package:equatable/equatable.dart';
import '../../models/user.dart';

/// أحداث إدارة المستخدمين
abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

/// حدث طلب قائمة المستخدمين
class UsersRequested extends UsersEvent {
  final UserRole? role;
  final String? search;
  final bool refresh;

  const UsersRequested({
    this.role,
    this.search,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [role, search, refresh];
}

/// حدث طلب تفاصيل مستخدم
class UserDetailsRequested extends UsersEvent {
  final String userId;

  const UserDetailsRequested(this.userId);

  @override
  List<Object> get props => [userId];
}

/// حدث تحديث بيانات مستخدم
class UserUpdated extends UsersEvent {
  final String userId;
  final Map<String, dynamic> userData;

  const UserUpdated({
    required this.userId,
    required this.userData,
  });

  @override
  List<Object> get props => [userId, userData];
}

/// حدث تحديث حالة مستخدم (تفعيل/تعطيل)
class UserStatusUpdated extends UsersEvent {
  final String userId;
  final bool isActive;

  const UserStatusUpdated({
    required this.userId,
    required this.isActive,
  });

  @override
  List<Object> get props => [userId, isActive];
}

/// حدث تحديث صورة المستخدم
class UserAvatarUpdated extends UsersEvent {
  final String userId;
  final List<int> fileBytes;
  final String fileName;

  const UserAvatarUpdated({
    required this.userId,
    required this.fileBytes,
    required this.fileName,
  });

  @override
  List<Object> get props => [userId, fileBytes, fileName];
}

