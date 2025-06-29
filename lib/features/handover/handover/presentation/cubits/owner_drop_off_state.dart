part of 'owner_drop_off_cubit.dart';

abstract class OwnerDropOffState extends Equatable {
  const OwnerDropOffState();

  @override
  List<Object?> get props => [];
}

class OwnerDropOffInitial extends OwnerDropOffState {}

class OwnerDropOffLoading extends OwnerDropOffState {}

class OwnerDropOffError extends OwnerDropOffState {
  final String message;

  const OwnerDropOffError({required this.message});

  @override
  List<Object?> get props => [message];
}

class OwnerDropOffDataLoaded extends OwnerDropOffState {
  final PostTripHandoverModel handoverData;
  final List<HandoverLogModel> logs;

  const OwnerDropOffDataLoaded({
    required this.handoverData,
    required this.logs,
  });

  @override
  List<Object?> get props => [handoverData, logs];
}

class OwnerDropOffCashPaymentConfirmed extends OwnerDropOffState {
  final PostTripHandoverModel handoverData;
  final double paymentAmount;

  const OwnerDropOffCashPaymentConfirmed({
    required this.handoverData,
    required this.paymentAmount,
  });

  @override
  List<Object?> get props => [handoverData, paymentAmount];
}

class OwnerDropOffNotesAdded extends OwnerDropOffState {
  final PostTripHandoverModel handoverData;
  final String notes;

  const OwnerDropOffNotesAdded({
    required this.handoverData,
    required this.notes,
  });

  @override
  List<Object?> get props => [handoverData, notes];
}

class OwnerDropOffCompleted extends OwnerDropOffState {
  final PostTripHandoverModel handoverData;
  final List<HandoverLogModel> logs;

  const OwnerDropOffCompleted({
    required this.handoverData,
    required this.logs,
  });

  @override
  List<Object?> get props => [handoverData, logs];
} 