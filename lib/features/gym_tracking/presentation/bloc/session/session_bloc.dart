import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manysallesapp/core/usecases/usecase.dart';
import 'package:manysallesapp/features/gym_tracking/domain/entities/exercise_session.dart';
import 'package:manysallesapp/features/gym_tracking/domain/usecases/session_usecases.dart';
import 'package:uuid/uuid.dart';

import 'session_event.dart';
import 'session_state.dart';

class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final GetSessions getSessions;
  final AddSession addSession;
  final UpdateSession updateSession;
  final DeleteSession deleteSession;

  SessionBloc({
    required this.getSessions,
    required this.addSession,
    required this.updateSession,
    required this.deleteSession,
  }) : super(SessionInitial()) {
    on<GetSessionsEvent>(_onGetSessions);
    on<AddSessionEvent>(_onAddSession);
    on<UpdateSessionEvent>(_onUpdateSession);
    on<DeleteSessionEvent>(_onDeleteSession);
    on<SelectSessionEvent>(_onSelectSession);
  }

  Future<void> _onGetSessions(
    GetSessionsEvent event,
    Emitter<SessionState> emit,
  ) async {
    final previousSelection = state is SessionLoaded
        ? (state as SessionLoaded).selectedSessionId
        : null;
    emit(SessionLoading());
    final failureOrSessions = await getSessions(NoParams());
    failureOrSessions.fold(
      (failure) => emit(SessionError(message: failure.message)),
      (sessions) {
        final stillValid =
            previousSelection != null &&
            sessions.any((session) => session.id == previousSelection);
        emit(
          SessionLoaded(
            sessions: sessions,
            selectedSessionId: stillValid ? previousSelection : null,
          ),
        );
      },
    );
  }

  Future<void> _onAddSession(
    AddSessionEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());

    final newSession = ExerciseSession(
      id: const Uuid().v4(),
      name: event.sessionName,
      exerciseIds: event.exerciseIds,
    );

    final result = await addSession(SessionParams(session: newSession));

    if (result.isLeft()) {
      emit(
        SessionError(
          message: result.fold((failure) => failure.message, (_) => ''),
        ),
      );
      return;
    }

    final sessionsResult = await getSessions(NoParams());

    sessionsResult.fold(
      (failure) => emit(SessionError(message: failure.message)),
      (sessions) => emit(
        SessionLoaded(sessions: sessions, selectedSessionId: newSession.id),
      ),
    );
  }

  Future<void> _onUpdateSession(
    UpdateSessionEvent event,
    Emitter<SessionState> emit,
  ) async {
    emit(SessionLoading());
    final failureOrSuccess = await updateSession(
      SessionParams(session: event.session),
    );
    failureOrSuccess.fold(
      (failure) => emit(SessionError(message: failure.message)),
      (_) {
        emit(SessionUpdatedSuccess());
        add(GetSessionsEvent());
      },
    );
  }

  Future<void> _onDeleteSession(
    DeleteSessionEvent event,
    Emitter<SessionState> emit,
  ) async {
    final currentState = state;
    emit(SessionLoading());
    final failureOrSuccess = await deleteSession(
      DeleteSessionParams(sessionId: event.sessionId),
    );
    failureOrSuccess.fold(
      (failure) => emit(SessionError(message: failure.message)),
      (_) {
        emit(SessionDeletedSuccess());
        if (currentState is SessionLoaded &&
            currentState.selectedSessionId == event.sessionId) {
          add(const SelectSessionEvent(sessionId: null));
        }
        add(GetSessionsEvent());
      },
    );
  }

  void _onSelectSession(SelectSessionEvent event, Emitter<SessionState> emit) {
    final currentState = state;
    if (currentState is SessionLoaded) {
      emit(
        currentState.copyWith(
          selectedSessionId: event.sessionId,
          clearSelection: event.sessionId == null,
        ),
      );
    }
  }
}
