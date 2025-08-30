// live_session_state.dart
import 'package:equatable/equatable.dart';
import '../../models/live_session.dart';

enum LiveSessionStatus {
  initial,
  loading,
  loaded,
  joining,
  joined,
  leaving,
  error,
}

class LiveSessionState extends Equatable {
  final LiveSessionStatus status;
  final List<LiveSession> sessions;
  final LiveSession? currentSession;
  final List<LiveSessionParticipant> participants;
  final List<LiveChatMessage> chatMessages;
  final bool isJoined;
  final bool isMuted;
  final bool isVideoEnabled;
  final bool isSpeakerEnabled;
  final bool isScreenSharing;
  final bool isRecording;
  final StreamQuality videoQuality;
  final String? error;
  final String? currentUserRole;

  const LiveSessionState({
    this.status = LiveSessionStatus.initial,
    this.sessions = const [],
    this.currentSession,
    this.participants = const [],
    this.chatMessages = const [],
    this.isJoined = false,
    this.isMuted = false,
    this.isVideoEnabled = true,
    this.isSpeakerEnabled = true,
    this.isScreenSharing = false,
    this.isRecording = false,
    this.videoQuality = StreamQuality.auto,
    this.error,
    this.currentUserRole,
  });

  @override
  List<Object?> get props => [
        status,
        sessions,
        currentSession,
        participants,
        chatMessages,
        isJoined,
        isMuted,
        isVideoEnabled,
        isSpeakerEnabled,
        isScreenSharing,
        isRecording,
        videoQuality,
        error,
        currentUserRole,
      ];

  LiveSessionState copyWith({
    LiveSessionStatus? status,
    List<LiveSession>? sessions,
    LiveSession? currentSession,
    List<LiveSessionParticipant>? participants,
    List<LiveChatMessage>? chatMessages,
    bool? isJoined,
    bool? isMuted,
    bool? isVideoEnabled,
    bool? isSpeakerEnabled,
    bool? isScreenSharing,
    bool? isRecording,
    StreamQuality? videoQuality,
    String? error,
    String? currentUserRole,
  }) {
    return LiveSessionState(
      status: status ?? this.status,
      sessions: sessions ?? this.sessions,
      currentSession: currentSession ?? this.currentSession,
      participants: participants ?? this.participants,
      chatMessages: chatMessages ?? this.chatMessages,
      isJoined: isJoined ?? this.isJoined,
      isMuted: isMuted ?? this.isMuted,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isSpeakerEnabled: isSpeakerEnabled ?? this.isSpeakerEnabled,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
      isRecording: isRecording ?? this.isRecording,
      videoQuality: videoQuality ?? this.videoQuality,
      error: error,
      currentUserRole: currentUserRole ?? this.currentUserRole,
    );
  }

  // Helper getters
  bool get isInstructor => currentUserRole == 'instructor';
  bool get isStudent => currentUserRole == 'student';
  bool get canControlSession => isInstructor;
  bool get canStartRecording => isInstructor;
  bool get canShareScreen => isInstructor;
  bool get isSessionActive => currentSession?.isLive == true;

  int get participantCount => participants.where((p) => p.isActive).length;

  List<LiveSessionParticipant> get activeParticipants =>
      participants.where((p) => p.isActive).toList();

  List<LiveSessionParticipant> get instructors =>
      participants.where((p) => p.isInstructor && p.isActive).toList();

  List<LiveSessionParticipant> get students =>
      participants.where((p) => p.isStudent && p.isActive).toList();
}
