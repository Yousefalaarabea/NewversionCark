import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:test_cark/config/routes/screens_name.dart';
import '../models/post_trip_handover_model.dart';
import '../models/excess_charges_model.dart';
import '../models/handover_log_model.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/api_service.dart';

part 'owner_drop_off_state.dart';

class OwnerDropOffCubit extends Cubit<OwnerDropOffState> {
  OwnerDropOffCubit() : super(OwnerDropOffInitial());

  // Local storage for handover data
  PostTripHandoverModel? _handoverData;
  List<HandoverLogModel> _logs = [];

  // Load handover data from renter
  Future<void> loadHandoverData(PostTripHandoverModel handoverData, List<HandoverLogModel> logs) async {
    emit(OwnerDropOffLoading());
    
    try {
      _handoverData = handoverData;
      _logs = logs;

      // Add initial log for owner review
      _addLog(HandoverLogModel.create(
        handoverId: _handoverData!.id,
        action: HandoverLogModel.ownerReview,
        actor: HandoverLogModel.owner,
        description: 'Owner started reviewing handover',
      ));

      emit(OwnerDropOffDataLoaded(
        handoverData: _handoverData!,
        logs: _logs,
      ));
    } catch (e) {
      emit(OwnerDropOffError(message: 'Failed to load handover data: $e'));
    }
  }

