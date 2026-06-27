import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/exercise_session.dart';
import '../repositories/gym_tracking_repository.dart';

class GetSessions implements UseCase<List<ExerciseSession>, NoParams> {
  final GymTrackingRepository repository;

  GetSessions(this.repository);

  @override
  Future<Either<Failure, List<ExerciseSession>>> call(NoParams params) async {
    return await repository.getSessions();
  }
}

class AddSession implements UseCase<void, SessionParams> {
  final GymTrackingRepository repository;

  AddSession(this.repository);

  @override
  Future<Either<Failure, void>> call(SessionParams params) async {
    return await repository.addSession(params.session);
  }
}

class UpdateSession implements UseCase<void, SessionParams> {
  final GymTrackingRepository repository;

  UpdateSession(this.repository);

  @override
  Future<Either<Failure, void>> call(SessionParams params) async {
    return await repository.updateSession(params.session);
  }
}

class DeleteSession implements UseCase<void, DeleteSessionParams> {
  final GymTrackingRepository repository;

  DeleteSession(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteSessionParams params) async {
    return await repository.deleteSession(params.sessionId);
  }
}

class SessionParams extends Equatable {
  final ExerciseSession session;

  const SessionParams({required this.session});

  @override
  List<Object> get props => [session];
}

class DeleteSessionParams extends Equatable {
  final String sessionId;

  const DeleteSessionParams({required this.sessionId});

  @override
  List<Object> get props => [sessionId];
}
