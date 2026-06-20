import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/gym.dart';
import '../entities/exercise.dart';
import '../entities/weight_log.dart';

abstract class GymTrackingRepository {
  Future<Either<Failure, List<Gym>>> getGyms();
  Future<Either<Failure, void>> addGym(Gym gym);

  Future<Either<Failure, List<Exercise>>> getExercises();
  Future<Either<Failure, void>> addExercise(Exercise exercise);

  Future<Either<Failure, List<WeightLog>>> getLogsForGymAndExercise(
    String gymId,
    String exerciseId,
  );
  Future<Either<Failure, WeightLog?>> getLatestLogForGymAndExercise(
    String gymId,
    String exerciseId,
  );
  Future<Either<Failure, void>> addWeightLog(WeightLog log);

  Future<Either<Failure, void>> updateWeightForEveryGym(WeightLog baseLog);
  Future<Either<Failure, void>> exportData();
  Future<Either<Failure, void>> importData(String filePath);
}
