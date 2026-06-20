import 'package:equatable/equatable.dart';

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
  final int reps;
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

class ExportDataEvent extends LogEvent {}
