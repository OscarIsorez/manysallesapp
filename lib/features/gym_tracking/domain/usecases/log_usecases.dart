import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/weight_log.dart';
import '../repositories/gym_tracking_repository.dart';

class GetLogsForGymAndExercise
    implements UseCase<List<WeightLog>, GetLogsParams> {
  final GymTrackingRepository repository;

  GetLogsForGymAndExercise(this.repository);

  @override
  Future<Either<Failure, List<WeightLog>>> call(GetLogsParams params) async {
    return await repository.getLogsForGymAndExercise(
      params.gymId,
      params.exerciseId,
    );
  }
}

class AddWeightLog implements UseCase<void, AddLogParams> {
  final GymTrackingRepository repository;

  AddWeightLog(this.repository);

  @override
  Future<Either<Failure, void>> call(AddLogParams params) async {
    if (params.updateEveryGym) {
      return await repository.updateWeightForEveryGym(params.weightLog);
    } else {
      return await repository.addWeightLog(params.weightLog);
    }
  }
}

class DeleteWeightLog implements UseCase<void, DeleteLogParams> {
  final GymTrackingRepository repository;

  DeleteWeightLog(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteLogParams params) async {
    return await repository.deleteWeightLog(params.logId);
  }
}

class ExportData implements UseCase<void, NoParams> {
  final GymTrackingRepository repository;

  ExportData(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.exportData();
  }
}

class ImportData implements UseCase<void, ImportDataParams> {
  final GymTrackingRepository repository;

  ImportData(this.repository);

  @override
  Future<Either<Failure, void>> call(ImportDataParams params) async {
    return await repository.importData(params.filePath);
  }
}

class GetLogsParams extends Equatable {
  final String gymId;
  final String exerciseId;

  const GetLogsParams({required this.gymId, required this.exerciseId});

  @override
  List<Object> get props => [gymId, exerciseId];
}

class AddLogParams extends Equatable {
  final WeightLog weightLog;
  final bool updateEveryGym;

  const AddLogParams({required this.weightLog, required this.updateEveryGym});

  @override
  List<Object> get props => [weightLog, updateEveryGym];
}

class ImportDataParams extends Equatable {
  final String filePath;

  const ImportDataParams({required this.filePath});

  @override
  List<Object> get props => [filePath];
}

class DeleteLogParams extends Equatable {
  final String logId;

  const DeleteLogParams({required this.logId});

  @override
  List<Object> get props => [logId];
}
