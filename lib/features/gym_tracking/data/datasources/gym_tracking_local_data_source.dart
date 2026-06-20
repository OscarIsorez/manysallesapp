import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/gym.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/weight_log.dart';
import '../../../../core/error/exceptions.dart';

abstract class GymTrackingLocalDataSource {
  Future<List<Gym>> getGyms();
  Future<void> addGym(Gym gym);

  Future<List<Exercise>> getExercises();
  Future<void> addExercise(Exercise exercise);

  Future<List<WeightLog>> getLogsForGymAndExercise(
    String gymId,
    String exerciseId,
  );
  Future<WeightLog?> getLatestLogForGymAndExercise(
    String gymId,
    String exerciseId,
  );
  Future<void> addWeightLog(WeightLog log);

  Future<String> exportData();
}

class GymTrackingLocalDataSourceImpl implements GymTrackingLocalDataSource {
  final Box<Gym> gymBox;
  final Box<Exercise> exerciseBox;
  final Box<WeightLog> logBox;

  GymTrackingLocalDataSourceImpl({
    required this.gymBox,
    required this.exerciseBox,
    required this.logBox,
  });

  @override
  Future<List<Gym>> getGyms() async {
    return gymBox.values.toList();
  }

  @override
  Future<void> addGym(Gym gym) async {
    await gymBox.put(gym.id, gym);
  }

  @override
  Future<List<Exercise>> getExercises() async {
    return exerciseBox.values.toList();
  }

  @override
  Future<void> addExercise(Exercise exercise) async {
    await exerciseBox.put(exercise.id, exercise);
  }

  @override
  Future<List<WeightLog>> getLogsForGymAndExercise(
    String gymId,
    String exerciseId,
  ) async {
    final logs = logBox.values
        .where((log) => log.gymId == gymId && log.exerciseId == exerciseId)
        .toList();
    logs.sort((a, b) => b.date.compareTo(a.date)); // descending
    return logs;
  }

  @override
  Future<WeightLog?> getLatestLogForGymAndExercise(
    String gymId,
    String exerciseId,
  ) async {
    final logs = await getLogsForGymAndExercise(gymId, exerciseId);
    if (logs.isNotEmpty) {
      return logs.first;
    }
    return null;
  }

  @override
  Future<void> addWeightLog(WeightLog log) async {
    await logBox.put(log.id, log);
  }

  @override
  Future<String> exportData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/gym_tracker_export.json');

      final data = {
        'gyms': gymBox.values.map((g) => {'id': g.id, 'name': g.name}).toList(),
        'exercises': exerciseBox.values
            .map((e) => {'id': e.id, 'name': e.name})
            .toList(),
        'logs': logBox.values
            .map(
              (l) => {
                'id': l.id,
                'gymId': l.gymId,
                'exerciseId': l.exerciseId,
                'weight': l.weight,
                'sets': l.sets,
                'reps': l.reps,
                'date': l.date.toIso8601String(),
              },
            )
            .toList(),
      };

      final jsonString = jsonEncode(data);
      await file.writeAsString(jsonString);
      return file.path;
    } catch (e) {
      throw const CacheException('Failed to export data');
    }
  }
}
