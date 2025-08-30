// live_session_event.dart
import 'package:equatable/equatable.dart';
import '../../models/live_session.dart';

abstract class LiveSessionEvent extends Equatable {
  const LiveSessionEvent();

  @override
  List<Object?> get props => [];
}

class LoadLiveSessions extends LiveSessionEvent {}

class LoadLiveSession extends LiveSessionEvent {
  final String sessionId;

  const LoadLiveSession(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}

class CreateLiveSession extends LiveSessionEvent {
  final LiveSession session;

  const CreateLiveSession(this.session);

  @override
  List<Object> get props => [session];
}

class UpdateLiveSession extends LiveSessionEvent {
  final String sessionId;
  final Map<String, dynamic> updates;

  const UpdateLiveSession(this.sessionId, this.updates);

  @override
  List<Object> get props => [sessionId, updates];
}

class JoinLiveSession extends LiveSessionEvent {
  final String sessionId;
  final String userRole; // instructor, student

  const JoinLiveSession(this.sessionId, this.userRole);

  @override
  List<Object> get props => [sessionId, userRole];
}

class LeaveLiveSession extends LiveSessionEvent {
  final String sessionId;

  const LeaveLiveSession(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}

class StartLiveSession extends LiveSessionEvent {
  final String sessionId;

  const StartLiveSession(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}

class EndLiveSession extends LiveSessionEvent {
  final String sessionId;

  const EndLiveSession(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}

class ToggleMicrophone extends LiveSessionEvent {}

class ToggleCamera extends LiveSessionEvent {}

class SwitchCamera extends LiveSessionEvent {}

class ToggleSpeaker extends LiveSessionEvent {}

class StartScreenShare extends LiveSessionEvent {}

class StopScreenShare extends LiveSessionEvent {}

class StartRecording extends LiveSessionEvent {}

class StopRecording extends LiveSessionEvent {}

class SetVideoQuality extends LiveSessionEvent {
  final StreamQuality quality;

  const SetVideoQuality(this.quality);

  @override
  List<Object> get props => [quality];
}

class SendChatMessage extends LiveSessionEvent {
  final String sessionId;
  final String message;

  const SendChatMessage(this.sessionId, this.message);

  @override
  List<Object> get props => [sessionId, message];
}

class LoadChatMessages extends LiveSessionEvent {
  final String sessionId;

  const LoadChatMessages(this.sessionId);

  @override
  List<Object> get props => [sessionId];
}

class ParticipantJoined extends LiveSessionEvent {
  final LiveSessionParticipant participant;

  const ParticipantJoined(this.participant);

  @override
  List<Object> get props => [participant];
}

class ParticipantLeft extends LiveSessionEvent {
  final String participantId;

  const ParticipantLeft(this.participantId);

  @override
  List<Object> get props => [participantId];
}

class UpdateParticipant extends LiveSessionEvent {
  final String participantId;
  final Map<String, dynamic> updates;

  const UpdateParticipant(this.participantId, this.updates);

  @override
  List<Object> get props => [participantId, updates];
}
