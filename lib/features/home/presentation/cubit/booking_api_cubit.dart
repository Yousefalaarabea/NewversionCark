import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import '../../../../core/booking_service.dart';
import '../model/car_model.dart';
import '../model/location_model.dart';

part 'booking_api_state.dart';

class BookingApiCubit extends Cubit<BookingApiState> {
  final BookingService _bookingService = BookingService();

  BookingApiCubit() : super(BookingApiInitial());

  // Create a new rental booking
  Future<void> createRental({
    required CarModel car,
    required DateTime startDate,
    required DateTime endDate,
    required String rentalType,
    required LocationModel pickupLocation,
    required LocationModel dropoffLocation,
    required String paymentMethod,
    List<LocationModel>? stops,
    int? selectedCardId,
  }) async {
    try {
      emit(BookingApiLoading());

      final result = await _bookingService.createRental(
        car: car,
        startDate: startDate,
        endDate: endDate,
        rentalType: rentalType,
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        paymentMethod: paymentMethod,
        stops: stops,
        selectedCardId: selectedCardId,
      );

      emit(BookingApiSuccess(result));
    } catch (e) {
      emit(BookingApiError(e.toString()));
    }
  }

  // Calculate rental costs
  Future<void> calculateRentalCosts({
    required int rentalId,
    required double plannedKm,
    required int totalWaitingMinutes,
  }) async {
    try {
      emit(BookingApiLoading());

      final result = await _bookingService.calculateRentalCosts(
        rentalId: rentalId,
        plannedKm: plannedKm,
        totalWaitingMinutes: totalWaitingMinutes,
      );

      emit(BookingApiCostsCalculated(result));
    } catch (e) {
      emit(BookingApiError(e.toString()));
    }
  }

  // Get user's rental history
  Future<void> getUserRentals() async {
    try {
      emit(BookingApiLoading());

      final rentals = await _bookingService.getUserRentals();
      emit(BookingApiRentalsLoaded(rentals));
    } catch (e) {
      emit(BookingApiError(e.toString()));
    }
  }

  // Get specific rental details
  Future<void> getRentalDetails(int rentalId) async {
    try {
      emit(BookingApiLoading());

      final rental = await _bookingService.getRentalDetails(rentalId);
      emit(BookingApiRentalDetailsLoaded(rental));
    } catch (e) {
      emit(BookingApiError(e.toString()));
    }
  }

  // Confirm booking (owner action)
  Future<void> confirmBooking(int rentalId) async {
    try {
      emit(BookingApiLoading());

      final result = await _bookingService.confirmBooking(rentalId);
      emit(BookingApiBookingConfirmed(result));
    } catch (e) {
      emit(BookingApiError(e.toString()));
    }
  }

  // Pay deposit
  Future<void> payDeposit({
    required int rentalId,
    required double amount,
    String? cardId,
  }) async {
    try {
      emit(BookingApiLoading());

      final result = await _bookingService.payDeposit(
        rentalId: rentalId,
        amount: amount,
        cardId: cardId,
      );
      emit(BookingApiDepositPaid(result));
    } catch (e) {
      emit(BookingApiError(e.toString()));
    }
  }

  // Start trip
  Future<void> startTrip(int rentalId) async {
    try {
      emit(BookingApiLoading());

      final result = await _bookingService.startTrip(rentalId);
      emit(BookingApiTripStarted(result));
    } catch (e) {
      emit(BookingApiError(e.toString()));
    }
  }

  // End trip
  Future<void> endTrip(int rentalId) async {
    try {
      emit(BookingApiLoading());

      final result = await _bookingService.endTrip(rentalId);
      emit(BookingApiTripEnded(result));
    } catch (e) {
      emit(BookingApiError(e.toString()));
    }
  }

  // Cancel rental
  Future<void> cancelRental(int rentalId) async {
    try {
      emit(BookingApiLoading());

      final result = await _bookingService.cancelRental(rentalId);
      emit(BookingApiRentalCanceled(result));
    } catch (e) {
      emit(BookingApiError(e.toString()));
    }
  }

  // Reset state
  void reset() {
    emit(BookingApiInitial());
  }
} 