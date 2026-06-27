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
  final WeightLog latestLog;

  const LogsLoaded({required this.logs, required this.latestLog});

  @override
  List<Object> get props => [logs, latestLog];
}

class LogAddedSuccess extends LogState {}

class LogDeletedSuccess extends LogState {}

class LogUpdatedSuccess extends LogState {}

class DataExportedSuccess extends LogState {
  final String message;

  const DataExportedSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class DataImportedSuccess extends LogState {
  final String message;

  const DataImportedSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class LogError extends LogState {
  final String message;

  const LogError({required this.message});

  @override
  List<Object> get props => [message];
}
