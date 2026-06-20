import 'package:equatable/equatable.dart';

abstract class GymEvent extends Equatable {
  const GymEvent();

  @override
  List<Object> get props => [];
}

class GetGymsEvent extends GymEvent {}

class AddGymEvent extends GymEvent {
  final String gymName;

  const AddGymEvent({required this.gymName});

  @override
  List<Object> get props => [gymName];
}
