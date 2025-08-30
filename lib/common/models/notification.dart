enum NotificationType {
  system,
  course,
  payment,
  message,
  achievement,
}

class Notification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final String? relatedId;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    this.relatedId,
    required this.createdAt,
    this.metadata,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: NotificationType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      isRead: json['is_read'] as bool,
      relatedId: json['related_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'is_read': isRead,
      'related_id': relatedId,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    String? relatedId,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  String get typeText {
    switch (type) {
      case NotificationType.system:
        return 'إشعار نظام';
      case NotificationType.course:
        return 'إشعار كورس';
      case NotificationType.payment:
        return 'إشعار دفع';
      case NotificationType.message:
        return 'رسالة';
      case NotificationType.achievement:
        return 'إنجاز';
    }
  }

  String get iconName {
    switch (type) {
      case NotificationType.system:
        return 'info';
      case NotificationType.course:
        return 'book';
      case NotificationType.payment:
        return 'credit_card';
      case NotificationType.message:
        return 'message';
      case NotificationType.achievement:
        return 'emoji_events';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Notification(id: $id, title: $title, type: $typeText)';
  }
}

