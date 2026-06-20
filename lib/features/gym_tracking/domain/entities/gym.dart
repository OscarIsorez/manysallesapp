import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'gym.g.dart';

@HiveType(typeId: 0)
class Gym extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;

  const Gym({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
