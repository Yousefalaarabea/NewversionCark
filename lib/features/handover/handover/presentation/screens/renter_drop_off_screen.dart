import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../config/routes/screens_name.dart';
import '../../../../../config/themes/app_colors.dart';
import '../../../../../core/widgets/custom_elevated_button.dart';
import '../cubits/renter_drop_off_cubit.dart';
import '../widgets/excess_charges_widget.dart';
import '../widgets/handover_notes_widget.dart';
import '../widgets/image_upload_widget.dart';

class RenterDropOffScreen extends StatefulWidget {
  final String tripId;
  final String carId;
  final String renterId;
  final String ownerId;
  final String paymentMethod;

  const RenterDropOffScreen({
    super.key,
    required this.tripId,
    required this.carId,
    required this.renterId,
    required this.ownerId,
    required this.paymentMethod,
  });

  @override
  State<RenterDropOffScreen> createState() => _RenterDropOffScreenState();
}

class _RenterDropOffScreenState extends State<RenterDropOffScreen> {
  final TextEditingController _odometerController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  String? _carImagePath;
  String? _odometerImagePath;
  int? _finalOdometerReading;
  String? _renterNotes;

  @override
  void initState() {
    super.initState();
    _initializeHandover();
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeHandover() {
    context.read<RenterDropOffCubit>().initializeHandover(
      tripId: widget.tripId,
      carId: widget.carId,
      renterId: widget.renterId,
      ownerId: widget.ownerId,
      paymentMethod: widget.paymentMethod,
    );
  }

  Future<void> _pickImage(bool isCarImage) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      
      if (image != null) {
        if (isCarImage) {
          await context.read<RenterDropOffCubit>().uploadCarImage(File(image.path));
        } else {
          await context.read<RenterDropOffCubit>().uploadOdometerImage(File(image.path));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture image: $e')),
      );
    }
  }

  void _calculateExcessCharges() {
    if (_finalOdometerReading == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter odometer reading first')),
      );
      return;
    }

    // Mock values - in real app these would come from trip data
    context.read<RenterDropOffCubit>().calculateExcessCharges(
      agreedKilometers: 200,
      agreedHours: 24,
      extraKmRate: 0.5,
      extraHourRate: 10.0,
    );
  }

  void _processPayment() {
    context.read<RenterDropOffCubit>().processPayment();
  }

  void _completeHandover() {
    context.read<RenterDropOffCubit>().completeRenterHandover();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Drop-Off'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocConsumer<RenterDropOffCubit, RenterDropOffState>(
        listener: (context, state) {
          if (state is RenterDropOffError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is RenterDropOffCarImageUploaded) {
            setState(() {
              _carImagePath = state.carImagePath;
            });
          } else if (state is RenterDropOffOdometerImageUploaded) {
            setState(() {
              _odometerImagePath = state.odometerImagePath;
            });
          } else if (state is RenterDropOffOdometerReadingSet) {
            setState(() {
              _finalOdometerReading = state.odometerReading;
            });
          } else if (state is RenterDropOffExcessCalculated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Excess charges calculated successfully')),
            );
          } else if (state is RenterDropOffPaymentProcessed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment processed successfully')),
            );
          } else if (state is RenterDropOffNotesAdded) {
            setState(() {
              _renterNotes = state.notes;
            });
          } else if (state is RenterDropOffCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Car drop-off completed successfully')),
            );
            // Navigate to owner drop-off screen
            Navigator.pushReplacementNamed(
              context,
              ScreensName.ownerDropOffScreen,
              arguments: {
                'handoverData': state.handoverData,
                'logs': state.logs,
              },
            );
          }
        },
        builder: (context, state) {
          if (state is RenterDropOffLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.directions_car, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Car Drop-Off Process',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Complete the following steps to return the car',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Step 1: Upload car image
                _buildStepCard(
                  title: '1. Car Image After Trip',
                  subtitle: 'Take a photo of the car to document its condition',
                  icon: Icons.camera_alt,
                  isCompleted: _carImagePath != null,
                  child: ImageUploadWidget(
                    imagePath: _carImagePath,
                    onImagePicked: (source) => _pickImage(true),
                    title: 'Car Image',
                  ),
                ),
                const SizedBox(height: 16),

                // Step 2: Upload odometer image
                _buildStepCard(
                  title: '2. Odometer Reading Photo',
                  subtitle: 'Take a photo of the odometer reading',
                  icon: Icons.speed,
                  isCompleted: _odometerImagePath != null,
                  child: ImageUploadWidget(
                    imagePath: _odometerImagePath,
                    onImagePicked: (source) => _pickImage(false),
                    title: 'Odometer Image',
                  ),
                ),
                const SizedBox(height: 16),

                // Step 3: Enter odometer reading
                _buildStepCard(
                  title: '3. Final Odometer Reading',
                  subtitle: 'Enter the current odometer reading',
                  icon: Icons.edit,
                  isCompleted: _finalOdometerReading != null,
                  child: TextFormField(
                    controller: _odometerController,
                    decoration: const InputDecoration(
                      labelText: 'Odometer Reading (km)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.speed),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final reading = int.tryParse(value);
                      if (reading != null) {
                        context.read<RenterDropOffCubit>().setFinalOdometerReading(reading);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Step 4: Calculate excess charges
                if (_finalOdometerReading != null)
                  _buildStepCard(
                    title: '4. Calculate Excess Charges',
                    subtitle: 'Calculate any additional charges if applicable',
                    icon: Icons.calculate,
                    isCompleted: state is RenterDropOffExcessCalculated || 
                                state is RenterDropOffPaymentProcessed ||
                                state is RenterDropOffCompleted,
                    child: Column(
                      children: [
                        CustomElevatedButton(
                          onPressed: _calculateExcessCharges,
                          text: 'Calculate Excess Charges',
                        ),
                        if (state is RenterDropOffExcessCalculated) ...[
                          const SizedBox(height: 16),
                          ExcessChargesWidget(
                            excessCharges: state.excessCharges,
                            paymentMethod: widget.paymentMethod,
                          ),
                          const SizedBox(height: 16),
                          CustomElevatedButton(
                            onPressed: _processPayment,
                            text: 'Process Payment',
                          ),
                        ],
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Step 5: Add notes
                _buildStepCard(
                  title: '5. Add Notes',
                  subtitle: 'Add any additional notes or comments',
                  icon: Icons.note_add,
                  isCompleted: _renterNotes != null && _renterNotes!.isNotEmpty,
                  child: HandoverNotesWidget(
                    title: 'Renter Notes',
                    initialValue: _renterNotes,
                    onNotesChanged: (notes) {
                      context.read<RenterDropOffCubit>().addRenterNotes(notes);
                    },
                    hintText: 'Add your notes about the trip or car condition...',
                  ),
                ),
                const SizedBox(height: 24),

                // Complete handover button
                if (_canCompleteHandover(state))
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8),
                    child: ElevatedButton(
                      onPressed: _completeHandover,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Complete Drop-Off',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? AppColors.green : AppColors.primary.withOpacity(0.15),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? AppColors.green 
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isCompleted ? [
                    BoxShadow(
                      color: AppColors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Icon(
                  isCompleted ? Icons.check : icon,
                  color: isCompleted ? Colors.white : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? AppColors.green : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  bool _canCompleteHandover(RenterDropOffState state) {
    return _carImagePath != null &&
           _odometerImagePath != null &&
           _finalOdometerReading != null &&
           (state is RenterDropOffExcessCalculated ||
            state is RenterDropOffPaymentProcessed ||
            state is RenterDropOffCompleted);
  }
} 