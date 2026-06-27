import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'exercise_session.g.dart';

@HiveType(typeId: 3)
class ExerciseSession extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final List<String> exerciseIds;

  const ExerciseSession({
    required this.id,
    required this.name,
    required this.exerciseIds,
  });

  @override
  List<Object?> get props => [id, name, exerciseIds];
}
