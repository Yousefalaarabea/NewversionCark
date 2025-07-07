import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../../notifications/presentation/cubits/notification_cubit.dart';
import '../../model/car_model.dart';
import '../../model/location_model.dart';
import 'package:test_cark/config/routes/screens_name.dart';
import '../../cubit/car_cubit.dart';
import '../../model/trip_details_model.dart';
import '../../model/trip_with_driver_details_model.dart';

class DepositInputScreen extends StatefulWidget {
  final CarModel car;
  final double totalPrice;
  final List<LocationModel> stops;

  const DepositInputScreen({
    super.key,
    required this.car,
    required this.totalPrice,
    required this.stops,
  });

  @override
  State<DepositInputScreen> createState() => _DepositInputScreenState();
}

class _DepositInputScreenState extends State<DepositInputScreen> {
  final TextEditingController _depositController = TextEditingController();

  @override
  void dispose() {
    _depositController.dispose();
    super.dispose();
  }

  void _submitDeposit() async {
    final deposit = _depositController.text;
    if (deposit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your deposit.')),
      );
      return;
    }

    try {
      final authCubit = context.read<AuthCubit>();
      final currentUser = authCubit.userModel;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        // Navigate to login screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
              (route) => false,
        );
        return;
      }

      final renterId = currentUser.id.toString();
      final ownerId = widget.car.ownerId;
      final carName = '${widget.car.brand} ${widget.car.model}';

      // Send booking notification using the new notification system
      context.read<NotificationCubit>().sendBookingNotification(
        renterName: '${currentUser.firstName} ${currentUser.lastName}',
        carBrand: widget.car.brand,
        carModel: widget.car.model,
        ownerId: ownerId,
        renterId: renterId,
        type: 'booking_request',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deposit of $deposit EGP submitted! Booking request sent.'),
          backgroundColor: Colors.green,
        ),
      );

      // Get the current state from CarCubit to check driver selection
      final carCubit = context.read<CarCubit>();
      final withDriver = carCubit.state.withDriver;
      final selectedPaymentMethod = carCubit.state.selectedPaymentMethod ?? 'Unknown';
      final dateRange = carCubit.state.dateRange;
      final pickupStation = carCubit.state.pickupStation;
      final returnStation = carCubit.state.returnStation;
      final stops = carCubit.state.stops;

      // Debug: Print the values to see what's being passed
      print('DEBUG - Deposit Input Screen:');
      print('withDriver: $withDriver');
      print('pickupStation: ${pickupStation?.name}');
      print('returnStation: ${returnStation?.name}');
      print('dateRange: $dateRange');
      print('selectedPaymentMethod: $selectedPaymentMethod');

      // Navigate based on driver selection
      if (withDriver == true) {
        // With Driver - navigate to trip with driver confirmation screen
        final tripWithDriverDetails = TripWithDriverDetailsModel(
          car: widget.car,
          pickupLocation: pickupStation?.name ?? 'Unknown',
          dropoffLocation: returnStation?.name ?? 'Unknown',
          stops: stops,
          startDate: dateRange?.start ?? DateTime.now(),
          endDate: dateRange?.end ?? DateTime.now().add(const Duration(days: 3)),
          totalPrice: widget.totalPrice,
          paymentMethod: selectedPaymentMethod,
          renterName: '${currentUser.firstName} ${currentUser.lastName}' ?? 'Unknown',
          withDriver: true,
        );

        Navigator.pushReplacementNamed(
          context,
          ScreensName.tripWithDriverConfirmationScreen,
          arguments: tripWithDriverDetails,
        );
      } else if (withDriver == false) {
        // Without Driver - navigate to trip details confirmation screen
        final tripDetails = TripDetailsModel(
          car: widget.car,
          pickupLocation: pickupStation?.name ?? 'Unknown',
          dropoffLocation: returnStation?.name ?? 'Unknown',
          startDate: dateRange?.start ?? DateTime.now(),
          endDate: dateRange?.end ?? DateTime.now().add(const Duration(days: 3)),
          totalPrice: widget.totalPrice,
          paymentMethod: selectedPaymentMethod,
          renterName: '${currentUser.firstName} ${currentUser.lastName}' ?? 'Unknown', ownerName: '',
        );

        Navigator.pushReplacementNamed(
          context,
          ScreensName.tripDetailsConfirmationScreen,
          arguments: tripDetails,
        );
      } else {
        // No driver selection - show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a driver option before proceeding.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit Required'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                size: 40,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Please enter your deposit.',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _depositController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Deposit Amount',
                border: OutlineInputBorder(),
                prefixText: 'EGP',
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Deposit should be paid within 24 hours.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitDeposit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Submit Deposit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}