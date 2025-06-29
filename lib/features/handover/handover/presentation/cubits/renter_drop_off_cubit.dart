import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';
import '../models/post_trip_handover_model.dart';
import '../models/excess_charges_model.dart';
import '../models/handover_log_model.dart';

part 'renter_drop_off_state.dart';

class RenterDropOffCubit extends Cubit<RenterDropOffState> {
  RenterDropOffCubit() : super(RenterDropOffInitial());

  // Local storage for handover data
  PostTripHandoverModel? _handoverData;
  List<HandoverLogModel> _logs = [];

  // Initialize handover process
  Future<void> initializeHandover({
    required String tripId,
    required String carId,
    required String renterId,
    required String ownerId,
    required String paymentMethod,
  }) async {
    emit(RenterDropOffLoading());
    
    try {
      // Create new handover record
      _handoverData = PostTripHandoverModel(
        id: 'handover_${DateTime.now().millisecondsSinceEpoch}',
        tripId: tripId,
        carId: carId,
        renterId: renterId,
        ownerId: ownerId,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
      );

      // Add initial log
      _addLog(HandoverLogModel.create(
        handoverId: _handoverData!.id,
        action: HandoverLogModel.renterHandover,
        actor: HandoverLogModel.renter,
        description: 'Handover process started',
      ));

      emit(RenterDropOffInitialized(handoverData: _handoverData!));
    } catch (e) {
      emit(RenterDropOffError(message: 'Failed to initialize handover: $e'));
    }
  }

