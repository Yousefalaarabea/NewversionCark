import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../config/routes/screens_name.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../../home/presentation/model/car_model.dart';
import '../cubits/renter_handover_cubit.dart';
import '../models/renter_handover_model.dart';

class RenterHandoverScreen extends StatefulWidget {
  const RenterHandoverScreen({Key? key}) : super(key: key);

  @override
  State<RenterHandoverScreen> createState() => _RenterHandoverScreenState();
}

class _RenterHandoverScreenState extends State<RenterHandoverScreen> {
  final TextEditingController _odometerController = TextEditingController();
  bool _contractConfirmed = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<RenterHandoverCubit>().fetchHandoverStatus();
  }

  @override
  void dispose() {
    _odometerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RenterHandoverCubit, RenterHandoverState>(
      listener: (context, state) {
        if (state is RenterHandoverFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        } else if (state is RenterHandoverSuccess) {
          // Send notification to owner that renter handover is completed
          _notifyOwnerRenterHandoverCompleted();
          
          Navigator.pushReplacementNamed(
            context,
            ScreensName.tripManagementScreen,
            arguments: {
              'car': CarModel.mock(),
              'totalPrice': 1000.0,
              'stops': [],
            },
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Renter Pick-Up Handover'),
        ),
        body: BlocBuilder<RenterHandoverCubit, RenterHandoverState>(
          builder: (context, state) {
            if (state is RenterHandoverLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is RenterHandoverStatusLoaded) {
              if (!state.ownerHandoverSent) {
                return const Center(
                  child: Text('Waiting for owner to send handover...'),
                );
              }
              final model = state.model;
              _odometerController.text = model.odometerReading?.toString() ?? '';
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Car Image Upload
                    Text('Upload Car Image at Pickup', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await _picker.pickImage(source: ImageSource.camera);
                        if (picked != null) {
                          context.read<RenterHandoverCubit>().uploadCarImage(picked.path);
                        }
                      },
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: model.carImagePath != null
                            ? Image.file(
                                File(model.carImagePath!),
                                fit: BoxFit.cover,
                              )
                            : const Center(child: Icon(Icons.camera_alt, size: 48)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Odometer
                    Text('Current Odometer Reading', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _odometerController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Enter odometer reading',
                            ),
                            onChanged: (val) {
                              final odometer = int.tryParse(val);
                              if (odometer != null) {
                                context.read<RenterHandoverCubit>().updateOdometer(odometer);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () async {
                            final picked = await _picker.pickImage(source: ImageSource.camera);
                            if (picked != null) {
                              context.read<RenterHandoverCubit>().uploadOdometerImage(picked.path);
                            }
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: model.odometerImagePath != null
                                ? Image.file(
                                    File(model.odometerImagePath!),
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.camera_alt, size: 32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Payment
                    if (!model.isPaymentCompleted) ...[
                      Text('Pay Remaining Amount', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: state is RenterHandoverPaymentProcessing
                            ? null
                            : () => context.read<RenterHandoverCubit>().payRemainingAmount(),
                        child: state is RenterHandoverPaymentProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Pay with Card (Paymob Test)'),
                      ),
                    ] else ...[
                      Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('Payment Completed', style: TextStyle(color: Colors.green)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Contract Confirmation
                    CheckboxListTile(
                      value: model.isContractConfirmed,
                      onChanged: (val) {
                        context.read<RenterHandoverCubit>().confirmContract(val ?? false);
                      },
                      title: const Text('I confirm I have signed the contract'),
                    ),
                    const SizedBox(height: 32),
                    // Send Handover Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (model.carImagePath != null &&
                                model.odometerReading != null &&
                                model.isContractConfirmed &&
                                model.isPaymentCompleted &&
                                state.ownerHandoverSent &&
                                state is! RenterHandoverSending)
                            ? () => context.read<RenterHandoverCubit>().sendHandover()
                            : null,
                        child: state is RenterHandoverSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Send Handover'),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Future<void> _notifyOwnerRenterHandoverCompleted() async {
    try {
      // Get current user (renter)
      final authCubit = context.read<AuthCubit>();
      final currentUser = authCubit.userModel;
      
      if (currentUser == null) {
        throw Exception('User not found');
      }

      // Get the latest booking request for this renter
      final bookingRequestsQuery = await FirebaseFirestore.instance
          .collection('booking_requests')
          .where('renterId', isEqualTo: currentUser.id)
          .where('status', isEqualTo: 'owner_handover_completed')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (bookingRequestsQuery.docs.isNotEmpty) {
        final bookingData = bookingRequestsQuery.docs.first.data();
        final ownerId = bookingData['ownerId'] as String?;
        final carBrand = bookingData['carBrand'] as String? ?? '';
        final carModel = bookingData['carModel'] as String? ?? '';
        final renterName = '${currentUser.firstName} ${currentUser.lastName}';

        if (ownerId != null) {
          // Send notification to owner that renter has completed handover
          await NotificationService().sendRenterHandoverCompletedNotification(
            ownerId: ownerId,
            renterName: renterName,
            carBrand: carBrand,
            carModel: carModel,
          );

          // Update booking status to 'trip_started'
          await FirebaseFirestore.instance
              .collection('booking_requests')
              .doc(bookingRequestsQuery.docs.first.id)
              .update({
            'status': 'trip_started',
            'renterHandoverCompletedAt': DateTime.now().toIso8601String(),
            'tripStartedAt': DateTime.now().toIso8601String(),
          });
          
          print('Renter handover notification sent to owner: $ownerId');
        }
      } else {
        print('No booking request found for renter: ${currentUser.id}');
      }
    } catch (e) {
      print('Error notifying owner: $e');
      // Don't throw the error to avoid crashing the app
    }
  }
}

class RenterHandoverConfirmationScreen extends StatelessWidget {
  const RenterHandoverConfirmationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '✅ Renter Handover Confirmed',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      ScreensName.tripDetailsScreen,
                    );
                  },
                  child: const Text('View Trip Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 