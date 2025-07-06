import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../config/routes/screens_name.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../../notifications/presentation/cubits/notification_cubit.dart';
import '../cubits/renter_handover_cubit.dart';
import '../../../../home/presentation/model/trip_details_model.dart';

class RenterHandoverScreen extends StatefulWidget {
  final int rentalId;
  final AppNotification notification;
  const RenterHandoverScreen({super.key, required this.rentalId, required this.notification} );

  @override
  State<RenterHandoverScreen> createState() => _RenterHandoverScreenState();
}

class _RenterHandoverScreenState extends State<RenterHandoverScreen> {
  final TextEditingController _odometerController = TextEditingController();
  final bool _contractConfirmed = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<RenterHandoverCubit>().setRentalId(widget.rentalId);
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
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('🎉 Trip Started'),
              content: const Text(
                'Congratulations! Your trip has officially started.\n\nYou will receive a notification with trip details shortly.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      ScreensName.homeScreen,
                      (route) => false,
                    );
                  },
                  child: const Text('Back to Home'),
                ),
              ],
            ),
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
                      const Row(
                        children: [
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

}

class RenterHandoverConfirmationScreen extends StatelessWidget {
  const RenterHandoverConfirmationScreen({super.key});

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