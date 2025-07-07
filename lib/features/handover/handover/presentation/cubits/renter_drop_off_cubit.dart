import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';
import '../models/post_trip_handover_model.dart';
import '../models/excess_charges_model.dart';
import '../models/handover_log_model.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../../../../core/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'renter_drop_off_state.dart';

class RenterDropOffCubit extends Cubit<RenterDropOffState> {
  RenterDropOffCubit() : super(RenterDropOffInitial());

  // Local storage for handover data
  PostTripHandoverModel? _handoverData;
  List<HandoverLogModel> _logs = [];

  // Initialize handover process
  Future<void> initializeHandover({
    required String carId,
    required String ownerId,
    required String paymentMethod,
    required String rentalId,
  }) async {
    emit(RenterDropOffLoading());
    
    try {
      // Create new handover record
      _handoverData = PostTripHandoverModel(
        id: 'handover_${DateTime.now().millisecondsSinceEpoch}',
        carId: carId.toString(),
        ownerId: ownerId.toString(),
        rentalId: rentalId.toString(),
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
    required String rentalId,
    required double currentOdometer,
    required BuildContext context,
  }) async {
    if (_handoverData == null) {
      emit(RenterDropOffError(message: 'Handover not initialized'));
      return;
    }

    emit(RenterDropOffLoading());

    try {
      final apiService = ApiService();
      final endpoint = 'selfdrive-rentals/$rentalId/current-odometer/';
      final response = await apiService.postWithToken(endpoint, {
        'currentOdometer': currentOdometer,
      });
      if (response.statusCode == 200) {
        final data = response.data;
        final odometerDetails = data['odometer_details'] ?? {};
        final timeDetails = data['time_details'] ?? {};
        final costDetails = data['cost_details'] ?? {};

        // Extract needed values
        final agreedKilometers = (odometerDetails['agreed_kilometers'] ?? 0).toDouble();
        final actualKilometers = (odometerDetails['current_odometer'] ?? 0).toDouble();
        final extraKmRate = (costDetails['extra_km_rate'] ?? 0).toDouble();
        final extraKmCost = (costDetails['extra_km_cost'] ?? 0).toDouble();
        final agreedDays = (timeDetails['agreed_days'] ?? 0).toInt();
        final extraDays = (timeDetails['extra_days'] ?? 0).toInt();
        final dailyPrice = (costDetails['daily_price'] ?? 0).toDouble();
        final extraDaysCost = (costDetails['extra_days_cost'] ?? 0).toDouble();
        final totalExtrasCost = (costDetails['total_extras_cost'] ?? 0).toDouble();
        final finalCost = (costDetails['final_cost'] ?? 0).toDouble();

        // You can use these values to build your ExcessChargesModel or similar
        final excessCharges = ExcessChargesModel(
          agreedKilometers: agreedKilometers.toInt(),
          actualKilometers: actualKilometers.toInt(),
          extraKilometers: (odometerDetails['extra_kilometers'] ?? 0).toInt(),
        extraKmRate: extraKmRate,
          extraKmCost: extraKmCost,
          agreedHours: agreedDays,
          actualHours: agreedDays + extraDays,
          extraHours: extraDays,
          extraHourRate: dailyPrice,
          extraHourCost: extraDaysCost,
          totalExcessCost: totalExtrasCost,
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
      } else {
        emit(RenterDropOffError(message: 'Failed to fetch odometer data: ${response.statusCode}'));
      }
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
      final apiService = ApiService();
      final rentalId = _handoverData!.rentalId;

  //     // Debug prints for all values
  //     print("odometerImagePath: "+(_handoverData!.odometerImagePath ?? 'NULL'));
  //     print("carImagePath: "+(_handoverData!.carImagePath ?? 'NULL'));
  //     print("finalOdometerReading: "+(_handoverData!.finalOdometerReading?.toString() ?? 'NULL'));
  //     print("notes: "+(_handoverData!.renterNotes ?? ''));
  //     print("rentalId: $rentalId");
  //
  //     MultipartFile? odometerFile;
  //     MultipartFile? carFile;
  //     try {
  //       odometerFile = await MultipartFile.fromFile(_handoverData!.odometerImagePath!);
  //     } catch (e) {
  //       print("Error in odometerFile: $e");
  //       emit(RenterDropOffError(message: 'Error in odometer image: $e'));
  //       return;
  //     }
  //     try {
  //       carFile = await MultipartFile.fromFile(_handoverData!.carImagePath!);
  //     } catch (e) {
  //       print("Error in carFile: $e");
  //       emit(RenterDropOffError(message: 'Error in car image: $e'));
  //       return;
  //     }
  //
  //     final formData = FormData.fromMap({
  //       'odometer_image': odometerFile,
  //       'car_image': carFile,
  //       'odometer_value': _handoverData!.finalOdometerReading.toString(),
  //       'notes': _handoverData!.renterNotes ?? '',
  //     });
  //     print("1111111111111111111111111111111111111111111111111111111");
  //
  //     final dio = Dio();
  //     // جلب التوكن من SharedPreferences
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('access_token');
  //     if (token == null) {
  //       emit(RenterDropOffError(message: 'User access token not found'));
  //       return;
  //     }
  //     final response = await dio.post(
  //       '${ApiService().baseUrl}selfdrive-rentals/$rentalId/renter_dropoff_handover/',
  //       data: formData,
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Bearer $token',
  //           'Accept': 'application/json',
  //         },
  //       ),
  //     );
  //     print("22222222222222222222222222222222222222222222222222222222");
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //     // Update handover data
  //       print("333333333333333333333333333333333333333333333333333");
  //
  //       _handoverData = _handoverData!.copyWith(
  //       renterHandoverStatus: 'completed',
  //       renterHandoverDate: DateTime.now(),
  //       updatedAt: DateTime.now(),
  //     );
  //
  //     // Add log entry
  //     _addLog(HandoverLogModel.create(
  //       handoverId: _handoverData!.id,
  //       action: HandoverLogModel.renterHandover,
  //       actor: HandoverLogModel.renter,
  //       description: 'Renter handover completed',
  //       metadata: {
  //         'carImagePath': _handoverData!.carImagePath,
  //         'odometerImagePath': _handoverData!.odometerImagePath,
  //         'finalOdometerReading': _handoverData!.finalOdometerReading,
  //         'excessCharges': _handoverData!.excessCharges!.toJson(),
  //         'paymentAmount': _handoverData!.paymentAmount,
  //         'paymentStatus': _handoverData!.paymentStatus,
  //         'renterNotes': _handoverData!.renterNotes,
  //       },
  //     ).markCompleted());
  //
  //     emit(RenterDropOffCompleted(
  //       handoverData: _handoverData!,
  //       logs: _logs,
  //     ));
  //     } else {
  //       emit(RenterDropOffError(message: 'Failed to complete handover: ${response.statusCode}'));
  //     }
  //   } catch (e) {
  //     emit(RenterDropOffError(message: 'Failed to complete handover: $e'));
  //   }
  // }

      // Debug prints for all values
      print("odometerImagePath: "+(_handoverData!.odometerImagePath ?? 'NULL'));
      print("carImagePath: "+(_handoverData!.carImagePath ?? 'NULL'));
      print("finalOdometerReading: "+(_handoverData!.finalOdometerReading?.toString() ?? 'NULL'));
      print("notes: "+(_handoverData!.renterNotes ?? ''));
      print("rentalId: $rentalId");

      MultipartFile odometerFile;
      MultipartFile carFile;

      try {
        odometerFile = await MultipartFile.fromFile(
          _handoverData!.odometerImagePath!,
          filename: _handoverData!.odometerImagePath!.split(Platform.pathSeparator).last,
        );
      } catch (e) {
        print("Error creating odometerFile: $e");
        emit(RenterDropOffError(message: 'Error preparing odometer image: $e'));
        return;
      }
      try {
        carFile = await MultipartFile.fromFile(
          _handoverData!.carImagePath!,
          filename: _handoverData!.carImagePath!.split(Platform.pathSeparator).last,
        );
      } catch (e) {
        print("Error creating carFile: $e");
        emit(RenterDropOffError(message: 'Error preparing car image: $e'));
        return;
      }

      final Map<String, dynamic> formDataMap = {
        'odometer_image': odometerFile,
        'car_image': carFile,
        'odometer_value': _handoverData!.finalOdometerReading.toString(),
        'notes': _handoverData!.renterNotes ?? '',
      };

      // ✅ هنا هنستخدم الـ postMultipartWithToken اللي عملناها في ApiService
      // التأكد من أن الـ rentalId هو الجزء الصحيح في الـ URL
      final endpoint = 'selfdrive-rentals/$rentalId/renter_dropoff_handover/';

      final response = await apiService.postMultipartWithToken(endpoint, formDataMap);

      print("22222222222222222222222222222222222222222222222222222222");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("333333333333333333333333333333333333333333333333333");

        _handoverData = _handoverData!.copyWith(
          renterHandoverStatus: 'completed',
          renterHandoverDate: DateTime.now(),
          updatedAt: DateTime.now(),
        );

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
      } else {
        emit(RenterDropOffError(message: 'Failed to complete handover: ${response.statusCode} - ${response.data}'));
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to complete handover: ${e.message}';
      if (e.response != null) {
        errorMessage += ' (Status: ${e.response?.statusCode}, Data: ${e.response?.data})';
      }
      emit(RenterDropOffError(message: errorMessage));
      print('DioException in completeRenterHandover: $e');
    } catch (e) {
      emit(RenterDropOffError(message: 'Failed to complete handover: $e'));
      print('General error in completeRenterHandover: $e');
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