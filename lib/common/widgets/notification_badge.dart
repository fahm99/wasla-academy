import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notifications/notifications_bloc.dart';
import '../bloc/notifications/notifications_state.dart';
import '../themes/app_theme.dart';

/// ويدجت شارة الإشعارات
/// يعرض عدد الإشعارات غير المقروءة
class NotificationBadge extends StatelessWidget {
  final Widget child;
  final double size;
  final double offset;
  final Color? badgeColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const NotificationBadge({
    super.key,
    required this.child,
    this.size = 18.0,
    this.offset = 12.0,
    this.badgeColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        int unreadCount = 0;
        
        if (state is NotificationsLoaded) {
          unreadCount = state.unreadCount;
        }
        
        return Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: onTap,
              child: child,
            ),
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: badgeColor ?? AppTheme.errorColor,
                    borderRadius: BorderRadius.circular(size / 2),
                  ),
                  constraints: BoxConstraints(
                    minWidth: size,
                    minHeight: size,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: TextStyle(
                        color: textColor ?? Colors.white,
                        fontSize: size * 0.6,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

