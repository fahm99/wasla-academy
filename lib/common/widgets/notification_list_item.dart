import 'package:flutter/material.dart';
import '../models/notification.dart' as notification_model;
import '../themes/app_theme.dart';

class NotificationListItem extends StatelessWidget {
  final notification_model.Notification notification;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Function(bool?)? onCheckboxChanged;

  const NotificationListItem({
    super.key,
    required this.notification,
    this.isSelectionMode = false,
    this.isSelected = false,
    required this.onTap,
    required this.onLongPress,
    this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
        child: ListTile(
          leading: _buildLeading(),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight:
                  notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                notification.formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          trailing: !isSelectionMode && !notification.isRead
              ? Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildLeading() {
    if (isSelectionMode) {
      return Checkbox(
        value: isSelected,
        onChanged: onCheckboxChanged,
        activeColor: AppTheme.primaryColor,
      );
    }

    return Container(
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
    );
  }

  IconData _getNotificationIcon() {
    switch (notification.type) {
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
    }
  }

  Color _getNotificationColor() {
    switch (notification.type) {
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
    }
  }
}
