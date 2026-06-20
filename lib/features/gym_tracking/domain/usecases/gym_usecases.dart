import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/gym.dart';
import '../repositories/gym_tracking_repository.dart';

class GetGyms implements UseCase<List<Gym>, NoParams> {
  final GymTrackingRepository repository;

  GetGyms(this.repository);

  @override
  Future<Either<Failure, List<Gym>>> call(NoParams params) async {
    return await repository.getGyms();
  }
}

class AddGym implements UseCase<void, GymParams> {
  final GymTrackingRepository repository;

  AddGym(this.repository);

  @override
  Future<Either<Failure, void>> call(GymParams params) async {
    return await repository.addGym(params.gym);
  }
}

class GymParams extends Equatable {
  final Gym gym;

  const GymParams({required this.gym});

  @override
  List<Object> get props => [gym];
}
