// live_session_bloc.dart
import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/live_session.dart' as models;
import '../../services/live_video_service.dart';
import 'live_session_event.dart';
import 'live_session_state.dart';

class LiveSessionBloc extends Bloc<LiveSessionEvent, LiveSessionState> {
  final LiveVideoService _liveVideoService;
  StreamSubscription? _participantJoinedSubscription;
  StreamSubscription? _participantLeftSubscription;
  StreamSubscription? _connectionStateSubscription;

  LiveSessionBloc({
    required LiveVideoService liveVideoService,
  })  : _liveVideoService = liveVideoService,
        super(const LiveSessionState()) {
    // Register event handlers
    on<LoadLiveSessions>(_onLoadLiveSessions);
    on<LoadLiveSession>(_onLoadLiveSession);
    on<CreateLiveSession>(_onCreateLiveSession);
    on<UpdateLiveSession>(_onUpdateLiveSession);
    on<JoinLiveSession>(_onJoinLiveSession);
    on<LeaveLiveSession>(_onLeaveLiveSession);
    on<StartLiveSession>(_onStartLiveSession);
    on<EndLiveSession>(_onEndLiveSession);
    on<ToggleMicrophone>(_onToggleMicrophone);
    on<ToggleCamera>(_onToggleCamera);
    on<SwitchCamera>(_onSwitchCamera);
    on<ToggleSpeaker>(_onToggleSpeaker);
    on<StartScreenShare>(_onStartScreenShare);
    on<StopScreenShare>(_onStopScreenShare);
    on<StartRecording>(_onStartRecording);
    on<StopRecording>(_onStopRecording);
    on<SetVideoQuality>(_onSetVideoQuality);
    on<SendChatMessage>(_onSendChatMessage);
    on<LoadChatMessages>(_onLoadChatMessages);
    on<ParticipantJoined>(_onParticipantJoined);
    on<ParticipantLeft>(_onParticipantLeft);
    on<UpdateParticipant>(_onUpdateParticipant);

    // Listen to live video service events
    _setupServiceListeners();
  }

  void _setupServiceListeners() {
    _participantJoinedSubscription =
        _liveVideoService.onParticipantJoined.listen(
      (participant) => add(ParticipantJoined(participant)),
    );

    _participantLeftSubscription = _liveVideoService.onParticipantLeft.listen(
      (participantId) => add(ParticipantLeft(participantId)),
    );

    _connectionStateSubscription =
        _liveVideoService.onConnectionStateChanged.listen(
      (connectionState) {
        log('Connection state changed: $connectionState');
        // Handle connection state changes if needed
      },
    );
  }

  Future<void> _onLoadLiveSessions(
    LoadLiveSessions event,
    Emitter<LiveSessionState> emit,
  ) async {
    emit(state.copyWith(status: LiveSessionStatus.loading));

    try {
      // Mock loading sessions - Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      final sessions = _generateMockSessions();

      emit(state.copyWith(
        status: LiveSessionStatus.loaded,
        sessions: sessions,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        error: 'Failed to load live sessions: $e',
      ));
    }
  }

  Future<void> _onLoadLiveSession(
    LoadLiveSession event,
    Emitter<LiveSessionState> emit,
  ) async {
    emit(state.copyWith(status: LiveSessionStatus.loading));

    try {
      // Mock loading single session - Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      final session = _generateMockSession(event.sessionId);

      emit(state.copyWith(
        status: LiveSessionStatus.loaded,
        currentSession: session,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        error: 'Failed to load live session: $e',
      ));
    }
  }

  Future<void> _onCreateLiveSession(
    CreateLiveSession event,
    Emitter<LiveSessionState> emit,
  ) async {
    emit(state.copyWith(status: LiveSessionStatus.loading));

    try {
      // Mock creating session - Replace with actual API call
      await Future.delayed(const Duration(seconds: 1));

      final sessions = [...state.sessions, event.session];

      emit(state.copyWith(
        status: LiveSessionStatus.loaded,
        sessions: sessions,
        currentSession: event.session,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        error: 'Failed to create live session: $e',
      ));
    }
  }

