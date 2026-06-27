import 'package:equatable/equatable.dart';
import 'package:manysallesapp/features/gym_tracking/domain/entities/weight_log.dart';

abstract class LogEvent extends Equatable {
  const LogEvent();

  @override
  List<Object?> get props => [];
}

class GetLogsEvent extends LogEvent {
  final String gymId;
  final String exerciseId;

  const GetLogsEvent({required this.gymId, required this.exerciseId});

  @override
  List<Object> get props => [gymId, exerciseId];
}

class AddWeightLogEvent extends LogEvent {
  final String gymId;
  final String exerciseId;
  final double weight;
  final int sets;
  final List<int> reps;
  final bool updateEveryGym;

  const AddWeightLogEvent({
    required this.gymId,
    required this.exerciseId,
    required this.weight,
    required this.sets,
    required this.reps,
    required this.updateEveryGym,
  });

  @override
  List<Object> get props => [
    gymId,
    exerciseId,
    weight,
    sets,
    reps,
    updateEveryGym,
  ];
}

class DeleteWeightLogEvent extends LogEvent {
  final String logId;
  final String gymId;
  final String exerciseId;

  const DeleteWeightLogEvent({
    required this.logId,
    required this.gymId,
    required this.exerciseId,
  });

  @override
  List<Object> get props => [logId, gymId, exerciseId];
}

class UpdateWeightLogEvent extends LogEvent {
  final WeightLog weightLog;
  final String gymId;
  final String exerciseId;

  const UpdateWeightLogEvent({
    required this.weightLog,
    required this.gymId,
    required this.exerciseId,
  });

  @override
  List<Object> get props => [weightLog, gymId, exerciseId];
}

class ExportDataEvent extends LogEvent {}

class ImportDataEvent extends LogEvent {
  final String filePath;

  const ImportDataEvent({required this.filePath});

  @override
  List<Object> get props => [filePath];
}
