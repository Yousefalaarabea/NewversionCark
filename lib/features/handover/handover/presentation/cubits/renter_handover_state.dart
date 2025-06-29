part of 'renter_handover_cubit.dart';

@immutable
abstract class RenterHandoverState {}

class RenterHandoverInitial extends RenterHandoverState {}
class RenterHandoverLoading extends RenterHandoverState {}
class RenterHandoverStatusLoaded extends RenterHandoverState {
  final bool ownerHandoverSent;
  final RenterHandoverModel model;
  RenterHandoverStatusLoaded({required this.ownerHandoverSent, required this.model});
}
class RenterHandoverPaymentProcessing extends RenterHandoverState {}
class RenterHandoverSending extends RenterHandoverState {}
class RenterHandoverSuccess extends RenterHandoverState {}
class RenterHandoverFailure extends RenterHandoverState {
  final String error;
  RenterHandoverFailure(this.error);
} 