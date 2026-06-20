import 'package:equatable/equatable.dart';

abstract class ExerciseEvent extends Equatable {
  const ExerciseEvent();

  @override
  List<Object> get props => [];
}

class GetExercisesEvent extends ExerciseEvent {}

class AddExerciseEvent extends ExerciseEvent {
  final String exerciseName;

  const AddExerciseEvent({required this.exerciseName});

  @override
  List<Object> get props => [exerciseName];
}