  Future<void> _onUpdateLiveSession(
    UpdateLiveSession event,
    Emitter<LiveSessionState> emit,
  ) async {
    try {
      // Mock updating session - Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedSessions = state.sessions.map((session) {
        if (session.id == event.sessionId) {
          return session.copyWith(
            status: event.updates['status'] != null
                ? models.LiveSessionStatus.values.firstWhere(
                    (s) => s.name == event.updates['status'],
                    orElse: () => session.status,
                  )
                : null,
            currentParticipants: event.updates['current_participants'] ??
                session.currentParticipants,
          );
        }
        return session;
      }).toList();

      emit(state.copyWith(sessions: updatedSessions));
    } catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        error: 'Failed to update live session: $e',
      ));
    }
  }

  Future<void> _onJoinLiveSession(
    JoinLiveSession event,
    Emitter<LiveSessionState> emit,
  ) async {
    emit(state.copyWith(status: LiveSessionStatus.joining));

    try {
      final session = state.currentSession;
      if (session == null) {
        throw Exception('No session to join');
      }

      // Initialize video service if not already initialized
      if (!_liveVideoService.isInitialized) {
        await _liveVideoService.initialize(appId: 'mock_app_id');
      }

      // Join based on role
      bool success;
      if (event.userRole == 'instructor') {
        success = await _liveVideoService.joinAsInstructor(
          session: session,
          token: 'mock_token',
        );
      } else {
        success = await _liveVideoService.joinAsStudent(
          session: session,
          token: 'mock_token',
        );
      }

      if (success) {
        emit(state.copyWith(
          status: LiveSessionStatus.joined,
          isJoined: true,
          currentUserRole: event.userRole,
          isMuted: _liveVideoService.isMuted,
          isVideoEnabled: _liveVideoService.isVideoEnabled,
          isSpeakerEnabled: _liveVideoService.isSpeakerEnabled,
        ));
      } else {
        throw Exception('Failed to join session');
      }
    } catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        error: 'Failed to join live session: $e',
      ));
    }
  }

  Future<void> _onLeaveLiveSession(
    LeaveLiveSession event,
    Emitter<LiveSessionState> emit,
  ) async {
    emit(state.copyWith(status: LiveSessionStatus.leaving));

    try {
      await _liveVideoService.leaveSession();

      emit(state.copyWith(
        status: LiveSessionStatus.loaded,
        isJoined: false,
        currentUserRole: null,
        participants: [],
        chatMessages: [],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        error: 'Failed to leave live session: $e',
      ));
    }
  }

  Future<void> _onStartLiveSession(
    StartLiveSession event,
    Emitter<LiveSessionState> emit,
  ) async {
    try {
      if (!state.canControlSession) {
        throw Exception('Not authorized to start session');
      }

      // Mock starting session - Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedSession = state.currentSession?.copyWith(
        status: models.LiveSessionStatus.live,
        startedAt: DateTime.now(),
      );

      emit(state.copyWith(currentSession: updatedSession));
    } catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        error: 'Failed to start live session: $e',
      ));
    }
  }

  Future<void> _onEndLiveSession(
    EndLiveSession event,
    Emitter<LiveSessionState> emit,
  ) async {
    try {
      if (!state.canControlSession) {
        throw Exception('Not authorized to end session');
      }

      // Stop recording if active
      if (state.isRecording) {
        await _liveVideoService.stopRecording();
      }

      // Mock ending session - Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      final updatedSession = state.currentSession?.copyWith(
        status: models.LiveSessionStatus.ended,
        endedAt: DateTime.now(),
      );

      emit(state.copyWith(
        currentSession: updatedSession,
        isRecording: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        error: 'Failed to end live session: $e',
      ));
    }
  }

  Future<void> _onToggleMicrophone(
    ToggleMicrophone event,
    Emitter<LiveSessionState> emit,
  ) async {
    try {
      await _liveVideoService.toggleMicrophone();
      emit(state.copyWith(isMuted: _liveVideoService.isMuted));
    } catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        error: 'Failed to toggle microphone: $e',
      ));
    }
  }

  Future<void> _onToggleCamera(
    ToggleCamera event,
    Emitter<LiveSessionState> emit,
  ) async {
    try {
      await _liveVideoService.toggleCamera();
      emit(state.copyWith(isVideoEnabled: _liveVideoService.isVideoEnabled));
    } catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        error: 'Failed to toggle camera: $e',
      ));
    }
  }

  Future<void> _onSwitchCamera(
    SwitchCamera event,
    Emitter<LiveSessionState> emit,
  ) async {
    try {
      await _liveVideoService.switchCamera();
    } catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        error: 'Failed to switch camera: $e',
      ));
    }
  }

  Future<void> _onToggleSpeaker(
    ToggleSpeaker event,
    Emitter<LiveSessionState> emit,
  ) async {
    try {
      await _liveVideoService.toggleSpeaker();
      emit(
          state.copyWith(isSpeakerEnabled: _liveVideoService.isSpeakerEnabled));
    } catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        error: 'Failed to toggle speaker: $e',
      ));
    }
  }

  Future<void> _onStartScreenShare(
    StartScreenShare event,
    Emitter<LiveSessionState> emit,
  ) async {
    try {
      if (!state.canShareScreen) {
        throw Exception('Not authorized to share screen');
      }

      final success = await _liveVideoService.startScreenShare();
      if (success) {
        emit(state.copyWith(isScreenSharing: true));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        error: 'Failed to start screen sharing: $e',
      ));
    }
  }

  Future<void> _onStopScreenShare(
    StopScreenShare event,
    Emitter<LiveSessionState> emit,
  ) async {
    try {
      await _liveVideoService.stopScreenShare();
      emit(state.copyWith(isScreenSharing: false));
    } catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        error: 'Failed to stop screen sharing: $e',
      ));
    }
  }

  Future<void> _onStartRecording(
    StartRecording event,
    Emitter<LiveSessionState> emit,
  ) async {
    try {
      if (!state.canStartRecording) {
        throw Exception('Not authorized to start recording');
      }

      final success = await _liveVideoService.startRecording();
      if (success) {
        emit(state.copyWith(isRecording: true));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        error: 'Failed to start recording: $e',
      ));
    }
  }

  Future<void> _onStopRecording(
    StopRecording event,
    Emitter<LiveSessionState> emit,
  ) async {
    try {
      await _liveVideoService.stopRecording();
      emit(state.copyWith(isRecording: false));
    } catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        error: 'Failed to stop recording: $e',
      ));
    }
  }

  Future<void> _onSetVideoQuality(
    SetVideoQuality event,
    Emitter<LiveSessionState> emit,
  ) async {
    try {
      await _liveVideoService.setVideoQuality(event.quality);
      emit(state.copyWith(videoQuality: event.quality));
    } catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        error: 'Failed to set video quality: $e',
      ));
    }
  }

  Future<void> _onSendChatMessage(
    SendChatMessage event,
    Emitter<LiveSessionState> emit,
  ) async {
    try {
      // Mock sending message - Replace with actual API call
      final message = models.LiveChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sessionId: event.sessionId,
        userId: 'current_user_id',
        userName: 'Current User',
        message: event.message,
        timestamp: DateTime.now(),
        isInstructor: state.isInstructor,
      );

      final updatedMessages = [...state.chatMessages, message];
      emit(state.copyWith(chatMessages: updatedMessages));
    } catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        error: 'Failed to send chat message: $e',
      ));
    }
  }

  Future<void> _onLoadChatMessages(
    LoadChatMessages event,
    Emitter<LiveSessionState> emit,
  ) async {
    try {
      // Mock loading messages - Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 300));

      final messages = _generateMockChatMessages(event.sessionId);
      emit(state.copyWith(chatMessages: messages));
    } catch (e) {
      emit(state.copyWith(
        status: LiveSessionStatus.error,
        error: 'Failed to load chat messages: $e',
      ));
    }
  }

  void _onParticipantJoined(
    ParticipantJoined event,
    Emitter<LiveSessionState> emit,
  ) {
    final updatedParticipants = [...state.participants, event.participant];
    emit(state.copyWith(participants: updatedParticipants));
  }

  void _onParticipantLeft(
    ParticipantLeft event,
    Emitter<LiveSessionState> emit,
  ) {
    final updatedParticipants =
        state.participants.where((p) => p.id != event.participantId).toList();
    emit(state.copyWith(participants: updatedParticipants));
  }

  void _onUpdateParticipant(
    UpdateParticipant event,
    Emitter<LiveSessionState> emit,
  ) {
    final updatedParticipants = state.participants.map((participant) {
      if (participant.id == event.participantId) {
        return participant.copyWith(
          isVideoEnabled:
              event.updates['is_video_enabled'] ?? participant.isVideoEnabled,
          isAudioEnabled:
              event.updates['is_audio_enabled'] ?? participant.isAudioEnabled,
          isScreenSharing:
              event.updates['is_screen_sharing'] ?? participant.isScreenSharing,
          isHandRaised:
              event.updates['is_hand_raised'] ?? participant.isHandRaised,
        );
      }
      return participant;
    }).toList();

    emit(state.copyWith(participants: updatedParticipants));
  }

  // Mock data generators
  List<models.LiveSession> _generateMockSessions() {
    return [
      models.LiveSession(
        id: '1',
        title: 'مقدمة في البرمجة',
        description: 'تعلم أساسيات البرمجة مع الأمثلة العملية',
        instructorId: 'instructor1',
        instructorName: 'د. أحمد محمد',
        courseId: 'course1',
        courseName: 'دورة البرمجة الأساسية',
        scheduledAt: DateTime.now().add(const Duration(hours: 1)),
        duration: 60,
        status: models.LiveSessionStatus.scheduled,
        tags: const ['برمجة', 'أساسيات'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      models.LiveSession(
        id: '2',
        title: 'تطوير تطبيقات الموبايل',
        description: 'تعلم تطوير التطبيقات باستخدام Flutter',
        instructorId: 'instructor2',
        instructorName: 'م. فاطمة أحمد',
        courseId: 'course2',
        courseName: 'دورة تطوير التطبيقات',
        scheduledAt: DateTime.now().add(const Duration(minutes: 30)),
        duration: 90,
        status: models.LiveSessionStatus.live,
        currentParticipants: 25,
        tags: const ['Flutter', 'موبايل'],
        isRecorded: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  models.LiveSession _generateMockSession(String sessionId) {
    return models.LiveSession(
      id: sessionId,
      title: 'جلسة مباشرة تجريبية',
      description: 'هذه جلسة تجريبية لاختبار النظام',
      instructorId: 'instructor1',
      instructorName: 'د. محمد علي',
      courseId: 'course1',
      courseName: 'الدورة التجريبية',
      scheduledAt: DateTime.now(),
      duration: 60,
      status: models.LiveSessionStatus.live,
      currentParticipants: 15,
      tags: const ['تجريبي'],
      allowChat: true,
      isRecorded: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  List<models.LiveChatMessage> _generateMockChatMessages(String sessionId) {
    return [
      models.LiveChatMessage(
        id: '1',
        sessionId: sessionId,
        userId: 'user1',
        userName: 'أحمد محمد',
        message: 'مرحباً بالجميع',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      models.LiveChatMessage(
        id: '2',
        sessionId: sessionId,
        userId: 'instructor1',
        userName: 'د. محمد علي',
        message: 'أهلاً وسهلاً، نبدأ الدرس الآن',
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
        isInstructor: true,
      ),
    ];
  }

  @override
  Future<void> close() {
    _participantJoinedSubscription?.cancel();
    _participantLeftSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    return super.close();
  }
}
