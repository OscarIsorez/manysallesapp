import 'package:equatable/equatable.dart';
import 'package:manysallesapp/features/gym_tracking/domain/entities/exercise.dart';

abstract class ExerciseState extends Equatable {
  const ExerciseState();

  @override
  List<Object> get props => [];
}

class ExerciseInitial extends ExerciseState {}

class ExerciseLoading extends ExerciseState {}

class ExerciseLoaded extends ExerciseState {
  final List<Exercise> exercises;

  const ExerciseLoaded({required this.exercises});

  @override
  List<Object> get props => [exercises];
}

class ExerciseError extends ExerciseState {
  final String message;

  const ExerciseError({required this.message});

  @override
  List<Object> get props => [message];
}

class ExerciseAddedSuccess extends ExerciseState {}
