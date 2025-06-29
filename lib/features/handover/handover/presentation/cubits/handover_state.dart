part of 'handover_cubit.dart';

@immutable
abstract class HandoverState {}

class HandoverInitial extends HandoverState {}

class HandoverLoading extends HandoverState {}

class HandoverDataLoaded extends HandoverState {
  final ContractModel contract;
  HandoverDataLoaded(this.contract);
}

class HandoverConfirmationsUpdated extends HandoverState {
  final bool isContractSigned;
  final bool isRemainingAmountReceived;
  HandoverConfirmationsUpdated({
    required this.isContractSigned,
    required this.isRemainingAmountReceived,
  });
}

class HandoverSending extends HandoverState {}

class HandoverSuccess extends HandoverState {
  final String message;
  final String contractId;
  HandoverSuccess({
    required this.message,
    required this.contractId,
  });
}

class HandoverCancelling extends HandoverState {}

class HandoverCancelled extends HandoverState {
  final String message;
  HandoverCancelled(this.message);
}

class HandoverFailure extends HandoverState {
  final String error;
  HandoverFailure(this.error);
} 