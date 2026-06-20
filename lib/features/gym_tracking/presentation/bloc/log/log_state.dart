import 'package:equatable/equatable.dart';
import 'package:manysallesapp/features/gym_tracking/domain/entities/weight_log.dart';

abstract class LogState extends Equatable {
  const LogState();

  @override
  List<Object> get props => [];
}

class LogInitial extends LogState {}

class LogLoading extends LogState {}

class LogsLoaded extends LogState {
  final List<WeightLog> logs;

  const LogsLoaded({required this.logs});

  @override
  List<Object> get props => [logs];
}

class LogAddedSuccess extends LogState {}

class DataExportedSuccess extends LogState {
  final String message;

  const DataExportedSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class LogError extends LogState {
  final String message;

  const LogError({required this.message});

  @override
  List<Object> get props => [message];
}
