import 'package:equatable/equatable.dart';

/// أحداث إدارة الإشعارات
abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

/// حدث طلب قائمة الإشعارات
class NotificationsRequested extends NotificationsEvent {
  final String userId;
  final bool refresh;

  const NotificationsRequested({
    required this.userId,
    this.refresh = false,
  });

  @override
  List<Object> get props => [userId, refresh];
}

/// حدث تحديد إشعار كمقروء
class NotificationMarkedAsRead extends NotificationsEvent {
  final String notificationId;

  const NotificationMarkedAsRead(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

/// حدث تحديد جميع الإشعارات كمقروءة
class AllNotificationsMarkedAsRead extends NotificationsEvent {
  final String userId;

  const AllNotificationsMarkedAsRead(this.userId);

  @override
  List<Object> get props => [userId];
}

/// حدث حذف إشعار
class NotificationDeleted extends NotificationsEvent {
  final String notificationId;

  const NotificationDeleted(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

/// حدث حذف جميع الإشعارات
class AllNotificationsDeleted extends NotificationsEvent {
  final String userId;

  const AllNotificationsDeleted(this.userId);

  @override
  List<Object> get props => [userId];
}

/// حدث إنشاء إشعار جديد
class NotificationCreated extends NotificationsEvent {
  final Map<String, dynamic> notificationData;

  const NotificationCreated(this.notificationData);

  @override
  List<Object> get props => [notificationData];
}

/// حدث استلام إشعار جديد (من Firebase Cloud Messaging)
class NotificationReceived extends NotificationsEvent {
  final Map<String, dynamic> notificationData;

  const NotificationReceived(this.notificationData);

  @override
  List<Object> get props => [notificationData];
}

