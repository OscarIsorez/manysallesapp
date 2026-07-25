import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/gym_tracking_repository.dart';
import '../entities/daily_aggregate.dart';

class GetDailyAggregatedLogs
    implements UseCase<List<DailyAggregate>, GetDailyParams> {
  final GymTrackingRepository repository;
  GetDailyAggregatedLogs(this.repository);

  @override
  Future<Either<Failure, List<DailyAggregate>>> call(
    GetDailyParams params,
  ) async {
    return await repository.getDailyAggregatedLogs(
      params.gymId,
      params.exerciseId,
    );
  }
}

class GetDailyParams {
  final String gymId;
  final String exerciseId;
  const GetDailyParams({required this.gymId, required this.exerciseId});
}
