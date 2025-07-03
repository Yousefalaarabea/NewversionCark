import 'package:equatable/equatable.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';
import 'package:test_cark/features/cars/presentation/models/car_rental_options.dart';
import 'package:test_cark/features/cars/presentation/models/car_usage_policy.dart';

class CarBundle {
  final CarModel car;
  final CarRentalOptions? rentalOptions;
  final CarUsagePolicy? usagePolicy;
  CarBundle({required this.car, this.rentalOptions, this.usagePolicy});
}

abstract class AddCarState extends Equatable {
  const AddCarState();

  @override
  List<Object?> get props => [];
}

class AddCarInitial extends AddCarState {}

class AddCarLoading extends AddCarState {}

class AddCarSuccess extends AddCarState {
  final CarBundle carBundle;

  const AddCarSuccess({required this.carBundle});

  @override
  List<Object?> get props => [carBundle];
}

class AddCarError extends AddCarState {
  final String message;

  const AddCarError({required this.message});

  @override
  List<Object?> get props => [message];
}

class AddCarFetchedSuccessfully extends AddCarState {
  final List<CarBundle> cars;

  const AddCarFetchedSuccessfully({required this.cars});

  @override
  List<Object?> get props => [cars];
}
