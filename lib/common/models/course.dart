enum CourseStatus {
  draft,
  published,
  archived,
}

enum CourseLevel {
  beginner,
  intermediate,
  advanced,
}

class Course {
  final String id;
  final String title;
  final String description;
  final String? thumbnail;
  final String instructorId;
  final String instructorName;
  final String? instructorAvatar;
  final String? instructorAlkuraimiAccount;
  final CourseStatus status;
  final CourseLevel level;
  final double price;
  final double? discountPrice;
  final int duration; // in minutes
  final int lessonsCount;
  final double rating;
  final int reviewsCount;
  final int enrolledCount;
  final String category;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? publishedAt;
  final Map<String, dynamic>? metadata;
  final int progress; // Add progress property

  const Course({
    required this.id,
    required this.title,
    required this.description,
    this.thumbnail,
    required this.instructorId,
    required this.instructorName,
    this.instructorAvatar,
    this.instructorAlkuraimiAccount,
    required this.status,
    required this.level,
    required this.price,
    this.discountPrice,
    required this.duration,
    required this.lessonsCount,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.enrolledCount = 0,
    required this.category,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.publishedAt,
    this.metadata,
    this.progress = 0, // Add progress parameter
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnail: json['thumbnail'] as String?,
      instructorId: json['instructor_id'] as String,
      instructorName: json['instructor_name'] as String,
      instructorAvatar: json['instructor_avatar'] as String?,
      instructorAlkuraimiAccount:
          json['instructor_alkuraimi_account'] as String?,
      status: CourseStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => CourseStatus.draft,
      ),
      level: CourseLevel.values.firstWhere(
        (level) => level.name == json['level'],
        orElse: () => CourseLevel.beginner,
      ),
      price: (json['price'] as num).toDouble(),
      discountPrice: json['discount_price'] != null
          ? (json['discount_price'] as num).toDouble()
          : null,
      duration: json['duration'] as int,
      lessonsCount: json['lessons_count'] as int,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      enrolledCount: json['enrolled_count'] as int? ?? 0,
      category: json['category'] as String? ?? '',
      tags: List<String>.from(json['tags'] as List? ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      progress: json['progress'] as int? ?? 0, // Add progress from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'instructor_id': instructorId,
      'instructor_name': instructorName,
      'instructor_avatar': instructorAvatar,
      'instructor_alkuraimi_account': instructorAlkuraimiAccount,
      'status': status.name,
      'level': level.name,
      'price': price,
      'discount_price': discountPrice,
      'duration': duration,
      'lessons_count': lessonsCount,
      'rating': rating,
      'reviews_count': reviewsCount,
      'enrolled_count': enrolledCount,
      'category': category,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'published_at': publishedAt?.toIso8601String(),
      'metadata': metadata,
      'progress': progress, // Add progress to JSON
    };
  }

  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnail,
    String? instructorId,
    String? instructorName,
    String? instructorAvatar,
    String? instructorAlkuraimiAccount,
    CourseStatus? status,
    CourseLevel? level,
    double? price,
    double? discountPrice,
    int? duration,
    int? lessonsCount,
    double? rating,
    int? reviewsCount,
    int? enrolledCount,
    String? category,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? publishedAt,
    Map<String, dynamic>? metadata,
    int? progress, // Add progress parameter
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      instructorAvatar: instructorAvatar ?? this.instructorAvatar,
      instructorAlkuraimiAccount:
          instructorAlkuraimiAccount ?? this.instructorAlkuraimiAccount,
      status: status ?? this.status,
      level: level ?? this.level,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      duration: duration ?? this.duration,
      lessonsCount: lessonsCount ?? this.lessonsCount,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      enrolledCount: enrolledCount ?? this.enrolledCount,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publishedAt: publishedAt ?? this.publishedAt,
      metadata: metadata ?? this.metadata,
      progress: progress ?? this.progress, // Add progress parameter
    );
  }

  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    if (hours > 0) {
      return '$hoursس $minutesد';
    }
    return '$minutesد';
  }

  double get effectivePrice {
    return discountPrice ?? price;
  }

  String get levelText {
    switch (level) {
      case CourseLevel.beginner:
        return 'مبتدئ';
      case CourseLevel.intermediate:
        return 'متوسط';
      case CourseLevel.advanced:
        return 'متقدم';
    }
  }

  String get statusText {
    switch (status) {
      case CourseStatus.draft:
        return 'مسودة';
      case CourseStatus.published:
        return 'منشور';
      case CourseStatus.archived:
        return 'مؤرشف';
    }
  }

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Course && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Course(id: $id, title: $title, instructor: $instructorName)';
  }
}
