import 'package:flutter/material.dart';
import '../models/notification.dart' as notification_model;

class NotificationPopup extends StatefulWidget {
  final notification_model.Notification notification;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;
  final Duration displayDuration;
  final Duration animationDuration;

  const NotificationPopup({
    super.key,
    required this.notification,
    this.onDismiss,
    this.onTap,
    this.displayDuration = const Duration(seconds: 4),
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<NotificationPopup> createState() => _NotificationPopupState();
}

class _NotificationPopupState extends State<NotificationPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    _controller.forward();

    // تأخير لإخفاء الإشعار بعد المدة المحددة
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _dismissNotification();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismissNotification() {
    _controller.reverse().then((_) {
      if (widget.onDismiss != null) {
        widget.onDismiss!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getNotificationColor().withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getNotificationIcon(),
                        color: _getNotificationColor(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.notification.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.notification.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _dismissNotification,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon() {
    switch (widget.notification.type) {
      case notification_model.NotificationType.system:
        return Icons.info_outline;
      case notification_model.NotificationType.course:
        return Icons.book_outlined;
      case notification_model.NotificationType.payment:
        return Icons.payment_outlined;
      case notification_model.NotificationType.message:
        return Icons.message_outlined;
      case notification_model.NotificationType.achievement:
        return Icons.emoji_events_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Color _getNotificationColor() {
    switch (widget.notification.type) {
      case notification_model.NotificationType.system:
        return Colors.blue;
      case notification_model.NotificationType.course:
        return Colors.green;
      case notification_model.NotificationType.payment:
        return Colors.purple;
      case notification_model.NotificationType.message:
        return Colors.orange;
      case notification_model.NotificationType.achievement:
        return Colors.amber;
      default:
        return Colors.blue;
    }
  }
}
