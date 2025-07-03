import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_cark/features/home/presentation/model/booking_model.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';
import 'package:test_cark/features/notifications/presentation/cubits/notification_cubit.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit() : super(BookingInitial());

  Future<void> fetchBookings() async {
    try {
      emit(BookingLoading());
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // This is where you would make your actual API call.
      // For now, we'll return mock data.
      final List<BookingModel> bookings = [
        BookingModel(
          car: CarModel(
            id: 1,
            model: 'Camry',
            brand: 'Toyota',
            carType: 'Sedan',
            carCategory: 'Economy',
            plateNumber: 'ABC123',
            year: 2022,
            color: 'White',
            seatingCapacity: 5,
            transmissionType: 'Automatic',
            fuelType: 'Petrol',
            currentOdometerReading: 35000,
            availability: true,
            currentStatus: 'Available',
            approvalStatus: true,
            ownerId: '11',
            avgRating: 4.8,
            totalReviews: 156,
          ),
          startDate: DateTime(2024, 5, 20),
          endDate: DateTime(2024, 5, 23),
          totalPrice: 6400.00,
          status: 'Completed',
        ),
        BookingModel(
          car: CarModel(
            id: 2,
            model: 'X5',
            brand: 'BMW',
            carType: 'SUV',
            carCategory: 'Luxury',
            plateNumber: 'BMW001',
            year: 2024,
            color: 'Black',
            seatingCapacity: 5,
            transmissionType: 'Automatic',
            fuelType: 'Petrol',
            currentOdometerReading: 10000,
            availability: true,
            currentStatus: 'Available',
            approvalStatus: true,
            ownerId: '22',
            avgRating: 4.9,
            totalReviews: 203,
          ),
          startDate: DateTime(2024, 6, 15),
          endDate: DateTime(2024, 6, 18),
          totalPrice: 450.00,
          status: 'Active',
        ),
      ];

      emit(BookingLoaded(bookings));
    } catch (e) {
      emit(BookingError("Failed to fetch bookings."));
    }
  }

  // Create a new booking request
  Future<void> createBookingRequest({
    required String renterId,
    required String ownerId,
    required CarModel car,
    required double totalPrice,
    required String pickupStation,
    required String returnStation,
    required String dateRange,
    required String renterName,
    NotificationCubit? notificationCubit,
  }) async {
    try {
      emit(BookingLoading());

      final bookingRequestData = {
        'renterId': renterId,
        'ownerId': ownerId,
        'carId': car.id,
        'carBrand': car.brand,
        'carModel': car.model,
        'totalPrice': totalPrice,
        'pickupStation': pickupStation,
        'returnStation': returnStation,
        'dateRange': dateRange,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('booking_requests')
          .add(bookingRequestData);

      // Send in-app notification to owner
      notificationCubit?.sendBookingNotification(
        renterName: renterName,
        carBrand: car.brand,
        carModel: car.model,
        ownerId: ownerId,
        renterId: renterId,
        type: 'booking_request',
      );

      emit(BookingRequestCreated(bookingRequestData));
    } catch (e) {
      emit(BookingError("Failed to create booking request: $e"));
    }
  }

  // Accept a booking request (owner action)
  Future<void> acceptBookingRequest({
    required String bookingRequestId,
    required String renterId,
    required String ownerId,
    required String carBrand,
    required String carModel,
    required String ownerName,
    NotificationCubit? notificationCubit,
  }) async {
    try {
      emit(BookingLoading());

      // Update booking request status
      await FirebaseFirestore.instance
          .collection('booking_requests')
          .doc(bookingRequestId)
          .update({
        'status': 'accepted',
        'acceptedAt': DateTime.now().toIso8601String(),
      });

      // Send in-app notification to renter
      notificationCubit?.sendBookingNotification(
        renterName: 'You',
        carBrand: carBrand,
        carModel: carModel,
        ownerId: ownerId,
        renterId: renterId,
        type: 'booking_accepted',
      );

      emit(BookingRequestAccepted());
    } catch (e) {
      emit(BookingError("Failed to accept booking request: $e"));
    }
  }

  // Decline a booking request (owner action)
  Future<void> declineBookingRequest({
    required String bookingRequestId,
    required String renterId,
    required String carBrand,
    required String carModel,
    NotificationCubit? notificationCubit,
  }) async {
    try {
      emit(BookingLoading());

      // Update booking request status
      await FirebaseFirestore.instance
          .collection('booking_requests')
          .doc(bookingRequestId)
          .update({
        'status': 'declined',
        'declinedAt': DateTime.now().toIso8601String(),
      });

      // Send in-app notification to renter
      notificationCubit?.sendBookingNotification(
        renterName: 'You',
        carBrand: carBrand,
        carModel: carModel,
        ownerId: '',
        renterId: renterId,
        type: 'booking_declined',
      );

      emit(BookingRequestDeclined());
    } catch (e) {
      emit(BookingError("Failed to decline booking request: $e"));
    }
  }

  // Pay deposit (renter action)
  Future<void> payDeposit({
    required String bookingRequestId,
    required double depositAmount,
    required String renterId,
    required String ownerId,
    required String renterName,
    required String carBrand,
    required String carModel,
    NotificationCubit? notificationCubit,
  }) async {
    try {
      emit(BookingLoading());

      // Update booking request status
      await FirebaseFirestore.instance
          .collection('booking_requests')
          .doc(bookingRequestId)
          .update({
        'status': 'deposit_paid',
        'depositAmount': depositAmount,
        'depositPaidAt': DateTime.now().toIso8601String(),
      });

      // Send in-app notification to owner
      notificationCubit?.sendPaymentNotification(
        amount: depositAmount.toStringAsFixed(2),
        carBrand: carBrand,
        carModel: carModel,
        type: 'deposit_paid',
      );

      // Send handover notification to owner
      notificationCubit?.sendHandoverNotification(
        carBrand: carBrand,
        carModel: carModel,
        type: 'handover_started',
        userName: renterName,
      );

      emit(DepositPaid(depositAmount));
    } catch (e) {
      emit(BookingError("Failed to pay deposit: $e"));
    }
  }

  // Complete owner handover
  Future<void> completeOwnerHandover({
    required String bookingRequestId,
    required String renterId,
    required String ownerId,
    required String ownerName,
    required String carBrand,
    required String carModel,
    NotificationCubit? notificationCubit,
  }) async {
    try {
      emit(BookingLoading());

      // Update booking request status
      await FirebaseFirestore.instance
          .collection('booking_requests')
          .doc(bookingRequestId)
          .update({
        'status': 'owner_handover_completed',
        'ownerHandoverCompletedAt': DateTime.now().toIso8601String(),
      });

      // Send in-app notification to renter
      notificationCubit?.sendHandoverNotification(
        carBrand: carBrand,
        carModel: carModel,
        type: 'handover_started',
        userName: ownerName,
      );

      emit(OwnerHandoverCompleted());
    } catch (e) {
      emit(BookingError("Failed to complete owner handover: $e"));
    }
  }

  // Complete renter handover
  Future<void> completeRenterHandover({
    required String bookingRequestId,
    required String renterId,
    required String ownerId,
    required String renterName,
    required String carBrand,
    required String carModel,
    NotificationCubit? notificationCubit,
  }) async {
    try {
      emit(BookingLoading());

      // Update booking request status
      await FirebaseFirestore.instance
          .collection('booking_requests')
          .doc(bookingRequestId)
          .update({
        'status': 'trip_started',
        'renterHandoverCompletedAt': DateTime.now().toIso8601String(),
        'tripStartedAt': DateTime.now().toIso8601String(),
      });

      // Send in-app notification to owner
      notificationCubit?.sendHandoverNotification(
        carBrand: carBrand,
        carModel: carModel,
        type: 'handover_completed',
        userName: renterName,
      );

      // Send trip started notification
      notificationCubit?.sendTripNotification(
        carBrand: carBrand,
        carModel: carModel,
        type: 'trip_started',
      );

      emit(RenterHandoverCompleted());
    } catch (e) {
      emit(BookingError("Failed to complete renter handover: $e"));
    }
  }

  // Get booking requests for a user
  Stream<List<Map<String, dynamic>>> getBookingRequestsForUser(String userId, String userRole) {
    return FirebaseFirestore.instance
        .collection('booking_requests')
        .where(userRole == 'owner' ? 'ownerId' : 'renterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }
} 