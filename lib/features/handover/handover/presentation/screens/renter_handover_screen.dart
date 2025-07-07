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
  bool _isPaymentConfirmed = false;

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
                    // Progress indicator for steps
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStepCircle(context, 1, 'Car Image', model.carImagePath != null),
                            _buildStepDivider(),
                            _buildStepCircle(context, 2, 'Odometer', model.odometerReading != null),
                            _buildStepDivider(),
                            _buildStepCircle(context, 3, 'Payment', model.isPaymentCompleted || _isPaymentConfirmed),
                            _buildStepDivider(),
                            _buildStepCircle(context, 4, 'Contract', model.isContractConfirmed),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Car Image Upload
                    Text('1. Upload Car Image at Pickup', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final picked = await _picker.pickImage(source: ImageSource.camera);
                          if (picked != null) {
                            context.read<RenterHandoverCubit>().uploadCarImage(picked.path);
                          }
                        },
                        child: Container(
                          height: 170,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                            color: Colors.grey[50],
                          ),
                          child: model.carImagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(model.carImagePath!),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt, size: 48, color: Colors.grey[500]),
                                    const SizedBox(height: 8),
                                    Text('Tap to capture car image', style: TextStyle(color: Colors.grey[600])),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Odometer
                    Text('2. Current Odometer Reading', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
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
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
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
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[100],
                                ),
                                child: model.odometerImagePath != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          File(model.odometerImagePath!),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.camera_alt, size: 32, color: Colors.grey[500]),
                                          const SizedBox(height: 4),
                                          Text('Odometer', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Payment
                    Text('3. Payment Confirmation', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: model.isPaymentCompleted
                            ? Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Text('Payment Completed', style: TextStyle(color: Colors.green)),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: _isPaymentConfirmed,
                                    onChanged: (val) {
                                      setState(() {
                                        _isPaymentConfirmed = val ?? false;
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      (widget.notification.data?['paymentMethod'] == 'cash')
                                          ? 'I confirm that I have paid the remaining amount of the trip to the owner.'
                                          : 'I confirm and sign to agree to withdraw the remaining amount for the trip once I click Send handover',
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${widget.notification.data?['remainingAmount']?.toStringAsFixed(2) ?? '--'} EGP',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Contract Confirmation
                    Text('4. Contract Confirmation', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: CheckboxListTile(
                        value: model.isContractConfirmed,
                        onChanged: (val) {
                          context.read<RenterHandoverCubit>().confirmContract(val ?? false);
                        },
                        title: const Text('I confirm I have signed the contract'),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      ),
                    ),
                    const SizedBox(height: 36),
                    // Send Handover Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: (model.carImagePath != null &&
                                model.odometerReading != null &&
                                model.isContractConfirmed &&
                                // model.isPaymentCompleted &&
                                state.ownerHandoverSent &&
                                state is! RenterHandoverSending)
                            ? () => context.read<RenterHandoverCubit>().sendHandover()
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: state is RenterHandoverSending
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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

  Widget _buildStepCircle(BuildContext context, int step, String label, bool completed) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: completed ? Colors.green : Colors.grey[300],
          child: Icon(
            completed ? Icons.check : Icons.circle,
            color: completed ? Colors.white : Colors.grey[600],
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: completed ? Colors.green : Colors.grey[600], fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Container(
      width: 28,
      height: 2,
      color: Colors.grey[300],
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