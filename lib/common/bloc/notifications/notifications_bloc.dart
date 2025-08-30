import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/notification_service.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

/// Bloc لإدارة الإشعارات
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationService _notificationService;
  StreamSubscription? _notificationSubscription;

  // عدد العناصر في كل صفحة
  static const int _pageSize = 20;

  NotificationsBloc({
    required NotificationService notificationService,
  })  : _notificationService = notificationService,
        super(NotificationsInitial()) {
    on<NotificationsRequested>(_onNotificationsRequested);
    on<NotificationMarkedAsRead>(_onNotificationMarkedAsRead);
    on<AllNotificationsMarkedAsRead>(_onAllNotificationsMarkedAsRead);
    on<NotificationDeleted>(_onNotificationDeleted);
    on<AllNotificationsDeleted>(_onAllNotificationsDeleted);
    on<NotificationCreated>(_onNotificationCreated);
    on<NotificationReceived>(_onNotificationReceived);

    // الاستماع للإشعارات الجديدة
    _notificationSubscription = _notificationService.notificationStream.listen(
      (notification) => add(NotificationReceived(notification)),
    );
  }

  /// معالجة حدث طلب قائمة الإشعارات
  Future<void> _onNotificationsRequested(
    NotificationsRequested event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      // إذا كان هناك طلب تحديث أو حالة أولية، نبدأ من الصفر
      if (event.refresh || state is NotificationsInitial) {
        emit(NotificationsLoading());
        
        final notifications = await _notificationService.getNotifications(
          userId: event.userId,
          limit: _pageSize,
        );
        
        final unreadCount = await _notificationService.getUnreadCount(event.userId);
        
        emit(NotificationsLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
          hasReachedMax: notifications.length < _pageSize,
        ));
      } else if (state is NotificationsLoaded) {
        // تحميل المزيد من الإشعارات (pagination)
        final currentState = state as NotificationsLoaded;
        
        if (!currentState.hasReachedMax) {
          final notifications = await _notificationService.getNotifications(
            userId: event.userId,
            limit: _pageSize,
            offset: currentState.notifications.length,
          );
          
          emit(notifications.isEmpty
              ? currentState.copyWith(hasReachedMax: true)
              : currentState.copyWith(
                  notifications: [...currentState.notifications, ...notifications],
                  hasReachedMax: notifications.length < _pageSize,
                ));
        }
      }
    } catch (e) {
      emit(NotificationOperationFailure('فشل تحميل الإشعارات: ${e.toString()}'));
    }
  }

  /// معالجة حدث تحديد إشعار كمقروء
  Future<void> _onNotificationMarkedAsRead(
    NotificationMarkedAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final success = await _notificationService.markAsRead(event.notificationId);
      
      if (success) {
        if (state is NotificationsLoaded) {
          final currentState = state as NotificationsLoaded;
          final updatedNotifications = currentState.notifications.map((notification) {
            if (notification['id'] == event.notificationId) {
              return {...notification, 'is_read': true};
            }
            return notification;
          }).toList();
          
          emit(currentState.copyWith(
            notifications: updatedNotifications,
            unreadCount: currentState.unreadCount > 0 ? currentState.unreadCount - 1 : 0,
          ));
        }
      } else {
        emit(const NotificationOperationFailure('فشل تحديد الإشعار كمقروء'));
      }
    } catch (e) {
      emit(NotificationOperationFailure('فشل تحديد الإشعار كمقروء: ${e.toString()}'));
    }
  }

  /// معالجة حدث تحديد جميع الإشعارات كمقروءة
  Future<void> _onAllNotificationsMarkedAsRead(
    AllNotificationsMarkedAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final success = await _notificationService.markAllAsRead(event.userId);
      
      if (success) {
        if (state is NotificationsLoaded) {
          final currentState = state as NotificationsLoaded;
          final updatedNotifications = currentState.notifications.map((notification) {
            return {...notification, 'is_read': true};
          }).toList();
          
          emit(currentState.copyWith(
            notifications: updatedNotifications,
            unreadCount: 0,
          ));
        }
        
        emit(const NotificationOperationSuccess(
          message: 'تم تحديد جميع الإشعارات كمقروءة',
          operationType: 'mark_all_read',
        ));
      } else {
        emit(const NotificationOperationFailure('فشل تحديد جميع الإشعارات كمقروءة'));
      }
    } catch (e) {
      emit(NotificationOperationFailure('فشل تحديد جميع الإشعارات كمقروءة: ${e.toString()}'));
    }
  }

  /// معالجة حدث حذف إشعار
  Future<void> _onNotificationDeleted(
    NotificationDeleted event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final success = await _notificationService.deleteNotification(event.notificationId);
      
      if (success) {
        if (state is NotificationsLoaded) {
          final currentState = state as NotificationsLoaded;
          final updatedNotifications = currentState.notifications
              .where((notification) => notification['id'] != event.notificationId)
              .toList();
          
          // تحديث عدد الإشعارات غير المقروءة
          final deletedNotification = currentState.notifications
              .firstWhere((notification) => notification['id'] == event.notificationId);
          
          final unreadCount = deletedNotification['is_read'] == false
              ? currentState.unreadCount - 1
              : currentState.unreadCount;
          
          emit(currentState.copyWith(
            notifications: updatedNotifications,
            unreadCount: unreadCount < 0 ? 0 : unreadCount,
          ));
        }
        
        emit(const NotificationOperationSuccess(
          message: 'تم حذف الإشعار بنجاح',
          operationType: 'delete',
        ));
      } else {
        emit(const NotificationOperationFailure('فشل حذف الإشعار'));
      }
    } catch (e) {
      emit(NotificationOperationFailure('فشل حذف الإشعار: ${e.toString()}'));
    }
  }

  /// معالجة حدث حذف جميع الإشعارات
  Future<void> _onAllNotificationsDeleted(
    AllNotificationsDeleted event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final success = await _notificationService.deleteAllNotifications(event.userId);
      
      if (success) {
        if (state is NotificationsLoaded) {
          final currentState = state as NotificationsLoaded;
          
          emit(currentState.copyWith(
            notifications: [],
            unreadCount: 0,
          ));
        }
        
        emit(const NotificationOperationSuccess(
          message: 'تم حذف جميع الإشعارات بنجاح',
          operationType: 'delete_all',
        ));
      } else {
        emit(const NotificationOperationFailure('فشل حذف جميع الإشعارات'));
      }
    } catch (e) {
      emit(NotificationOperationFailure('فشل حذف جميع الإشعارات: ${e.toString()}'));
    }
  }

  /// معالجة حدث إنشاء إشعار جديد
  Future<void> _onNotificationCreated(
    NotificationCreated event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final success = await _notificationService.createNotification(event.notificationData);
      
      if (success) {
        emit(const NotificationOperationSuccess(
          message: 'تم إنشاء الإشعار بنجاح',
          operationType: 'create',
        ));
      } else {
        emit(const NotificationOperationFailure('فشل إنشاء الإشعار'));
      }
    } catch (e) {
      emit(NotificationOperationFailure('فشل إنشاء الإشعار: ${e.toString()}'));
    }
  }

  /// معالجة حدث استلام إشعار جديد
  void _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationsState> emit,
  ) {
    // إضافة الإشعار الجديد إلى القائمة الحالية
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      final updatedNotifications = [
        event.notificationData,
        ...currentState.notifications,
      ];
      
      emit(currentState.copyWith(
        notifications: updatedNotifications,
        unreadCount: currentState.unreadCount + 1,
      ));
    }
    
    // إرسال حالة استلام إشعار جديد
    emit(NewNotificationReceived(event.notificationData));
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}

