import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/notifications/notifications_bloc.dart';
import '../bloc/notifications/notifications_event.dart';
import '../bloc/notifications/notifications_state.dart';
import '../models/notification.dart' as model;
import '../themes/app_theme.dart';
import '../widgets/loading_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _scrollController = ScrollController();
  bool _isSelectionMode = false;
  final Set<String> _selectedNotifications = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // طلب الإشعارات عند فتح الشاشة
    final userId = context.read<NotificationsBloc>().state
            is NotificationsLoaded
        ? (context.read<NotificationsBloc>().state as NotificationsLoaded)
                .notifications
                .isNotEmpty
            ? (context.read<NotificationsBloc>().state as NotificationsLoaded)
                .notifications
                .first['user_id']
            : 'current_user_id'
        : 'current_user_id';

    context
        .read<NotificationsBloc>()
        .add(NotificationsRequested(userId: userId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<NotificationsBloc>().state;
      if (state is NotificationsLoaded && !state.hasReachedMax) {
        final userId = state.notifications.isNotEmpty
            ? state.notifications.first['user_id']
            : 'current_user_id';

        context
            .read<NotificationsBloc>()
            .add(NotificationsRequested(userId: userId));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedNotifications.clear();
      }
    });
  }

  void _toggleNotificationSelection(String notificationId) {
    setState(() {
      if (_selectedNotifications.contains(notificationId)) {
        _selectedNotifications.remove(notificationId);
      } else {
        _selectedNotifications.add(notificationId);
      }

      if (_selectedNotifications.isEmpty && _isSelectionMode) {
        _isSelectionMode = false;
      }
    });
  }

  void _selectAll(List<Map<String, dynamic>> notifications) {
    setState(() {
      if (_selectedNotifications.length == notifications.length) {
        // إذا كانت جميع الإشعارات محددة، قم بإلغاء تحديد الجميع
        _selectedNotifications.clear();
        _isSelectionMode = false;
      } else {
        // تحديد جميع الإشعارات
        _selectedNotifications.clear();
        for (final notification in notifications) {
          _selectedNotifications.add(notification['id']);
        }
      }
    });
  }

  void _markSelectedAsRead() {
    for (final notificationId in _selectedNotifications) {
      context
          .read<NotificationsBloc>()
          .add(NotificationMarkedAsRead(notificationId));
    }
    setState(() {
      _isSelectionMode = false;
      _selectedNotifications.clear();
    });
  }

  void _deleteSelected() {
    for (final notificationId in _selectedNotifications) {
      context
          .read<NotificationsBloc>()
          .add(NotificationDeleted(notificationId));
    }
    setState(() {
      _isSelectionMode = false;
      _selectedNotifications.clear();
    });
  }

  void _markAllAsRead(String userId) {
    context.read<NotificationsBloc>().add(AllNotificationsMarkedAsRead(userId));
    setState(() {
      _isSelectionMode = false;
      _selectedNotifications.clear();
    });
  }

  void _deleteAll(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف جميع الإشعارات'),
        content: const Text(
            'هل أنت متأكد من حذف جميع الإشعارات؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context
                  .read<NotificationsBloc>()
                  .add(AllNotificationsDeleted(userId));
              setState(() {
                _isSelectionMode = false;
                _selectedNotifications.clear();
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectionMode
            ? 'تم تحديد ${_selectedNotifications.length}'
            : 'الإشعارات'),
        actions: [
          if (!_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => _buildOptionsSheet(context),
                );
              },
            ),
          if (_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleSelectionMode,
            ),
        ],
      ),
      body: BlocConsumer<NotificationsBloc, NotificationsState>(
        listener: (context, state) {
          if (state is NotificationOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is NotificationOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationsInitial || state is NotificationsLoading) {
            return const Center(child: LoadingWidget());
          }

          if (state is NotificationsLoaded) {
            final notifications = state.notifications;

            if (notifications.isEmpty) {
              return _buildEmptyState();
            }

            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    final userId = notifications.isNotEmpty
                        ? notifications.first['user_id']
                        : 'current_user_id';

                    context.read<NotificationsBloc>().add(
                          NotificationsRequested(userId: userId, refresh: true),
                        );
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: notifications.length + 1,
                    itemBuilder: (context, index) {
                      if (index == notifications.length) {
                        return _buildBottomLoader(state);
                      }

                      return _buildNotificationItem(notifications[index]);
                    },
                  ),
                ),
                if (_isSelectionMode)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: _buildSelectionToolbar(),
                  ),
              ],
            );
          }

          return const Center(child: Text('حدث خطأ أثناء تحميل الإشعارات'));
        },
      ),
    );
  }

  Widget _buildOptionsSheet(BuildContext context) {
    final state = context.read<NotificationsBloc>().state;
    final userId =
        state is NotificationsLoaded && state.notifications.isNotEmpty
            ? state.notifications.first['user_id']
            : 'current_user_id';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: const Text('تحديد متعدد'),
            onTap: () {
              Navigator.pop(context);
              _toggleSelectionMode();
            },
          ),
          ListTile(
            leading: const Icon(Icons.done_all),
            title: const Text('تحديد الكل كمقروء'),
            onTap: () {
              Navigator.pop(context);
              _markAllAsRead(userId);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('حذف الكل', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _deleteAll(userId);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر هنا جميع الإشعارات والتنبيهات الخاصة بك',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomLoader(NotificationsLoaded state) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: state.hasReachedMax
          ? const SizedBox()
          : const CircularProgressIndicator(),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final notificationType = model.NotificationType.values.firstWhere(
      (type) => type.name == notification['type'],
      orElse: () => model.NotificationType.system,
    );

    final isRead = notification['is_read'] as bool;
    final notificationId = notification['id'] as String;
    final isSelected = _selectedNotifications.contains(notificationId);

    return InkWell(
      onTap: _isSelectionMode
          ? () => _toggleNotificationSelection(notificationId)
          : () {
              // تحديد الإشعار كمقروء عند النقر عليه
              if (!isRead) {
                context
                    .read<NotificationsBloc>()
                    .add(NotificationMarkedAsRead(notificationId));
              }

              // التنقل إلى الشاشة المرتبطة بالإشعار إذا كان هناك
              if (notification['related_id'] != null) {
                // التنقل حسب نوع الإشعار
                switch (notificationType) {
                  case model.NotificationType.course:
                    // Navigator.of(context).pushNamed('/course-details', arguments: notification['related_id']);
                    break;
                  case model.NotificationType.payment:
                    // Navigator.of(context).pushNamed('/payment-details', arguments: notification['related_id']);
                    break;
                  default:
                    break;
                }
              }
            },
      onLongPress: () {
        if (!_isSelectionMode) {
          _toggleSelectionMode();
        }
        _toggleNotificationSelection(notificationId);
      },
      child: Container(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
        child: ListTile(
          leading: _isSelectionMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: (_) =>
                      _toggleNotificationSelection(notificationId),
                  activeColor: AppTheme.primaryColor,
                )
              : Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notificationType)
                        .withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(notificationType),
                    color: _getNotificationColor(notificationType),
                  ),
                ),
          title: Text(
            notification['title'] as String,
            style: TextStyle(
              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification['message'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(
                    DateTime.parse(notification['created_at'] as String)),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          trailing: !_isSelectionMode && !isRead
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

  Widget _buildSelectionToolbar() {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton.icon(
              onPressed: _markSelectedAsRead,
              icon: const Icon(Icons.done_all),
              label: const Text('تحديد كمقروء'),
            ),
            TextButton.icon(
              onPressed: _deleteSelected,
              icon: const Icon(Icons.delete),
              label: const Text('حذف'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(model.NotificationType type) {
    switch (type) {
      case model.NotificationType.system:
        return Icons.info_outline;
      case model.NotificationType.course:
        return Icons.book_outlined;
      case model.NotificationType.payment:
        return Icons.payment_outlined;
      case model.NotificationType.message:
        return Icons.message_outlined;
      case model.NotificationType.achievement:
        return Icons.emoji_events_outlined;
    }
  }

  Color _getNotificationColor(model.NotificationType type) {
    switch (type) {
      case model.NotificationType.system:
        return Colors.blue;
      case model.NotificationType.course:
        return Colors.green;
      case model.NotificationType.payment:
        return Colors.purple;
      case model.NotificationType.message:
        return Colors.orange;
      case model.NotificationType.achievement:
        return Colors.amber;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
