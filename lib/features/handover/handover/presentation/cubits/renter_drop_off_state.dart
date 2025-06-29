part of 'renter_drop_off_cubit.dart';

abstract class RenterDropOffState extends Equatable {
  const RenterDropOffState();

  @override
  List<Object?> get props => [];
}

class RenterDropOffInitial extends RenterDropOffState {}

class RenterDropOffLoading extends RenterDropOffState {}

class RenterDropOffError extends RenterDropOffState {
  final String message;

  const RenterDropOffError({required this.message});

  @override
  List<Object?> get props => [message];
}

class RenterDropOffInitialized extends RenterDropOffState {
  final PostTripHandoverModel handoverData;

  const RenterDropOffInitialized({required this.handoverData});

  @override
  List<Object?> get props => [handoverData];
}

class RenterDropOffCarImageUploaded extends RenterDropOffState {
  final PostTripHandoverModel handoverData;
  final String carImagePath;

  const RenterDropOffCarImageUploaded({
    required this.handoverData,
    required this.carImagePath,
  });

  @override
  List<Object?> get props => [handoverData, carImagePath];
}

class RenterDropOffOdometerImageUploaded extends RenterDropOffState {
  final PostTripHandoverModel handoverData;
  final String odometerImagePath;

  const RenterDropOffOdometerImageUploaded({
    required this.handoverData,
    required this.odometerImagePath,
  });

  @override
  List<Object?> get props => [handoverData, odometerImagePath];
}

class RenterDropOffOdometerReadingSet extends RenterDropOffState {
  final PostTripHandoverModel handoverData;
  final int odometerReading;

  const RenterDropOffOdometerReadingSet({
    required this.handoverData,
    required this.odometerReading,
  });

  @override
  List<Object?> get props => [handoverData, odometerReading];
}

class RenterDropOffExcessCalculated extends RenterDropOffState {
  final PostTripHandoverModel handoverData;
  final ExcessChargesModel excessCharges;

  const RenterDropOffExcessCalculated({
    required this.handoverData,
    required this.excessCharges,
  });

  @override
  List<Object?> get props => [handoverData, excessCharges];
}

class RenterDropOffPaymentProcessed extends RenterDropOffState {
  final PostTripHandoverModel handoverData;
  final double paymentAmount;
  final String paymentStatus;

  const RenterDropOffPaymentProcessed({
    required this.handoverData,
    required this.paymentAmount,
    required this.paymentStatus,
  });

  @override
  List<Object?> get props => [handoverData, paymentAmount, paymentStatus];
}

class RenterDropOffNotesAdded extends RenterDropOffState {
  final PostTripHandoverModel handoverData;
  final String notes;

  const RenterDropOffNotesAdded({
    required this.handoverData,
    required this.notes,
  });

  @override
  List<Object?> get props => [handoverData, notes];
}

class RenterDropOffCompleted extends RenterDropOffState {
  final PostTripHandoverModel handoverData;
  final List<HandoverLogModel> logs;

  const RenterDropOffCompleted({
    required this.handoverData,
    required this.logs,
  });

  @override
  List<Object?> get props => [handoverData, logs];
} 