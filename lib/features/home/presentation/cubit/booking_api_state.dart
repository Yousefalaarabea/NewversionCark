part of 'booking_api_cubit.dart';

@immutable
abstract class BookingApiState {}

class BookingApiInitial extends BookingApiState {}

class BookingApiLoading extends BookingApiState {}

class BookingApiSuccess extends BookingApiState {
  final Map<String, dynamic> data;
  BookingApiSuccess(this.data);
}

class BookingApiError extends BookingApiState {
  final String message;
  BookingApiError(this.message);
}

class BookingApiCostsCalculated extends BookingApiState {
  final Map<String, dynamic> breakdown;
  BookingApiCostsCalculated(this.breakdown);
}

class BookingApiRentalsLoaded extends BookingApiState {
  final List<Map<String, dynamic>> rentals;
  BookingApiRentalsLoaded(this.rentals);
}

class BookingApiRentalDetailsLoaded extends BookingApiState {
  final Map<String, dynamic> rental;
  BookingApiRentalDetailsLoaded(this.rental);
}

class BookingApiBookingConfirmed extends BookingApiState {
  final Map<String, dynamic> result;
  BookingApiBookingConfirmed(this.result);
}

class BookingApiDepositPaid extends BookingApiState {
  final Map<String, dynamic> result;
  BookingApiDepositPaid(this.result);
}

class BookingApiTripStarted extends BookingApiState {
  final Map<String, dynamic> result;
  BookingApiTripStarted(this.result);
}

class BookingApiTripEnded extends BookingApiState {
  final Map<String, dynamic> result;
  BookingApiTripEnded(this.result);
}

class BookingApiRentalCanceled extends BookingApiState {
  final Map<String, dynamic> result;
  BookingApiRentalCanceled(this.result);
}