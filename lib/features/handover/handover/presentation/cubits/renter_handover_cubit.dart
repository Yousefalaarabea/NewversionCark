import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import '../models/renter_handover_model.dart';
import 'dart:async';
import 'package:test_cark/core/booking_service.dart';

part 'renter_handover_state.dart';

class RenterHandoverCubit extends Cubit<RenterHandoverState> {
  RenterHandoverCubit() : super(RenterHandoverInitial());

  RenterHandoverModel _model = RenterHandoverModel();
  bool _ownerHandoverSent = false;
  int? _rentalId;

  void setRentalId(int id) => _rentalId = id;

  // Simulate fetching handover status from backend
  Future<void> fetchHandoverStatus() async {
    emit(RenterHandoverLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    // Mock: owner has sent handover
    _ownerHandoverSent = true;
    emit(RenterHandoverStatusLoaded(ownerHandoverSent: _ownerHandoverSent, model: _model));
  }

  void uploadCarImage(String imagePath) {
    _model = _model.copyWith(carImagePath: imagePath);
    emit(RenterHandoverStatusLoaded(ownerHandoverSent: _ownerHandoverSent, model: _model));
  }

  void updateOdometer(int odometer) {
    _model = _model.copyWith(odometerReading: odometer);
    emit(RenterHandoverStatusLoaded(ownerHandoverSent: _ownerHandoverSent, model: _model));
  }

  void confirmContract(bool confirmed) {
    _model = _model.copyWith(isContractConfirmed: confirmed);
    emit(RenterHandoverStatusLoaded(ownerHandoverSent: _ownerHandoverSent, model: _model));
  }

  // Simulate payment via Paymob
  Future<void> payRemainingAmount() async {
    emit(RenterHandoverPaymentProcessing());
    await Future.delayed(const Duration(seconds: 2));
    // Mock payment success
    _model = _model.copyWith(isPaymentCompleted: true);
    emit(RenterHandoverStatusLoaded(ownerHandoverSent: _ownerHandoverSent, model: _model));
  }

  void uploadOdometerImage(String imagePath) {
    _model = _model.copyWith(odometerImagePath: imagePath);
    emit(RenterHandoverStatusLoaded(ownerHandoverSent: _ownerHandoverSent, model: _model));
  }

  // Final send handover
  Future<void> sendHandover() async {
    if (!_ownerHandoverSent) {
      emit(RenterHandoverFailure('Owner has not sent handover yet.'));
      return;
    }
    if (_model.carImagePath == null) {
      emit(RenterHandoverFailure('Please upload car image.'));
      return;
    }
    if (_model.odometerReading == null) {
      emit(RenterHandoverFailure('Please enter odometer reading.'));
      return;
    }
    if (_model.odometerImagePath == null) {
      emit(RenterHandoverFailure('Please upload odometer image.'));
      return;
    }
    if (!_model.isContractConfirmed) {
      emit(RenterHandoverFailure('Please confirm contract signing.'));
      return;
    }
    // if (!_model.isPaymentCompleted) {
    //   emit(RenterHandoverFailure('Please complete payment.'));
    //   return;
    // }
    emit(RenterHandoverSending());
    try {
      final bookingService = BookingService();
      final rentalId = _rentalId;
      if (rentalId == null) {
        emit(RenterHandoverFailure('Invalid rental ID'));
        return;
      }
      final response = await bookingService.renterPickupHandover(
        rentalId: rentalId,
        carImagePath: _model.carImagePath!,
        odometerImagePath: _model.odometerImagePath!,
        odometerValue: _model.odometerReading!,
      );
      emit(RenterHandoverSuccess());
    } catch (e) {
      emit(RenterHandoverFailure('Failed to send handover: \\${e.toString()}'));
    }
  }
} 