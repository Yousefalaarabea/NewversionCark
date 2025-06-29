import 'package:equatable/equatable.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';

abstract class AddCarState extends Equatable {
  const AddCarState();

  @override
  List<Object?> get props => [];
}

class AddCarInitial extends AddCarState {}

class AddCarLoading extends AddCarState {}

class AddCarSuccess extends AddCarState {
  final CarModel car;

  const AddCarSuccess({required this.car});

  @override
  List<Object?> get props => [car];
}

class AddCarError extends AddCarState {
  final String message;

  const AddCarError({required this.message});

  @override
  List<Object?> get props => [message];
}
class AddCarFetchedSuccessfully extends AddCarState {
  final List<CarModel> cars;

  const AddCarFetchedSuccessfully({required this.cars});

  @override
  List<Object?> get props => [cars];
}
