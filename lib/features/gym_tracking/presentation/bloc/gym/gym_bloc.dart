import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manysallesapp/core/usecases/usecase.dart';
import 'package:manysallesapp/features/gym_tracking/domain/entities/gym.dart';
import 'package:manysallesapp/features/gym_tracking/domain/usecases/gym_usecases.dart';
import 'package:uuid/uuid.dart';

import 'gym_event.dart';
import 'gym_state.dart';

class GymBloc extends Bloc<GymEvent, GymState> {
  final GetGyms getGyms;
  final AddGym addGym;

  GymBloc({required this.getGyms, required this.addGym}) : super(GymInitial()) {
    on<GetGymsEvent>(_onGetGyms);
    on<AddGymEvent>(_onAddGym);
  }

  Future<void> _onGetGyms(GetGymsEvent event, Emitter<GymState> emit) async {
    emit(GymLoading());
    final failureOrGyms = await getGyms(NoParams());
    failureOrGyms.fold(
      (failure) => emit(GymError(message: failure.message)),
      (gyms) => emit(GymLoaded(gyms: gyms)),
    );
  }

  Future<void> _onAddGym(AddGymEvent event, Emitter<GymState> emit) async {
    emit(GymLoading());
    final newGym = Gym(id: const Uuid().v4(), name: event.gymName);
    final failureOrSuccess = await addGym(GymParams(gym: newGym));
    failureOrSuccess.fold(
      (failure) => emit(GymError(message: failure.message)),
      (_) {
        emit(GymAddedSuccess());
        add(GetGymsEvent());
      },
    );
  }
}
