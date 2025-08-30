class Section {
  final String id;
  final String title;
  final String? description;
  final String courseId;
  final int orderIndex;
  final List<Lesson> lessons;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Section({
    required this.id,
    required this.title,
    this.description,
    required this.courseId,
    required this.orderIndex,
    this.lessons = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      courseId: json['course_id'] as String,
      orderIndex: json['order_index'] as int,
      lessons: json['lessons'] != null
          ? List<Lesson>.from(
              (json['lessons'] as List).map((lesson) => Lesson.fromJson(lesson)))
          : [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'course_id': courseId,
      'order_index': orderIndex,
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Section copyWith({
    String? id,
    String? title,
    String? description,
    String? courseId,
    int? orderIndex,
    List<Lesson>? lessons,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Section(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      courseId: courseId ?? this.courseId,
      orderIndex: orderIndex ?? this.orderIndex,
      lessons: lessons ?? this.lessons,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get totalDuration => lessons.fold(0, (sum, lesson) => sum + lesson.duration);

  String get formattedDuration {
    final hours = totalDuration ~/ 60;
    final minutes = totalDuration % 60;
    if (hours > 0) {
      return '$hoursس $minutesد';
    }
    return '$minutesد';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Section && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Section(id: $id, title: $title, lessons: ${lessons.length})';
  }
}

class Lesson {
  final String id;
  final String title;
  final String? description;
  final String sectionId;
  final String contentType;
  final String? contentUrl;
  final int duration;
  final bool isFree;
  final int orderIndex;
  final List<Attachment>? attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Lesson({
    required this.id,
    required this.title,
    this.description,
    required this.sectionId,
    required this.contentType,
    this.contentUrl,
    required this.duration,
    this.isFree = false,
    required this.orderIndex,
    this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      sectionId: json['section_id'] as String,
      contentType: json['content_type'] as String,
      contentUrl: json['content_url'] as String?,
      duration: json['duration'] as int,
      isFree: json['is_free'] as bool? ?? false,
      orderIndex: json['order_index'] as int,
      attachments: json['attachments'] != null
          ? List<Attachment>.from(
              (json['attachments'] as List).map((attachment) => Attachment.fromJson(attachment)))
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'section_id': sectionId,
      'content_type': contentType,
      'content_url': contentUrl,
      'duration': duration,
      'is_free': isFree,
      'order_index': orderIndex,
      'attachments': attachments?.map((attachment) => attachment.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Lesson copyWith({
    String? id,
    String? title,
    String? description,
    String? sectionId,
    String? contentType,
    String? contentUrl,
    int? duration,
    bool? isFree,
    int? orderIndex,
    List<Attachment>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      sectionId: sectionId ?? this.sectionId,
      contentType: contentType ?? this.contentType,
      contentUrl: contentUrl ?? this.contentUrl,
      duration: duration ?? this.duration,
      isFree: isFree ?? this.isFree,
      orderIndex: orderIndex ?? this.orderIndex,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Lesson && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Lesson(id: $id, title: $title)';
  }
}

class Attachment {
  final String id;
  final String title;
  final String? description;
  final String fileUrl;
  final String fileType;
  final int fileSize;
  final String lessonId;
  final DateTime createdAt;

  const Attachment({
    required this.id,
    required this.title,
    this.description,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    required this.lessonId,
    required this.createdAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      fileUrl: json['file_url'] as String,
      fileType: json['file_type'] as String,
      fileSize: json['file_size'] as int,
      lessonId: json['lesson_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size': fileSize,
      'lesson_id': lessonId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  String get fileExtension {
    final parts = fileUrl.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return '';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attachment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Attachment(id: $id, title: $title, fileType: $fileType)';
  }
}

