import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/exercise.dart';
import '../repositories/gym_tracking_repository.dart';

class GetExercises implements UseCase<List<Exercise>, NoParams> {
  final GymTrackingRepository repository;

  GetExercises(this.repository);

  @override
  Future<Either<Failure, List<Exercise>>> call(NoParams params) async {
    return await repository.getExercises();
  }
}

class AddExercise implements UseCase<void, ExerciseParams> {
  final GymTrackingRepository repository;

  AddExercise(this.repository);

  @override
  Future<Either<Failure, void>> call(ExerciseParams params) async {
    return await repository.addExercise(params.exercise);
  }
}

class ExerciseParams extends Equatable {
  final Exercise exercise;

  const ExerciseParams({required this.exercise});

  @override
  List<Object> get props => [exercise];
}
