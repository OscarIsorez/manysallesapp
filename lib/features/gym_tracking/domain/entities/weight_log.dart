import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'weight_log.g.dart';

@HiveType(typeId: 2)
class WeightLog extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String gymId;
  @HiveField(2)
  final String exerciseId;
  @HiveField(3)
  final double weight;
  @HiveField(4)
  final int sets;
  @HiveField(5)
  final List<int> reps;
  @HiveField(6)
  final DateTime date;

  const WeightLog({
    required this.id,
    required this.gymId,
    required this.exerciseId,
    required this.weight,
    required this.sets,
    required this.reps,
    required this.date,
  });

  @override
  List<Object?> get props => [id, gymId, exerciseId, weight, sets, reps, date];

  WeightLog copyWith({
    String? id,
    String? gymId,
    String? exerciseId,
    double? weight,
    int? sets,
    List<int>? reps,
    DateTime? date,
  }) {
    return WeightLog(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      exerciseId: exerciseId ?? this.exerciseId,
      weight: weight ?? this.weight,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      date: date ?? this.date,
    );
  }

  factory WeightLog.empty() {
    return WeightLog(
      id: '',
      gymId: '',
      exerciseId: '',
      weight: 0,
      sets: 0,
      reps: const [],
      date: DateTime.now(),
    );
  }
}
