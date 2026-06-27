import 'package:fpdart/fpdart.dart';
import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/gym.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_session.dart';
import '../../domain/entities/weight_log.dart';
import '../../domain/repositories/gym_tracking_repository.dart';
import '../datasources/gym_tracking_local_data_source.dart';

class GymTrackingRepositoryImpl implements GymTrackingRepository {
  final GymTrackingLocalDataSource localDataSource;

  GymTrackingRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Gym>>> getGyms() async {
    try {
      final gyms = await localDataSource.getGyms();
      return Right(gyms);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addGym(Gym gym) async {
    try {
      await localDataSource.addGym(gym);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Exercise>>> getExercises() async {
    try {
      final exercises = await localDataSource.getExercises();
      return Right(exercises);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addExercise(Exercise exercise) async {
    try {
      await localDataSource.addExercise(exercise);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExercise(String exerciseId) async {
    try {
      await localDataSource.deleteExercise(exerciseId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ExerciseSession>>> getSessions() async {
    try {
      final sessions = await localDataSource.getSessions();
      return Right(sessions);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addSession(ExerciseSession session) async {
    try {
      await localDataSource.addSession(session);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSession(ExerciseSession session) async {
    try {
      await localDataSource.updateSession(session);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    try {
      await localDataSource.deleteSession(sessionId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WeightLog>>> getLogsForGymAndExercise(
    String gymId,
    String exerciseId,
  ) async {
    try {
      final logs = await localDataSource.getLogsForGymAndExercise(
        gymId,
        exerciseId,
      );
      return Right(logs);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, WeightLog?>> getLatestLogForGymAndExercise(
    String gymId,
    String exerciseId,
  ) async {
    try {
      final log = await localDataSource.getLatestLogForGymAndExercise(
        gymId,
        exerciseId,
      );
      return Right(log);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addWeightLog(WeightLog log) async {
    try {
      await localDataSource.addWeightLog(log);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateWeightLog(WeightLog log) async {
    try {
      await localDataSource.updateWeightLog(log);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteWeightLog(String logId) async {
    try {
      await localDataSource.deleteWeightLog(logId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateWeightForEveryGym(
    WeightLog baseLog,
  ) async {
    try {
      // Get all gyms
      final gyms = await localDataSource.getGyms();
      final uuid = const Uuid();

      for (var gym in gyms) {
        final newLog = WeightLog(
          id: uuid.v4(),
          gymId: gym.id,
          exerciseId: baseLog.exerciseId,
          weight: baseLog.weight,
          sets: baseLog.sets,
          reps: baseLog.reps,
          date: baseLog.date,
        );
        await localDataSource.addWeightLog(newLog);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> exportData() async {
    try {
      await localDataSource.exportData();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> importData(String filePath) async {
    try {
      final jsonString = await File(filePath).readAsString();
      final decoded = jsonDecode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        return Left(const CacheFailure('Invalid import file format'));
      }

      await localDataSource.importData(decoded);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
