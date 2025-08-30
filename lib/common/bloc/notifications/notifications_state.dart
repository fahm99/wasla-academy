import 'package:equatable/equatable.dart';

/// حالات إدارة الإشعارات
abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

/// حالة التحميل الأولي
class NotificationsInitial extends NotificationsState {}

/// حالة جاري تحميل الإشعارات
class NotificationsLoading extends NotificationsState {}

/// حالة تحميل الإشعارات بنجاح
class NotificationsLoaded extends NotificationsState {
  final List<Map<String, dynamic>> notifications;
  final int unreadCount;
  final bool hasReachedMax;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
    this.hasReachedMax = false,
  });

  @override
  List<Object> get props => [notifications, unreadCount, hasReachedMax];

  NotificationsLoaded copyWith({
    List<Map<String, dynamic>>? notifications,
    int? unreadCount,
    bool? hasReachedMax,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

/// حالة نجاح العملية
class NotificationOperationSuccess extends NotificationsState {
  final String message;
  final String operationType;

  const NotificationOperationSuccess({
    required this.message,
    required this.operationType,
  });

  @override
  List<Object> get props => [message, operationType];
}

/// حالة فشل العملية
class NotificationOperationFailure extends NotificationsState {
  final String message;

  const NotificationOperationFailure(this.message);

  @override
  List<Object> get props => [message];
}

/// حالة استلام إشعار جديد
class NewNotificationReceived extends NotificationsState {
  final Map<String, dynamic> notification;

  const NewNotificationReceived(this.notification);

  @override
  List<Object> get props => [notification];
}

