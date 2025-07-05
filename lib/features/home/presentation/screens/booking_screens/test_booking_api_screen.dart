import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../cubit/booking_api_cubit.dart';
import '../../model/car_model.dart';
import '../../model/location_model.dart';

class TestBookingApiScreen extends StatefulWidget {
  const TestBookingApiScreen({super.key});

  @override
  State<TestBookingApiScreen> createState() => _TestBookingApiScreenState();
}

class _TestBookingApiScreenState extends State<TestBookingApiScreen> {
  String? _result;

  @override
  void initState() {
    super.initState();
    // Check if we have a token
    _checkToken();
  }

  Future<void> _checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    setState(() {
      _result = token != null 
        ? '✅ Token found: ${token.substring(0, 50)}...'
        : '❌ No token found. Please login first.';
    });
  }

  void _showResult(String result) {
    setState(() {
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Booking API'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<BookingApiCubit, BookingApiState>(
        listener: (context, state) {
          if (state is BookingApiSuccess) {
            _showResult('✅ Booking created successfully!\n${state.data}');
          } else if (state is BookingApiRentalsLoaded) {
            _showResult('✅ User rentals loaded: ${state.rentals.length} rentals\n${state.rentals}');
          } else if (state is BookingApiError) {
            _showResult('❌ Error: ${state.message}');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () => _testCreateRental(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Test Create Rental'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _testGetUserRentals(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Test Get User Rentals'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _testGetRentalDetails(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Test Get Rental Details'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _testCalculateCosts(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Test Calculate Costs'),
              ),
              const SizedBox(height: 24),
              if (_result != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _result!.startsWith('✅') ? Colors.green.shade50 : Colors.red.shade50,
                    border: Border.all(
                      color: _result!.startsWith('✅') ? Colors.green : Colors.red,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _result!,
                    style: TextStyle(
                      color: _result!.startsWith('✅') ? Colors.green.shade800 : Colors.red.shade800,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _testCreateRental(BuildContext context) {
    // Create a mock car for testing
    final car = CarModel(
      ownerId: '1',
      id: 1,
      brand: 'Toyota',
      model: 'Camry',
      carType: 'Sedan',
      carCategory: 'Economy',
      plateNumber: 'ABC-123',
      year: 2022,
      color: 'White',
      seatingCapacity: 5,
      transmissionType: 'Automatic',
      fuelType: 'Gasoline',
      currentOdometerReading: 50000,
      availability: true,
      currentStatus: 'Available',
      approvalStatus: true,
      avgRating: 4.5,
      totalReviews: 10,
      imageUrl: 'https://example.com/car.jpg',
    );

    // Create mock locations
    final pickupLocation = LocationModel(
      name: 'Cairo, Egypt',
      address: 'Cairo, Egypt',
      lat: 30.0444,
      lng: 31.2357,
    );

    final dropoffLocation = LocationModel(
      name: 'Alexandria, Egypt',
      address: 'Alexandria, Egypt',
      lat: 31.2001,
      lng: 29.9187,
    );

    final cubit = context.read<BookingApiCubit>();
    cubit.createRental(
      car: car,
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 3)),
      rentalType: 'WithoutDriver',
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      paymentMethod: 'wallet',
    );
  }

  void _testGetUserRentals(BuildContext context) {
    final cubit = context.read<BookingApiCubit>();
    cubit.getUserRentals();
  }

  void _testGetRentalDetails(BuildContext context) {
    // You can modify this ID based on actual rental IDs from your system
    final cubit = context.read<BookingApiCubit>();
    cubit.getRentalDetails(1);
  }

  void _testCalculateCosts(BuildContext context) {
    final cubit = context.read<BookingApiCubit>();
    cubit.calculateRentalCosts(
      rentalId: 1,
      plannedKm: 150.0,
      totalWaitingMinutes: 30,
    );
  }
} 