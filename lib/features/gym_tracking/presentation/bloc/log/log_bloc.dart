import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manysallesapp/core/usecases/usecase.dart';
import 'package:manysallesapp/features/gym_tracking/domain/entities/weight_log.dart';
import 'package:manysallesapp/features/gym_tracking/domain/usecases/log_usecases.dart';
import 'package:uuid/uuid.dart';

import 'log_event.dart';
import 'log_state.dart';

class LogBloc extends Bloc<LogEvent, LogState> {
  final GetLogsForGymAndExercise getLogs;
  final AddWeightLog addWeightLog;
  final ExportData exportData;

  LogBloc({
    required this.getLogs,
    required this.addWeightLog,
    required this.exportData,
  }) : super(LogInitial()) {
    on<GetLogsEvent>(_onGetLogs);
    on<AddWeightLogEvent>(_onAddWeightLog);
    on<ExportDataEvent>(_onExportData);
  }

  Future<void> _onGetLogs(GetLogsEvent event, Emitter<LogState> emit) async {
    emit(LogLoading());
    final failureOrLogs = await getLogs(
      GetLogsParams(gymId: event.gymId, exerciseId: event.exerciseId),
    );
    failureOrLogs.fold(
      (failure) => emit(LogError(message: failure.message)),
      (logs) => emit(LogsLoaded(logs: logs)),
    );
  }

  Future<void> _onAddWeightLog(
    AddWeightLogEvent event,
    Emitter<LogState> emit,
  ) async {
    emit(LogLoading());

    final newLog = WeightLog(
      id: const Uuid().v4(),
      gymId: event.gymId,
      exerciseId: event.exerciseId,
      weight: event.weight,
      sets: event.sets,
      reps: event.reps,
      date: DateTime.now(),
    );

    final failureOrSuccess = await addWeightLog(
      AddLogParams(weightLog: newLog, updateEveryGym: event.updateEveryGym),
    );

    failureOrSuccess.fold(
      (failure) => emit(LogError(message: failure.message)),
      (_) {
        emit(LogAddedSuccess());
        add(GetLogsEvent(gymId: event.gymId, exerciseId: event.exerciseId));
      },
    );
  }

  Future<void> _onExportData(
    ExportDataEvent event,
    Emitter<LogState> emit,
  ) async {
    emit(LogLoading());
    final failureOrSuccess = await exportData(NoParams());
    failureOrSuccess.fold(
      (failure) => emit(LogError(message: failure.message)),
      (_) => emit(
        const DataExportedSuccess(message: 'Data successfully exported!'),
      ),
    );
  }
}
