import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'exercise.g.dart';

@HiveType(typeId: 1)
class Exercise extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;

  const Exercise({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