  // Confirm cash payment received (if payment method is cash)
  Future<void> confirmCashPayment() async {
    if (_handoverData == null) {
      emit(OwnerDropOffError(message: 'Handover data not loaded'));
      return;
    }

    if (_handoverData!.paymentMethod != 'cash') {
      emit(OwnerDropOffError(message: 'Payment method is not cash'));
      return;
    }

    emit(OwnerDropOffLoading());

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));
      
      // Update payment status
      _handoverData = _handoverData!.copyWith(
        paymentStatus: 'completed',
        updatedAt: DateTime.now(),
      );

      // Add log entry
      _addLog(HandoverLogModel.create(
        handoverId: _handoverData!.id,
        action: HandoverLogModel.ownerReview,
        actor: HandoverLogModel.owner,
        description: 'Cash payment confirmed',
        metadata: {
          'paymentAmount': _handoverData!.paymentAmount,
          'paymentStatus': 'completed',
        },
      ).markCompleted());

      emit(OwnerDropOffCashPaymentConfirmed(
        handoverData: _handoverData!,
        paymentAmount: _handoverData!.paymentAmount ?? 0.0,
      ));
    } catch (e) {
      emit(OwnerDropOffError(message: 'Failed to confirm cash payment: $e'));
    }
  }

  // Add owner notes
  void addOwnerNotes(String notes) {
    if (_handoverData == null) {
      emit(OwnerDropOffError(message: 'Handover data not loaded'));
      return;
    }

    _handoverData = _handoverData!.copyWith(
      ownerNotes: notes,
      updatedAt: DateTime.now(),
    );

    emit(OwnerDropOffNotesAdded(
      handoverData: _handoverData!,
      notes: notes,
    ));
  }

  // Complete owner handover
  Future<void> completeOwnerHandover() async {
    if (_handoverData == null) {
      emit(OwnerDropOffError(message: 'Handover data not loaded'));
      return;
    }

    // Validate that renter has completed handover
    if (_handoverData!.renterHandoverStatus != 'completed') {
      emit(OwnerDropOffError(message: 'Renter handover not completed yet'));
      return;
    }

    // Validate cash payment if applicable
    if (_handoverData!.paymentMethod == 'cash' && _handoverData!.paymentStatus != 'completed') {
      emit(OwnerDropOffError(message: 'Please confirm cash payment before completing handover'));
      return;
    }

    emit(OwnerDropOffLoading());

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));
      
      // Update handover data
      _handoverData = _handoverData!.copyWith(
        ownerHandoverStatus: 'completed',
        ownerHandoverDate: DateTime.now(),
        tripStatus: 'completed',
        updatedAt: DateTime.now(),
      );

      // Add log entry
      _addLog(HandoverLogModel.create(
        handoverId: _handoverData!.id,
        action: HandoverLogModel.ownerHandover,
        actor: HandoverLogModel.owner,
        description: 'Owner handover completed - Trip finished',
        metadata: {
          'tripStatus': 'completed',
          'ownerNotes': _handoverData!.ownerNotes,
          'finalPaymentStatus': _handoverData!.paymentStatus,
        },
      ).markCompleted());

      emit(OwnerDropOffCompleted(
        handoverData: _handoverData!,
        logs: _logs,
      ));
    } catch (e) {
      emit(OwnerDropOffError(message: 'Failed to complete handover: $e'));
    }
  }

  // Complete owner dropoff handover (multipart, like renter)
  Future<void> completeOwnerDropoffHandover({
    required File carImageFile,
    required File odometerImageFile,
    required double odometerValue,
    required String notes,
    bool? confirmExcessCash,
    required String rentalId,
  }) async {
    emit(OwnerDropOffLoading());
    try {
      final apiService = ApiService();
      MultipartFile odometerFile;
      MultipartFile carFile;
      try {
        odometerFile = await MultipartFile.fromFile(
          odometerImageFile.path,
          filename: odometerImageFile.path.split(Platform.pathSeparator).last,
        );
      } catch (e) {
        emit(OwnerDropOffError(message: 'Error preparing odometer image: $e'));
        return;
      }
      try {
        carFile = await MultipartFile.fromFile(
          carImageFile.path,
          filename: carImageFile.path.split(Platform.pathSeparator).last,
        );
      } catch (e) {
        emit(OwnerDropOffError(message: 'Error preparing car image: $e'));
        return;
      }
      final Map<String, dynamic> formDataMap = {
        'odometer_image': odometerFile,
        'car_image': carFile,
        'odometer_value': odometerValue.toString(),
        'notes': notes,
      };
      if (confirmExcessCash != null) {
        formDataMap['confirm_excess_cash'] = confirmExcessCash.toString();
      }
      final endpoint = 'selfdrive-rentals/$rentalId/owner_dropoff_handover/';
      final response = await apiService.postMultipartWithToken(endpoint, formDataMap);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("KHALLLLLLLAAAAAAAAAAAAAAAAAAAS");
        emit(OwnerDropOffCompletedGeneric()); // حالة عامة للنجاح، الشاشة تظهر bottom sheet بعدها
      } else {
        emit(OwnerDropOffError(message: 'Failed to complete owner dropoff: ${response.statusCode} - ${response.data}'));
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to complete owner dropoff: ${e.message}';
      if (e.response != null) {
        errorMessage += ' (Status: ${e.response?.statusCode}, Data: ${e.response?.data})';
      }
      emit(OwnerDropOffError(message: errorMessage));
    } catch (e) {
      emit(OwnerDropOffError(message: 'Failed to complete owner dropoff: $e'));
    }
  }

  // --- Rating APIs ---
  Future<bool> sendRenterRating({
    required String rentalId,
    required int rating,
    required String notes,
  }) async {
    try {
      final apiService = ApiService();
      final res = await apiService.postWithToken(
        '/feedback/rate/renter/',
        {
          'rental_type': 'selfdriverental',
          'rental_id': int.tryParse(rentalId) ?? rentalId,
          'rating': rating,
          'notes': notes,
        },
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendCarRating({
    required String rentalId,
    required int rating,
    required String notes,
  }) async {
    try {
      final apiService = ApiService();
      final res = await apiService.postWithToken(
        '/feedback/rate/car/',
        {
          'rental_type': 'selfdriverental',
          'rental_id': int.tryParse(rentalId) ?? rentalId,
          'rating': rating,
          'notes': notes,
        },
      );
      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      return false;
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
    emit(OwnerDropOffInitial());
  }
}

// --- State for generic completion (for bottom sheet trigger) ---
class OwnerDropOffCompletedGeneric extends OwnerDropOffState {} 