import 'package:equatable/equatable.dart';
import 'package:manysallesapp/features/gym_tracking/domain/entities/exercise_session.dart';

abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {}

class SessionLoading extends SessionState {}

class SessionLoaded extends SessionState {
  final List<ExerciseSession> sessions;
  final String? selectedSessionId;

  const SessionLoaded({
    required this.sessions,
    this.selectedSessionId,
  });

  SessionLoaded copyWith({
    List<ExerciseSession>? sessions,
    String? selectedSessionId,
    bool clearSelection = false,
  }) {
    return SessionLoaded(
      sessions: sessions ?? this.sessions,
      selectedSessionId: clearSelection
          ? null
          : (selectedSessionId ?? this.selectedSessionId),
    );
  }

  ExerciseSession? get selectedSession {
    if (selectedSessionId == null) return null;
    for (final session in sessions) {
      if (session.id == selectedSessionId) return session;
    }
    return null;
  }

  @override
  List<Object?> get props => [sessions, selectedSessionId];
}

class SessionError extends SessionState {
  final String message;

  const SessionError({required this.message});

  @override
  List<Object> get props => [message];
}

class SessionAddedSuccess extends SessionState {}

class SessionUpdatedSuccess extends SessionState {}

class SessionDeletedSuccess extends SessionState {}
