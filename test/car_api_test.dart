// import 'package:flutter_test/flutter_test.dart';
// import 'package:test_cark/features/home/presentation/model/car_model.dart';
//
// void main() {
//   group('Car API Integration Tests', () {
//     test('CarModel.fromJson should parse API response correctly', () {
//       // Sample API response from the provided endpoints
//       final apiResponse = {
//         "id": 1,
//         "model": "shark",
//         "brand": "Mitsubishi",
//         "car_type": "Sedan",
//         "car_category": "Economy",
//         "plate_number": "XYZ123",
//         "year": 2003,
//         "color": "Black",
//         "seating_capacity": 5,
//         "transmission_type": "Automatic",
//         "fuel_type": "Petrol",
//         "current_odometer_reading": 20000,
//         "availability": true,
//         "current_status": "Available",
//         "created_at": "2025-06-29T00:09:42.179150Z",
//         "updated_at": "2025-06-29T00:09:181Z",
//         "approval_status": false,
//         "owner": 32
//       };
//
//       final car = CarModel.fromJson(apiResponse);
//
//       expect(car.id, equals(1));
//       expect(car.model, equals("shark"));
//       expect(car.brand, equals("Mitsubishi"));
//       expect(car.carType, equals("Sedan"));
//       expect(car.carCategory, equals("Economy"));
//       expect(car.plateNumber, equals("XYZ123"));
//       expect(car.year, equals(2003));
//       expect(car.color, equals("Black"));
//       expect(car.seatingCapacity, equals(5));
//       expect(car.transmissionType, equals("Automatic"));
//       expect(car.fuelType, equals("Petrol"));
//       expect(car.currentOdometerReading, equals(20000));
//       expect(car.availability, equals(true));
//       expect(car.currentStatus, equals("Available"));
//       expect(car.approvalStatus, equals(false));
//       expect(car.ownerId, equals("32"));
//     });
//
//     test('CarModel.toJson should generate correct API request format', () {
//       final car = CarModel(
//         id: 1,
//         model: "Toyota Corolla",
//         brand: "Toyota",
//         carType: "Sedan",
//         carCategory: "Economy",
//         plateNumber: "ACB153",
//         year: 2021,
//         color: "Red",
//         seatingCapacity: 5,
//         transmissionType: "Automatic",
//         fuelType: "Petrol",
//         currentOdometerReading: 5000,
//         availability: true,
//         currentStatus: "Available",
//         approvalStatus: false,
//         rentalOptions: RentalOptions(
//           availableWithoutDriver: false,
//           availableWithDriver: false,
//           dailyRentalPrice: 0.0,
//         ),
//         ownerId: "32",
//       );
//
//       final json = car.toJson();
//
//       expect(json["model"], equals("Toyota Corolla"));
//       expect(json["brand"], equals("Toyota"));
//       expect(json["car_type"], equals("Sedan"));
//       expect(json["car_category"], equals("Economy"));
//       expect(json["plate_number"], equals("ACB153"));
//       expect(json["year"], equals(2021));
//       expect(json["color"], equals("Red"));
//       expect(json["seating_capacity"], equals(5));
//       expect(json["transmission_type"], equals("Automatic"));
//       expect(json["fuel_type"], equals("Petrol"));
//       expect(json["current_odometer_reading"], equals(5000));
//     });
//
//     test('RentalOptions.fromJson should handle missing fields gracefully', () {
//       final emptyJson = {};
//       final rentalOptions = RentalOptions.fromJson(emptyJson);
//
//       expect(rentalOptions.availableWithoutDriver, equals(false));
//       expect(rentalOptions.availableWithDriver, equals(false));
//       expect(rentalOptions.dailyRentalPrice, isNull);
//     });
//   });
// }
