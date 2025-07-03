import 'package:test_cark/features/home/presentation/model/car_model.dart';

class BookingModel {
  final CarModel car;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final String status;

  BookingModel({
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.status,
  });

  // Mock data for a single booking
  factory BookingModel.mock() {
    return BookingModel(
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
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      endDate: DateTime.now().subtract(const Duration(days: 7)),
      totalPrice: 250.00,
      status: 'Completed',
    );
  }
} 