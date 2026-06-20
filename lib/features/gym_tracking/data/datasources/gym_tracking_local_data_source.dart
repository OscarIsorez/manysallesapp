import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/gym.dart';
import '../../domain/entities/exercise.dart';
import '../../domain/entities/exercise_session.dart';
import '../../domain/entities/weight_log.dart';
import '../../../../core/error/exceptions.dart';

abstract class GymTrackingLocalDataSource {
  Future<List<Gym>> getGyms();
  Future<void> addGym(Gym gym);

  Future<List<Exercise>> getExercises();
  Future<void> addExercise(Exercise exercise);

  Future<List<ExerciseSession>> getSessions();
  Future<void> addSession(ExerciseSession session);
  Future<void> updateSession(ExerciseSession session);
  Future<void> deleteSession(String sessionId);

  Future<List<WeightLog>> getLogsForGymAndExercise(
    String gymId,
    String exerciseId,
  );
  Future<WeightLog?> getLatestLogForGymAndExercise(
    String gymId,
    String exerciseId,
  );
  Future<void> addWeightLog(WeightLog log);
  Future<void> deleteWeightLog(String logId);

  Future<String> exportData();
  Future<void> importData(Map<String, dynamic> data);
}

class GymTrackingLocalDataSourceImpl implements GymTrackingLocalDataSource {
  final Box<Gym> gymBox;
  final Box<Exercise> exerciseBox;
  final Box<ExerciseSession> sessionBox;
  final Box<WeightLog> logBox;

  GymTrackingLocalDataSourceImpl({
    required this.gymBox,
    required this.exerciseBox,
    required this.sessionBox,
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
  Future<List<ExerciseSession>> getSessions() async {
    return sessionBox.values.toList();
  }

  @override
  Future<void> addSession(ExerciseSession session) async {
    await sessionBox.put(session.id, session);
  }

  @override
  Future<void> updateSession(ExerciseSession session) async {
    await sessionBox.put(session.id, session);
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await sessionBox.delete(sessionId);
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
  Future<void> deleteWeightLog(String logId) async {
    await logBox.delete(logId);
  }

  @override
  Future<String> exportData() async {
    try {
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw const CacheException('Failed to get downloads directory');
      }
      final file = File('${directory.path}/gym_tracker_export.json');

      final data = {
        'gyms': gymBox.values.map((g) => {'id': g.id, 'name': g.name}).toList(),
        'exercises': exerciseBox.values
            .map((e) => {'id': e.id, 'name': e.name})
            .toList(),
        'sessions': sessionBox.values
            .map(
              (s) => {
                'id': s.id,
                'name': s.name,
                'exerciseIds': s.exerciseIds,
              },
            )
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

  Gym _parseGym(Map<String, dynamic> gym) {
    return Gym(id: gym['id'] as String, name: gym['name'] as String);
  }

  Exercise _parseExercise(Map<String, dynamic> exercise) {
    return Exercise(
      id: exercise['id'] as String,
      name: exercise['name'] as String,
    );
  }

  ExerciseSession _parseSession(Map<String, dynamic> session) {
    return ExerciseSession(
      id: session['id'] as String,
      name: session['name'] as String,
      exerciseIds: (session['exerciseIds'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
    );
  }

  List<int> _parseReps(dynamic repsValue) {
    if (repsValue is List) {
      return repsValue.whereType<num>().map((rep) => rep.toInt()).toList();
    }

    if (repsValue is int) {
      return [repsValue];
    }

    return const [];
  }

  WeightLog _parseLog(Map<String, dynamic> log) {
    return WeightLog(
      id: log['id'] as String,
      gymId: log['gymId'] as String,
      exerciseId: log['exerciseId'] as String,
      weight: (log['weight'] as num).toDouble(),
      sets: log['sets'] as int,
      reps: _parseReps(log['reps']),
      date: DateTime.parse(log['date'] as String),
    );
  }

  @override
  Future<void> importData(Map<String, dynamic> data) async {
    final gyms = (data['gyms'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((gym) => _parseGym(Map<String, dynamic>.from(gym)))
        .toList();

    final exercises = (data['exercises'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((exercise) => _parseExercise(Map<String, dynamic>.from(exercise)))
        .toList();

    final sessions = (data['sessions'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((session) => _parseSession(Map<String, dynamic>.from(session)))
        .toList();

    final logs = (data['logs'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((log) => _parseLog(Map<String, dynamic>.from(log)))
        .toList();

    await gymBox.clear();
    await exerciseBox.clear();
    await sessionBox.clear();
    await logBox.clear();

    for (final gym in gyms) {
      await gymBox.put(gym.id, gym);
    }

    for (final exercise in exercises) {
      await exerciseBox.put(exercise.id, exercise);
    }

    for (final session in sessions) {
      await sessionBox.put(session.id, session);
    }

    for (final log in logs) {
      await logBox.put(log.id, log);
    }
  }
}
