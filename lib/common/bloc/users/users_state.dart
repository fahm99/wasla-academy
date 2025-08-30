import 'package:equatable/equatable.dart';
import '../../models/user.dart';

/// حالات إدارة المستخدمين
abstract class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object?> get props => [];
}

/// حالة التحميل الأولي
class UsersInitial extends UsersState {}

/// حالة جاري تحميل المستخدمين
class UsersLoading extends UsersState {}

/// حالة تحميل المستخدمين بنجاح
class UsersLoaded extends UsersState {
  final List<User> users;
  final bool hasReachedMax;
  final UserRole? role;
  final String? search;

  const UsersLoaded({
    required this.users,
    this.hasReachedMax = false,
    this.role,
    this.search,
  });

  @override
  List<Object?> get props => [users, hasReachedMax, role, search];

  UsersLoaded copyWith({
    List<User>? users,
    bool? hasReachedMax,
    UserRole? role,
    String? search,
  }) {
    return UsersLoaded(
      users: users ?? this.users,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      role: role ?? this.role,
      search: search ?? this.search,
    );
  }
}

/// حالة تحميل تفاصيل مستخدم بنجاح
class UserDetailsLoaded extends UsersState {
  final User user;

  const UserDetailsLoaded(this.user);

  @override
  List<Object> get props => [user];
}

/// حالة نجاح العملية
class UserOperationSuccess extends UsersState {
  final String message;
  final String operationType;

  const UserOperationSuccess({
    required this.message,
    required this.operationType,
  });

  @override
  List<Object> get props => [message, operationType];
}

/// حالة فشل العملية
class UserOperationFailure extends UsersState {
  final String message;

  const UserOperationFailure(this.message);

  @override
  List<Object> get props => [message];
}

