import 'package:equatable/equatable.dart';

enum LiveSessionStatus {
  scheduled,
  live,
  ended,
  cancelled,
}

enum StreamQuality {
  low,
  medium,
  high,
  auto,
}

class LiveSession extends Equatable {
  final String id;
  final String title;
  final String description;
  final String instructorId;
  final String instructorName;
  final String? instructorAvatar;
  final String courseId;
  final String courseName;
  final DateTime scheduledAt;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int duration; // في الدقائق
  final LiveSessionStatus status;
  final int maxParticipants;
  final int currentParticipants;
  final List<String> tags;
  final bool isRecorded;
  final String? recordingUrl;
  final bool allowChat;
  final bool allowParticipantsVideo;
  final bool allowParticipantsAudio;
  final String? meetingId;
  final String? agoraToken;
  final String? streamKey;
  final StreamQuality quality;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LiveSession({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorId,
    required this.instructorName,
    this.instructorAvatar,
    required this.courseId,
    required this.courseName,
    required this.scheduledAt,
    this.startedAt,
    this.endedAt,
    required this.duration,
    required this.status,
    this.maxParticipants = 100,
    this.currentParticipants = 0,
    this.tags = const [],
    this.isRecorded = false,
    this.recordingUrl,
    this.allowChat = true,
    this.allowParticipantsVideo = false,
    this.allowParticipantsAudio = false,
    this.meetingId,
    this.agoraToken,
    this.streamKey,
    this.quality = StreamQuality.auto,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        instructorId,
        instructorName,
        instructorAvatar,
        courseId,
        courseName,
        scheduledAt,
        startedAt,
        endedAt,
        duration,
        status,
        maxParticipants,
        currentParticipants,
        tags,
        isRecorded,
        recordingUrl,
        allowChat,
        allowParticipantsVideo,
        allowParticipantsAudio,
        meetingId,
        agoraToken,
        streamKey,
        quality,
        metadata,
        createdAt,
        updatedAt,
      ];

  LiveSession copyWith({
    String? id,
    String? title,
    String? description,
    String? instructorId,
    String? instructorName,
    String? instructorAvatar,
    String? courseId,
    String? courseName,
    DateTime? scheduledAt,
    DateTime? startedAt,
    DateTime? endedAt,
    int? duration,
    LiveSessionStatus? status,
    int? maxParticipants,
    int? currentParticipants,
    List<String>? tags,
    bool? isRecorded,
    String? recordingUrl,
    bool? allowChat,
    bool? allowParticipantsVideo,
    bool? allowParticipantsAudio,
    String? meetingId,
    String? agoraToken,
    String? streamKey,
    StreamQuality? quality,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LiveSession(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      instructorAvatar: instructorAvatar ?? this.instructorAvatar,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      tags: tags ?? this.tags,
      isRecorded: isRecorded ?? this.isRecorded,
      recordingUrl: recordingUrl ?? this.recordingUrl,
      allowChat: allowChat ?? this.allowChat,
      allowParticipantsVideo:
          allowParticipantsVideo ?? this.allowParticipantsVideo,
      allowParticipantsAudio:
          allowParticipantsAudio ?? this.allowParticipantsAudio,
      meetingId: meetingId ?? this.meetingId,
      agoraToken: agoraToken ?? this.agoraToken,
      streamKey: streamKey ?? this.streamKey,
      quality: quality ?? this.quality,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructor_id': instructorId,
      'instructor_name': instructorName,
      'instructor_avatar': instructorAvatar,
      'course_id': courseId,
      'course_name': courseName,
      'scheduled_at': scheduledAt.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'duration': duration,
      'status': status.name,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'tags': tags,
      'is_recorded': isRecorded,
      'recording_url': recordingUrl,
      'allow_chat': allowChat,
      'allow_participants_video': allowParticipantsVideo,
      'allow_participants_audio': allowParticipantsAudio,
      'meeting_id': meetingId,
      'agora_token': agoraToken,
      'stream_key': streamKey,
      'quality': quality.name,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory LiveSession.fromJson(Map<String, dynamic> json) {
    return LiveSession(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      instructorId: json['instructor_id'],
      instructorName: json['instructor_name'],
      instructorAvatar: json['instructor_avatar'],
      courseId: json['course_id'],
      courseName: json['course_name'],
      scheduledAt: DateTime.parse(json['scheduled_at']),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      endedAt:
          json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      duration: json['duration'],
      status: LiveSessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LiveSessionStatus.scheduled,
      ),
      maxParticipants: json['max_participants'] ?? 100,
      currentParticipants: json['current_participants'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      isRecorded: json['is_recorded'] ?? false,
      recordingUrl: json['recording_url'],
      allowChat: json['allow_chat'] ?? true,
      allowParticipantsVideo: json['allow_participants_video'] ?? false,
      allowParticipantsAudio: json['allow_participants_audio'] ?? false,
      meetingId: json['meeting_id'],
      agoraToken: json['agora_token'],
      streamKey: json['stream_key'],
      quality: StreamQuality.values.firstWhere(
        (e) => e.name == json['quality'],
        orElse: () => StreamQuality.auto,
      ),
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Helper getters
  bool get isLive => status == LiveSessionStatus.live;
  bool get isScheduled => status == LiveSessionStatus.scheduled;
  bool get isEnded => status == LiveSessionStatus.ended;
  bool get isCancelled => status == LiveSessionStatus.cancelled;

  bool get canJoin => isLive || isScheduled;
  bool get isFull => currentParticipants >= maxParticipants;

  Duration get remainingTime {
    if (isLive && startedAt != null) {
      final elapsed = DateTime.now().difference(startedAt!);
      final total = Duration(minutes: duration);
      return total - elapsed;
    }
    return Duration.zero;
  }

  Duration get timeUntilStart {
    if (isScheduled) {
      return scheduledAt.difference(DateTime.now());
    }
    return Duration.zero;
  }

  String get statusText {
    switch (status) {
      case LiveSessionStatus.scheduled:
        return 'مجدولة';
      case LiveSessionStatus.live:
        return 'مباشر';
      case LiveSessionStatus.ended:
        return 'انتهت';
      case LiveSessionStatus.cancelled:
        return 'ملغية';
    }
  }

  String get qualityText {
    switch (quality) {
      case StreamQuality.low:
        return 'منخفضة';
      case StreamQuality.medium:
        return 'متوسطة';
      case StreamQuality.high:
        return 'عالية';
      case StreamQuality.auto:
        return 'تلقائي';
    }
  }
}

class LiveSessionParticipant extends Equatable {
  final String id;
  final String sessionId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String role; // instructor, student
  final DateTime joinedAt;
  final DateTime? leftAt;
  final bool isVideoEnabled;
  final bool isAudioEnabled;
  final bool isScreenSharing;
  final bool isHandRaised;
  final Map<String, dynamic> metadata;

  const LiveSessionParticipant({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.role,
    required this.joinedAt,
    this.leftAt,
    this.isVideoEnabled = false,
    this.isAudioEnabled = false,
    this.isScreenSharing = false,
    this.isHandRaised = false,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        sessionId,
        userId,
        userName,
        userAvatar,
        role,
        joinedAt,
        leftAt,
        isVideoEnabled,
        isAudioEnabled,
        isScreenSharing,
        isHandRaised,
        metadata,
      ];

  bool get isInstructor => role == 'instructor';
  bool get isStudent => role == 'student';
  bool get isActive => leftAt == null;

  LiveSessionParticipant copyWith({
    String? id,
    String? sessionId,
    String? userId,
    String? userName,
    String? userAvatar,
    String? role,
    DateTime? joinedAt,
    DateTime? leftAt,
    bool? isVideoEnabled,
    bool? isAudioEnabled,
    bool? isScreenSharing,
    bool? isHandRaised,
    Map<String, dynamic>? metadata,
  }) {
    return LiveSessionParticipant(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      leftAt: leftAt ?? this.leftAt,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isAudioEnabled: isAudioEnabled ?? this.isAudioEnabled,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
      isHandRaised: isHandRaised ?? this.isHandRaised,
      metadata: metadata ?? this.metadata,
    );
  }
}

class LiveChatMessage extends Equatable {
  final String id;
  final String sessionId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String message;
  final String type; // text, system, emoji
  final DateTime timestamp;
  final bool isInstructor;
  final Map<String, dynamic> metadata;

  const LiveChatMessage({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.message,
    this.type = 'text',
    required this.timestamp,
    this.isInstructor = false,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [
        id,
        sessionId,
        userId,
        userName,
        userAvatar,
        message,
        type,
        timestamp,
        isInstructor,
        metadata,
      ];

  bool get isSystemMessage => type == 'system';
  bool get isTextMessage => type == 'text';
  bool get isEmojiMessage => type == 'emoji';

  LiveChatMessage copyWith({
    String? id,
    String? sessionId,
    String? userId,
    String? userName,
    String? userAvatar,
    String? message,
    String? type,
    DateTime? timestamp,
    bool? isInstructor,
    Map<String, dynamic>? metadata,
  }) {
    return LiveChatMessage(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isInstructor: isInstructor ?? this.isInstructor,
      metadata: metadata ?? this.metadata,
    );
  }
}
