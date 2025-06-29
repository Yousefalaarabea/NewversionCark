import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/contract_model.dart';

part 'handover_state.dart';

class HandoverCubit extends Cubit<HandoverState> {
  HandoverCubit() : super(HandoverInitial()) {
    // Load initial contract data
    loadContractData();
  }

  ContractModel? _contract;
  bool _isContractSigned = false;
  bool _isRemainingAmountReceived = false;

  ContractModel? get contract => _contract;
  bool get isContractSigned => _isContractSigned;
  bool get isRemainingAmountReceived => _isRemainingAmountReceived;

  // Load contract data (mock implementation)
  Future<void> loadContractData() async {
    emit(HandoverLoading());
    
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    _contract = ContractModel.mock();
    emit(HandoverDataLoaded(_contract!));
  }

  // Update contract signing confirmation
  void updateContractSigned(bool value) {
    _isContractSigned = value;
    emit(HandoverConfirmationsUpdated(
      isContractSigned: _isContractSigned,
      isRemainingAmountReceived: _isRemainingAmountReceived,
    ));
  }

  // Update remaining amount confirmation
  void updateRemainingAmountReceived(bool value) {
    _isRemainingAmountReceived = value;
    emit(HandoverConfirmationsUpdated(
      isContractSigned: _isContractSigned,
      isRemainingAmountReceived: _isRemainingAmountReceived,
    ));
  }

  // Check if handover can be sent
  bool get canSendHandover {
    if (_contract == null) return false;
    if (!_contract!.isDepositPaid) return false;
    if (!_isContractSigned) return false;
    if (!_isRemainingAmountReceived) return false;
    return true;
  }

  // Send handover request
  Future<void> sendHandover({required String contractImagePath}) async {
    if (!canSendHandover) {
      emit(HandoverFailure('Please complete all requirements before sending handover'));
      return;
    }

    try {
      emit(HandoverSending());
      
      // Simulate API call with backend response
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate backend response
      final backendResponse = await _simulateBackendCall(contractImagePath);
      
      if (backendResponse['success'] == true) {
        // Update contract with new data
        _contract = _contract!.copyWith(
          contractImagePath: contractImagePath,
          isContractSigned: _isContractSigned,
          isRemainingAmountReceived: _isRemainingAmountReceived,
          status: 'completed',
        );
        
        emit(HandoverSuccess(
          message: backendResponse['message'] ?? 'Handover completed successfully',
          contractId: backendResponse['contractId'] ?? _contract!.id,
        ));
      } else {
        emit(HandoverFailure(backendResponse['error'] ?? 'Failed to complete handover'));
      }
    } catch (e) {
      emit(HandoverFailure('Failed to send handover: ${e.toString()}'));
    }
  }

  // Simulate backend API call
  Future<Map<String, dynamic>> _simulateBackendCall(String contractImagePath) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simulate successful backend response
    // In real implementation, this would be an actual API call
    return {
      'success': true,
      'message': 'Handover completed successfully! Your car has been handed over to the renter.',
      'contractId': 'CONTRACT_${DateTime.now().millisecondsSinceEpoch}',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // To simulate failure, uncomment the following:
    // return {
    //   'success': false,
    //   'error': 'Network error occurred. Please try again.',
    // };
  }

  // Cancel handover and refund deposit
  Future<void> cancelHandover() async {
    try {
      emit(HandoverCancelling());
      
      // Simulate API call for refund
      await Future.delayed(const Duration(seconds: 1));
      
      // Simulate backend response for cancellation
      final backendResponse = await _simulateCancelBackendCall();
      
      if (backendResponse['success'] == true) {
        // Update contract status
        _contract = _contract!.copyWith(status: 'cancelled');
        
        emit(HandoverCancelled(backendResponse['message'] ?? 'Handover cancelled. Deposit refunded to wallet.'));
      } else {
        emit(HandoverFailure(backendResponse['error'] ?? 'Failed to cancel handover'));
      }
    } catch (e) {
      emit(HandoverFailure('Failed to cancel handover: ${e.toString()}'));
    }
  }

  // Simulate backend API call for cancellation
  Future<Map<String, dynamic>> _simulateCancelBackendCall() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Simulate successful cancellation response
    return {
      'success': true,
      'message': 'Handover cancelled successfully. Deposit has been refunded to your wallet.',
      'refundAmount': _contract?.depositAmount ?? 0.0,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Reset handover state
  void resetHandover() {
    _isContractSigned = false;
    _isRemainingAmountReceived = false;
    emit(HandoverInitial());
  }
} 