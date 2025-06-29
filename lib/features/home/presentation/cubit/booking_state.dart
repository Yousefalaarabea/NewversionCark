part of 'booking_cubit.dart';

@immutable
abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<BookingModel> bookings;

  BookingLoaded(this.bookings);
}

class BookingError extends BookingState {
  final String message;

  BookingError(this.message);
}

// Booking Request States
class BookingRequestCreated extends BookingState {
  final Map<String, dynamic> bookingData;

  BookingRequestCreated(this.bookingData);
}

class BookingRequestAccepted extends BookingState {}

class BookingRequestDeclined extends BookingState {}

// Payment States
class DepositPaid extends BookingState {
  final double amount;

  DepositPaid(this.amount);
}

// Handover States
class OwnerHandoverCompleted extends BookingState {}

class RenterHandoverCompleted extends BookingState {}

// Trip States
class TripStarted extends BookingState {}

class TripCompleted extends BookingState {
  final double finalAmount;

  TripCompleted(this.finalAmount);
} 