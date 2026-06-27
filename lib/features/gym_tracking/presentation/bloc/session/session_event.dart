import 'package:equatable/equatable.dart';
import 'package:manysallesapp/features/gym_tracking/domain/entities/exercise_session.dart';

abstract class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

class GetSessionsEvent extends SessionEvent {}

class AddSessionEvent extends SessionEvent {
  final String sessionName;
  final List<String> exerciseIds;

  const AddSessionEvent({
    required this.sessionName,
    required this.exerciseIds,
  });

  @override
  List<Object> get props => [sessionName, exerciseIds];
}

class UpdateSessionEvent extends SessionEvent {
  final ExerciseSession session;

  const UpdateSessionEvent({required this.session});

  @override
  List<Object> get props => [session];
}

class DeleteSessionEvent extends SessionEvent {
  final String sessionId;

  const DeleteSessionEvent({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}

class SelectSessionEvent extends SessionEvent {
  final String? sessionId;

  const SelectSessionEvent({this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}
