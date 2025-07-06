import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/contract_model.dart';
import 'package:test_cark/core/booking_service.dart';

part 'handover_state.dart';

class HandoverCubit extends Cubit<HandoverState> {
  HandoverCubit() : super(HandoverInitial()) {
    // Load initial contract data
    loadContractData();
  }

  ContractModel? _contract;
  bool _isContractSigned = false;
  bool _isRemainingAmountReceived = false;
  int? _rentalId;

  ContractModel? get contract => _contract;
  bool get isContractSigned => _isContractSigned;
  bool get isRemainingAmountReceived => _isRemainingAmountReceived;
  int? get rentalId => _rentalId;

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

  // Check if handover can be sent (based on payment method)
  bool canSendHandover(String paymentMethod) {
    print('🔍 [HandoverCubit] canSendHandover called');
    print('🔍 [HandoverCubit] Current rentalId: $_rentalId');
    print('🔍 [HandoverCubit] paymentMethod: $paymentMethod');
    print('🔍 [HandoverCubit] contract: $_contract');
    print('🔍 [HandoverCubit] isContractSigned: $_isContractSigned');
    print('🔍 [HandoverCubit] isRemainingAmountReceived: $_isRemainingAmountReceived');
    
    if (_contract == null) {
      print('❌ [HandoverCubit] Contract is null');
      return false;
    }
    if (!_contract!.isDepositPaid) {
      print('❌ [HandoverCubit] Deposit not paid');
      return false;
    }
    if (!_isContractSigned) {
      print('❌ [HandoverCubit] Contract not signed');
      return false;
    }
    if (_rentalId == null) {
      print('❌ [HandoverCubit] rentalId is null');
      return false;
    }
    if (paymentMethod.toLowerCase() == 'cash' && !_isRemainingAmountReceived) {
      print('❌ [HandoverCubit] Cash payment but remaining amount not received');
      return false;
    }
    
    print('✅ [HandoverCubit] All conditions met, can send handover');
    return true;
  }

  void setRentalId(int id) {
    print('🔍 [HandoverCubit] Setting rentalId: $id');
    _rentalId = id;
    print('🔍 [HandoverCubit] rentalId set successfully: $_rentalId');
  }

  // Send handover request
  Future<void> sendHandover({required String contractImagePath, required String paymentMethod}) async {
    print('🔍 [HandoverCubit] sendHandover called');
    print('🔍 [HandoverCubit] Current rentalId: $_rentalId');
    print('🔍 [HandoverCubit] contractImagePath: $contractImagePath');
    print('🔍 [HandoverCubit] paymentMethod: $paymentMethod');
    
    if (!canSendHandover(paymentMethod)) {
      emit(HandoverFailure('Please complete all requirements before sending handover'));
      return;
    }

    try {
      print("🔍 [HandoverCubit] Starting handover process...");

      emit(HandoverSending());
      final bookingService = BookingService();
      final rentalId = _rentalId;
      print('🔍 [HandoverCubit] Extracted rentalId: $rentalId');
      
      if (rentalId == null) {
        print('❌ [HandoverCubit] rentalId is null! Cannot proceed with handover.');
        emit(HandoverFailure('Invalid rental ID - rentalId is null'));
        return;
      }
      
      print('✅ [HandoverCubit] Proceeding with handover for rentalId: $rentalId');
      
      Map<String, dynamic> response;
      if (paymentMethod.toLowerCase() == 'cash') {
        print('🔍 [HandoverCubit] Using cash payment method');
        response = await bookingService.ownerPickupHandover(
          rentalId: rentalId,
          contractImagePath: contractImagePath,
          confirmRemainingCash: _isRemainingAmountReceived,
        );
      } else {
        print('🔍 [HandoverCubit] Using non-cash payment method');
        response = await bookingService.ownerPickupHandover(
          rentalId: rentalId,
          contractImagePath: contractImagePath,
        );
      }
      
      print('✅ [HandoverCubit] Handover API call successful');
      print('🔍 [HandoverCubit] API Response: $response');
      
      // Success
      _contract = _contract!.copyWith(
        contractImagePath: contractImagePath,
        isContractSigned: _isContractSigned,
        isRemainingAmountReceived: _isRemainingAmountReceived,
        status: 'completed',
      );
      emit(HandoverSuccess(
        message: response['message'] ?? 'Handover completed successfully',
        contractId: response['contractId'] ?? _contract!.id,
      ));
    } catch (e) {
      print('❌ [HandoverCubit] Error in sendHandover: $e');
      emit(HandoverFailure('Failed to send handover: ${e.toString()}'));
    }
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