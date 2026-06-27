import 'package:equatable/equatable.dart';
import 'package:manysallesapp/features/gym_tracking/domain/entities/exercise.dart';

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

class DeleteExerciseEvent extends ExerciseEvent {
  final String exerciseId;

  const DeleteExerciseEvent({required this.exerciseId});

  @override
  List<Object> get props => [exerciseId];
}

class UpdateExerciseEvent extends ExerciseEvent {
  final Exercise exercise;

  const UpdateExerciseEvent({required this.exercise});

  @override
  List<Object> get props => [exercise];
}
