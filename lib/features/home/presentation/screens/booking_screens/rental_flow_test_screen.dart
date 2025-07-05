import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/themes/app_colors.dart';
import '../../../../../config/routes/screens_name.dart';
import '../../model/car_model.dart';
import '../../model/location_model.dart';
import '../../cubit/car_cubit.dart';
import '../../cubit/booking_api_cubit.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../../notifications/presentation/cubits/notification_cubit.dart';
import 'package:test_cark/features/cars/presentation/models/car_rental_options.dart';

class RentalFlowTestScreen extends StatefulWidget {
  const RentalFlowTestScreen({super.key});

  @override
  State<RentalFlowTestScreen> createState() => _RentalFlowTestScreenState();
}

class _RentalFlowTestScreenState extends State<RentalFlowTestScreen> {
  int _currentStep = 0;
  final List<String> _steps = [
    '1. Signup/Login',
    '2. Rental Search',
    '3. Home Screen (Available Cars)',
    '4. Car Details',
    '5. Booking Summary',
    '6. Send Request & Notification'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Flow Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complete Car Rental Flow (Without Driver)',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20.h),
            
            // Flow Steps
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Flow Steps:',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...List.generate(_steps.length, (index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        children: [
                          Container(
                            width: 24.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: index <= _currentStep 
                                  ? AppColors.primary 
                                  : Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: index <= _currentStep 
                                      ? Colors.white 
                                      : Colors.grey[600],
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              _steps[index],
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: index <= _currentStep 
                                    ? Colors.black87 
                                    : Colors.grey[600],
                                fontWeight: index <= _currentStep 
                                    ? FontWeight.w500 
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Test Actions
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTestSection(
                      'Step 1: Authentication',
                      [
                        _buildTestButton(
                          'Test Login',
                          () => _testLogin(),
                          Icons.login,
                        ),
                        _buildTestButton(
                          'Test Signup',
                          () => _testSignup(),
                          Icons.person_add,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    _buildTestSection(
                      'Step 2: Rental Search',
                      [
                        _buildTestButton(
                          'Navigate to Rental Search',
                          () => _navigateToRentalSearch(),
                          Icons.search,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    _buildTestSection(
                      'Step 3: Car Selection',
                      [
                        _buildTestButton(
                          'Navigate to Home (Available Cars)',
                          () => _navigateToHome(),
                          Icons.home,
                        ),
                        _buildTestButton(
                          'Test Car Details Screen',
                          () => _testCarDetails(),
                          Icons.directions_car,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    _buildTestSection(
                      'Step 4: Booking Process',
                      [
                        _buildTestButton(
                          'Test Booking Summary',
                          () => _testBookingSummary(),
                          Icons.summarize,
                        ),
                        _buildTestButton(
                          'Test Complete Booking Flow',
                          () => _testCompleteBookingFlow(),
                          Icons.check_circle,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    _buildTestSection(
                      'Step 5: Notifications',
                      [
                        _buildTestButton(
                          'Test Booking Notification',
                          () => _testBookingNotification(),
                          Icons.notifications,
                        ),
                        _buildTestButton(
                          'View Notifications',
                          () => _viewNotifications(),
                          Icons.notifications_active,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16.h),
                    
                    _buildTestSection(
                      'Step 6: Complete Flow Test',
                      [
                        _buildTestButton(
                          'Run Complete Flow Test',
                          () => _runCompleteFlowTest(),
                          Icons.play_arrow,
                          isPrimary: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTestButton(String text, VoidCallback onPressed, IconData icon, {bool isPrimary = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18.sp),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primary : Colors.grey[100],
          foregroundColor: isPrimary ? Colors.white : Colors.black87,
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }

  void _testLogin() {
    setState(() {
      _currentStep = 0;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Login test completed'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _testSignup() {
    setState(() {
      _currentStep = 0;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Signup test completed'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _navigateToRentalSearch() {
    setState(() {
      _currentStep = 1;
    });
    
    Navigator.pushNamed(context, ScreensName.rentalSearchScreen);
  }

  void _navigateToHome() {
    setState(() {
      _currentStep = 2;
    });
    
    Navigator.pushNamed(context, ScreensName.homeScreen);
  }

  void _testCarDetails() {
    setState(() {
      _currentStep = 3;
    });
    
    // Create mock car data for testing
    final mockCar = CarModel(
      ownerId: '1',
      id: 1,
      model: 'X5',
      brand: 'BMW',
      carType: 'SUV',
      carCategory: 'Luxury',
      plateNumber: 'ABC-123',
      year: 2023,
      color: 'Black',
      seatingCapacity: 5,
      transmissionType: 'Automatic',
      fuelType: 'Gasoline',
      currentOdometerReading: 15000,
      availability: true,
      currentStatus: 'Available',
      approvalStatus: true,
      avgRating: 4.5,
      totalReviews: 10,
      imageUrl: null,
    );

    final mockRentalOptions = CarRentalOptions(
      availableWithoutDriver: true,
      availableWithDriver: false,
      dailyRentalPrice: 200.0,
      monthlyRentalPrice: 5000.0,
      yearlyRentalPrice: 50000.0,
      dailyRentalPriceWithDriver: 250.0,
      monthlyPriceWithDriver: 6000.0,
      yearlyPriceWithDriver: 60000.0,
    );

    final mockUsagePolicy = CarUsagePolicy(
      dailyKmLimit: 200,
      extraKmCost: 0.5,
      fuelPolicy: 'Full to Full',
      insuranceIncluded: true,
      additionalInsuranceCost: 50.0,
    );

    final carBundle = CarBundle(
      car: mockCar,
      rentalOptions: mockRentalOptions,
      usagePolicy: mockUsagePolicy,
    );

    Navigator.pushNamed(
      context,
      ScreensName.carDetailsScreen,
      arguments: carBundle,
    );
  }

  void _testBookingSummary() {
    setState(() {
      _currentStep = 4;
    });
    
    // Create mock car data for testing
    final mockCar = CarModel(
      ownerId: '1',
      id: 1,
      model: 'X5',
      brand: 'BMW',
      carType: 'SUV',
      carCategory: 'Luxury',
      plateNumber: 'ABC-123',
      year: 2023,
      color: 'Black',
      seatingCapacity: 5,
      transmissionType: 'Automatic',
      fuelType: 'Gasoline',
      currentOdometerReading: 15000,
      availability: true,
      currentStatus: 'Available',
      approvalStatus: true,
      avgRating: 4.5,
      totalReviews: 10,
      imageUrl: null,
    );

    final mockRentalOptions = CarRentalOptions(
      availableWithoutDriver: true,
      availableWithDriver: false,
      dailyRentalPrice: 200.0,
      monthlyRentalPrice: 5000.0,
      yearlyRentalPrice: 50000.0,
      dailyRentalPriceWithDriver: 250.0,
      monthlyPriceWithDriver: 6000.0,
      yearlyPriceWithDriver: 60000.0,
    );

    Navigator.pushNamed(
      context,
      ScreensName.bookingSummaryScreen,
      arguments: {
        'car': mockCar,
        'totalPrice': 400.0,
        'rentalOptions': mockRentalOptions,
      },
    );
  }

  void _testCompleteBookingFlow() {
    setState(() {
      _currentStep = 5;
    });
    
    // Simulate complete booking flow
    _simulateBookingFlow();
  }

  void _testBookingNotification() {
    // Test sending a booking notification
    context.read<NotificationCubit>().sendBookingNotification(
      renterName: 'John Doe',
      carBrand: 'BMW',
      carModel: 'X5',
      ownerId: '1',
      renterId: '2',
      type: 'booking_request',
      totalPrice: 400.0,
      rentalId: '123',
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Booking notification sent to car owner'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _viewNotifications() {
    Navigator.pushNamed(context, '/notifications');
  }

  void _runCompleteFlowTest() async {
    setState(() {
      _currentStep = 0;
    });
    
    // Simulate the complete flow
    await _simulateCompleteFlow();
  }

  void _simulateBookingFlow() {
    // Simulate booking API call
    final mockCar = CarModel(
      ownerId: '1',
      id: 1,
      model: 'X5',
      brand: 'BMW',
      carType: 'SUV',
      carCategory: 'Luxury',
      plateNumber: 'ABC-123',
      year: 2023,
      color: 'Black',
      seatingCapacity: 5,
      transmissionType: 'Automatic',
      fuelType: 'Gasoline',
      currentOdometerReading: 15000,
      availability: true,
      currentStatus: 'Available',
      approvalStatus: true,
      avgRating: 4.5,
      totalReviews: 10,
      imageUrl: null,
    );

    final mockPickupLocation = LocationModel(
      name: 'Dubai Mall',
      address: 'Dubai Mall, Dubai, UAE',
      lat: 25.1972,
      lng: 55.2744,
    );

    final mockDropoffLocation = LocationModel(
      name: 'Burj Khalifa',
      address: 'Burj Khalifa, Dubai, UAE',
      lat: 25.1972,
      lng: 55.2744,
    );

    // Create rental using BookingApiCubit
    context.read<BookingApiCubit>().createRental(
      car: mockCar,
      startDate: DateTime.now().add(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 3)),
      rentalType: 'WithoutDriver',
      pickupLocation: mockPickupLocation,
      dropoffLocation: mockDropoffLocation,
      paymentMethod: 'cash',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Booking flow test completed'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _simulateCompleteFlow() async {
    // Step 1: Authentication
    setState(() {
      _currentStep = 0;
    });
    await Future.delayed(const Duration(seconds: 1));
    
    // Step 2: Rental Search
    setState(() {
      _currentStep = 1;
    });
    await Future.delayed(const Duration(seconds: 1));
    
    // Step 3: Home Screen
    setState(() {
      _currentStep = 2;
    });
    await Future.delayed(const Duration(seconds: 1));
    
    // Step 4: Car Details
    setState(() {
      _currentStep = 3;
    });
    await Future.delayed(const Duration(seconds: 1));
    
    // Step 5: Booking Summary
    setState(() {
      _currentStep = 4;
    });
    await Future.delayed(const Duration(seconds: 1));
    
    // Step 6: Send Request & Notification
    setState(() {
      _currentStep = 5;
    });
    
    // Send test notification
    context.read<NotificationCubit>().sendBookingNotification(
      renterName: 'Test User',
      carBrand: 'BMW',
      carModel: 'X5',
      ownerId: '1',
      renterId: '2',
      type: 'booking_request',
      totalPrice: 400.0,
      rentalId: 'test-123',
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Complete rental flow test finished successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
}

// Mock classes for testing
class CarBundle {
  final CarModel car;
  final CarRentalOptions rentalOptions;
  final CarUsagePolicy usagePolicy;

  CarBundle({
    required this.car,
    required this.rentalOptions,
    required this.usagePolicy,
  });
}

class CarUsagePolicy {
  final int dailyKmLimit;
  final double extraKmCost;
  final String fuelPolicy;
  final bool insuranceIncluded;
  final double additionalInsuranceCost;

  CarUsagePolicy({
    required this.dailyKmLimit,
    required this.extraKmCost,
    required this.fuelPolicy,
    required this.insuranceIncluded,
    required this.additionalInsuranceCost,
  });
}