import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manysallesapp/core/usecases/usecase.dart';
import 'package:manysallesapp/features/gym_tracking/domain/entities/exercise.dart';
import 'package:manysallesapp/features/gym_tracking/domain/usecases/exercise_usecases.dart';
import 'package:uuid/uuid.dart';

import 'exercise_event.dart';
import 'exercise_state.dart';

class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  final GetExercises getExercises;
  final AddExercise addExercise;

  ExerciseBloc({required this.getExercises, required this.addExercise})
    : super(ExerciseInitial()) {
    on<GetExercisesEvent>(_onGetExercises);
    on<AddExerciseEvent>(_onAddExercise);
  }

  Future<void> _onGetExercises(
    GetExercisesEvent event,
    Emitter<ExerciseState> emit,
  ) async {
    emit(ExerciseLoading());
    final failureOrExercises = await getExercises(NoParams());
    failureOrExercises.fold(
      (failure) => emit(ExerciseError(message: failure.message)),
      (exercises) => emit(ExerciseLoaded(exercises: exercises)),
    );
  }

  Future<void> _onAddExercise(
    AddExerciseEvent event,
    Emitter<ExerciseState> emit,
  ) async {
    emit(ExerciseLoading());
    final newExercise = Exercise(
      id: const Uuid().v4(),
      name: event.exerciseName,
    );
    final failureOrSuccess = await addExercise(
      ExerciseParams(exercise: newExercise),
    );
    failureOrSuccess.fold(
      (failure) => emit(ExerciseError(message: failure.message)),
      (_) {
        emit(ExerciseAddedSuccess());
        add(GetExercisesEvent());
      },
    );
  }
}