  // Upload car image after trip
  Future<void> uploadCarImage(File imageFile) async {
    if (_handoverData == null) {
      emit(RenterDropOffError(message: 'Handover not initialized'));
      return;
    }

    emit(RenterDropOffLoading());

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));
      
      // Update handover data
      _handoverData = _handoverData!.copyWith(
        carImagePath: imageFile.path,
        updatedAt: DateTime.now(),
      );

      // Add log entry
      _addLog(HandoverLogModel.create(
        handoverId: _handoverData!.id,
        action: HandoverLogModel.renterUploadCarImage,
        actor: HandoverLogModel.renter,
        description: 'Car image uploaded',
        metadata: {'imagePath': imageFile.path},
      ).markCompleted());

      emit(RenterDropOffCarImageUploaded(
        handoverData: _handoverData!,
        carImagePath: imageFile.path,
      ));
    } catch (e) {
      emit(RenterDropOffError(message: 'Failed to upload car image: $e'));
    }
  }

  // Upload odometer image
  Future<void> uploadOdometerImage(File imageFile) async {
    if (_handoverData == null) {
      emit(RenterDropOffError(message: 'Handover not initialized'));
      return;
    }

    emit(RenterDropOffLoading());

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));
      
      // Update handover data
      _handoverData = _handoverData!.copyWith(
        odometerImagePath: imageFile.path,
        updatedAt: DateTime.now(),
      );

      // Add log entry
      _addLog(HandoverLogModel.create(
        handoverId: _handoverData!.id,
        action: HandoverLogModel.renterUploadOdometer,
        actor: HandoverLogModel.renter,
        description: 'Odometer image uploaded',
        metadata: {'imagePath': imageFile.path},
      ).markCompleted());

      emit(RenterDropOffOdometerImageUploaded(
        handoverData: _handoverData!,
        odometerImagePath: imageFile.path,
      ));
    } catch (e) {
      emit(RenterDropOffError(message: 'Failed to upload odometer image: $e'));
    }
  }

  // Set final odometer reading
  void setFinalOdometerReading(int reading) {
    if (_handoverData == null) {
      emit(RenterDropOffError(message: 'Handover not initialized'));
      return;
    }

    _handoverData = _handoverData!.copyWith(
      finalOdometerReading: reading,
      updatedAt: DateTime.now(),
    );

    emit(RenterDropOffOdometerReadingSet(
      handoverData: _handoverData!,
      odometerReading: reading,
    ));
  }

  // Calculate excess charges
  Future<void> calculateExcessCharges({
    required int agreedKilometers,
    required int agreedHours,
    required double extraKmRate,
    required double extraHourRate,
  }) async {
    if (_handoverData == null || _handoverData!.finalOdometerReading == null) {
      emit(RenterDropOffError(message: 'Handover not initialized or odometer reading not set'));
      return;
    }

    emit(RenterDropOffLoading());

    try {
      // Simulate API call to get actual hours (in real app, this would come from trip data)
      await Future.delayed(Duration(seconds: 1));
      final actualHours = agreedHours + 4; // Mock: 4 extra hours
      
      // Calculate excess charges
      final excessCharges = ExcessChargesModel.calculate(
        agreedKilometers: agreedKilometers,
        actualKilometers: _handoverData!.finalOdometerReading!,
        extraKmRate: extraKmRate,
        agreedHours: agreedHours,
        actualHours: actualHours,
        extraHourRate: extraHourRate,
      );

      // Update handover data
      _handoverData = _handoverData!.copyWith(
        excessCharges: excessCharges,
        updatedAt: DateTime.now(),
      );

      emit(RenterDropOffExcessCalculated(
        handoverData: _handoverData!,
        excessCharges: excessCharges,
      ));
    } catch (e) {
      emit(RenterDropOffError(message: 'Failed to calculate excess charges: $e'));
    }
  }

  // Process payment
  Future<void> processPayment() async {
    if (_handoverData == null || _handoverData!.excessCharges == null) {
      emit(RenterDropOffError(message: 'Handover not initialized or excess charges not calculated'));
      return;
    }

    emit(RenterDropOffLoading());

    try {
      // Simulate payment API call
      await Future.delayed(Duration(seconds: 3));
      
      final paymentAmount = _handoverData!.excessCharges!.totalExcessCost;
      final paymentStatus = _handoverData!.paymentMethod == 'cash' ? 'pending' : 'completed';
      
      // Update handover data
      _handoverData = _handoverData!.copyWith(
        paymentAmount: paymentAmount,
        paymentStatus: paymentStatus,
        updatedAt: DateTime.now(),
      );

      // Add log entry
      _addLog(HandoverLogModel.create(
        handoverId: _handoverData!.id,
        action: HandoverLogModel.renterPayment,
        actor: HandoverLogModel.renter,
        description: 'Payment processed',
        metadata: {
          'amount': paymentAmount,
          'method': _handoverData!.paymentMethod,
          'status': paymentStatus,
        },
      ).markCompleted());

      emit(RenterDropOffPaymentProcessed(
        handoverData: _handoverData!,
        paymentAmount: paymentAmount,
        paymentStatus: paymentStatus,
      ));
    } catch (e) {
      emit(RenterDropOffError(message: 'Failed to process payment: $e'));
    }
  }

  // Add renter notes
  void addRenterNotes(String notes) {
    if (_handoverData == null) {
      emit(RenterDropOffError(message: 'Handover not initialized'));
      return;
    }

    _handoverData = _handoverData!.copyWith(
      renterNotes: notes,
      updatedAt: DateTime.now(),
    );

    emit(RenterDropOffNotesAdded(
      handoverData: _handoverData!,
      notes: notes,
    ));
  }

  // Complete renter handover
  Future<void> completeRenterHandover() async {
    if (_handoverData == null) {
      emit(RenterDropOffError(message: 'Handover not initialized'));
      return;
    }

    // Validate required fields
    if (_handoverData!.carImagePath == null ||
        _handoverData!.odometerImagePath == null ||
        _handoverData!.finalOdometerReading == null ||
        _handoverData!.excessCharges == null) {
      emit(RenterDropOffError(message: 'Please complete all required steps before finalizing handover'));
      return;
    }

    emit(RenterDropOffLoading());

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));
      
      // Update handover data
      _handoverData = _handoverData!.copyWith(
        renterHandoverStatus: 'completed',
        renterHandoverDate: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add log entry
      _addLog(HandoverLogModel.create(
        handoverId: _handoverData!.id,
        action: HandoverLogModel.renterHandover,
        actor: HandoverLogModel.renter,
        description: 'Renter handover completed',
        metadata: {
          'carImagePath': _handoverData!.carImagePath,
          'odometerImagePath': _handoverData!.odometerImagePath,
          'finalOdometerReading': _handoverData!.finalOdometerReading,
          'excessCharges': _handoverData!.excessCharges!.toJson(),
          'paymentAmount': _handoverData!.paymentAmount,
          'paymentStatus': _handoverData!.paymentStatus,
          'renterNotes': _handoverData!.renterNotes,
        },
      ).markCompleted());

      emit(RenterDropOffCompleted(
        handoverData: _handoverData!,
        logs: _logs,
      ));
    } catch (e) {
      emit(RenterDropOffError(message: 'Failed to complete handover: $e'));
    }
  }

  // Get current handover data
  PostTripHandoverModel? get handoverData => _handoverData;

  // Get logs
  List<HandoverLogModel> get logs => _logs;

  // Helper method to add logs
  void _addLog(HandoverLogModel log) {
    _logs.add(log);
  }

  // Reset state
  void reset() {
    _handoverData = null;
    _logs.clear();
    emit(RenterDropOffInitial());
  }
} 