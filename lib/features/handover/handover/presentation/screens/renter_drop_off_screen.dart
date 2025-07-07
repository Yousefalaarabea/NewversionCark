import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../config/routes/screens_name.dart';
import '../../../../../config/themes/app_colors.dart';
import '../../../../../core/widgets/custom_elevated_button.dart';
import '../cubits/renter_drop_off_cubit.dart';
import '../widgets/excess_charges_widget.dart';
import '../widgets/handover_notes_widget.dart';
import '../widgets/image_upload_widget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../../../core/api_service.dart';

class RenterDropOffScreen extends StatefulWidget {
  // final String tripId;
  final String carId;
  // final String renterId;
  final String ownerId;
  final String rentalId;
  final String paymentMethod;

  const RenterDropOffScreen({
    super.key,
    // required this.tripId,
    required this.carId,
    // required this.renterId,
    required this.ownerId,
    required this.rentalId,
    required this.paymentMethod,
  });

  @override
  State<RenterDropOffScreen> createState() => _RenterDropOffScreenState();
}

class _RenterDropOffScreenState extends State<RenterDropOffScreen> {
  final TextEditingController _odometerController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  double _ownerRating = 5;
  double _carRating = 5;
  final TextEditingController _ownerNotesController = TextEditingController();
  final TextEditingController _carNotesController = TextEditingController();

  String? _carImagePath;
  String? _odometerImagePath;
  int? _finalOdometerReading;
  String? _renterNotes;
  bool? _isPaymentConfirmedExcessCharges = false;

  @override
  void initState() {
    super.initState();
    _initializeHandover();
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _notesController.dispose();
    _ownerNotesController.dispose();
    _carNotesController.dispose();
    super.dispose();
  }

  void _initializeHandover() {
    context.read<RenterDropOffCubit>().initializeHandover(
          // tripId: widget.tripId,
          carId: widget.carId,
          // renterId: widget.renterId,
          ownerId: widget.ownerId,
          rentalId: widget.rentalId,
          paymentMethod: widget.paymentMethod,
        );
  }

  // Future<void> _pickImage(bool isCarImage) async {
  //   try {
  //     final ImagePicker picker = ImagePicker();
  //     final XFile? image = await picker.pickImage(source: ImageSource.camera);
  //
  //     if (image != null) {
  //       if (isCarImage) {
  //         await context
  //             .read<RenterDropOffCubit>()
  //             .uploadCarImage(File(image.path));
  //       } else {
  //         await context
  //             .read<RenterDropOffCubit>()
  //             .uploadOdometerImage(File(image.path));
  //       }
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to capture image: $e')),
  //     );
  //   }
  // }
  Future<void> _pickImage(bool isCarImage) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (image != null) {
        // ✅ خطوة الضغط وتقليل الحجم
        // يمكنك تعديل الجودة (quality) والأبعاد (minWidth, minHeight) حسب حاجتك
        final filePath = image.path;
        final targetPath = '${image.path}_compressed.jpg'; // مسار جديد للملف المضغوط

        File? compressedImageFile;

        // ضغط الصورة
        final result = await FlutterImageCompress.compressAndGetFile(
          filePath,
          targetPath,
          quality: 70, // جودة الصورة من 0-100. جرب 70 أو 80.
          minWidth: 1024, // أقصى عرض (بالبكسل). جرب 1024 أو 800.
          minHeight: 768, // أقصى ارتفاع (بالبكسل).
          format: CompressFormat.jpeg,
        );

        if (result != null) {
          compressedImageFile = File(result.path);
        } else {
          // لو الضغط فشل، ممكن تستخدم الصورة الأصلية أو تدي رسالة خطأ
          print('Image compression failed, using original image.');
          compressedImageFile = File(image.path);
        }

        if (compressedImageFile != null) {
          if (isCarImage) {
            await context
                .read<RenterDropOffCubit>()
                .uploadCarImage(compressedImageFile); // استخدم الملف المضغوط
          } else {
            await context
                .read<RenterDropOffCubit>()
                .uploadOdometerImage(compressedImageFile); // استخدم الملف المضغوط
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture or compress image: $e')),
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

    print('Triggering calculateExcessCharges');
    print('rentalId: \\${widget.rentalId}');
    print('currentOdometer: \\${_finalOdometerReading}');
    context.read<RenterDropOffCubit>().calculateExcessCharges(
      rentalId: widget.rentalId,
      currentOdometer: _finalOdometerReading!.toDouble(),
      context: context,
    );
  }

  void _processPayment() {
    context.read<RenterDropOffCubit>().processPayment();

  }

  void _completeHandover() {
    // Check all required steps before submission
    if (_carImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture a photo of the car after the trip.')),
      );
      return;
    }
    if (_odometerImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture a photo of the final odometer.')),
      );
      return;
    }
    if (_finalOdometerReading == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the final odometer reading.')),
      );
      return;
    }
    final cubit = context.read<RenterDropOffCubit>();
    final state = cubit.state;
    if (!(state is RenterDropOffExcessCalculated ||
        state is RenterDropOffPaymentProcessed ||
        state is RenterDropOffCompleted)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please calculate excess charges before submitting.')),
      );
      return;
    }
    // If everything is fine, submit the drop-off
    cubit.completeRenterHandover();
  }

  // --- New: Separate API calls for rating ---
  Future<bool> _sendOwnerRating(String rentalId) async {
    try {
      final apiService = ApiService();
      final ownerRes = await apiService.postWithToken(
        '/feedback/rate/owner/',
        {
          'rental_type': 'selfdriverental',
          'rental_id': int.tryParse(rentalId) ?? rentalId,
          'rating': _ownerRating.round(),
          'notes': _ownerNotesController.text,
        },
      );
      if (ownerRes.statusCode != 200 && ownerRes.statusCode != 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to rate owner:  ${ownerRes.statusCode}')),
        );
        return false;
      }
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while sending owner rating: $e')),
      );
      return false;
    }
  }

  Future<bool> _sendCarRating(String rentalId) async {
    try {
      final apiService = ApiService();
      final carRes = await apiService.postWithToken(
        '/feedback/rate/car/',
        {
          'rental_type': 'selfdriverental',
          'rental_id': int.tryParse(rentalId) ?? rentalId,
          'rating': _carRating.round(),
          'notes': _carNotesController.text,
        },
      );
      if (carRes.statusCode != 200 && carRes.statusCode != 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to rate car:  ${carRes.statusCode}')),
        );
        return false;
      }
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while sending car rating: $e')),
      );
      return false;
    }
  }

  // --- Remove old _showRatingDialog and _sendRatings ---

  // --- New: Show rating bottom sheet after drop-off ---
  void _showRatingBottomSheet(BuildContext context, String rentalId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Congratulations! The trip is finished', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 16),
                    const Text('Please rate the owner and the car'),
                    const SizedBox(height: 16),
                    const Text('Owner Rating'),
                    RatingBar.builder(
                      initialRating: _ownerRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setModalState(() => _ownerRating = rating);
                      },
                    ),
                    TextField(
                      controller: _ownerNotesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes about the owner',
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Car Rating'),
                    RatingBar.builder(
                      initialRating: _carRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setModalState(() => _carRating = rating);
                      },
                    ),
                    TextField(
                      controller: _carNotesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes about the car',
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final ownerSuccess = await _sendOwnerRating(rentalId);
                          final carSuccess = await _sendCarRating(rentalId);
                          if (ownerSuccess && carSuccess) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(content: Text('Ratings sent successfully!')),
                            );
                            Navigator.pushReplacementNamed(
                              this.context,
                              ScreensName.homeScreen,
                            );
                          }
                        },
                        child: const Text('Submit',style: TextStyle(color: Colors.white),),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
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
              const SnackBar(
                  content: Text('Excess charges calculated successfully')),
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
            _showRatingBottomSheet(context, widget.rentalId);
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
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primary.withOpacity(0.05)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.directions_car,
                            color: AppColors.primary, size: 28),
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
                        context
                            .read<RenterDropOffCubit>()
                            .setFinalOdometerReading(reading);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Step 4: Calculate excess charges
                _buildStepCard(
                  title: '4. Calculate Excess Charges',
                  subtitle: 'Calculate any additional charges if applicable',
                  icon: Icons.calculate,
                  isCompleted: state is RenterDropOffExcessCalculated ||
                      state is RenterDropOffPaymentProcessed ||
                      state is RenterDropOffCompleted,
                  child: (_finalOdometerReading != null)
                      ? Column(
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
                              Row(
                                children: [
                                  StatefulBuilder(
                                    builder: (context, setState) {
                                      return Checkbox(
                                        value: _isPaymentConfirmedExcessCharges ?? false,
                                        onChanged: (val) {
                                          setState(() {
                                            _isPaymentConfirmedExcessCharges = val ?? false;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                  Expanded(
                                    child: Text(
                                      'I confirm and sign to agree to withdraw the remaining amount for the trip once I click Send handover',
                                      style: TextStyle(fontSize: 15),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        )
                      : const Text('Please enter the odometer reading first.'),
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
                    hintText:
                        'Add your notes about the trip or car condition...',
                  ),
                ),
                const SizedBox(height: 24),

                // Complete handover button
                if (_canCompleteHandover(state))
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 5,left: 5,bottom: 5,right: 5),
                    child: ElevatedButton(
                      onPressed: _completeHandover,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
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
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
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
          color: isCompleted
              ? AppColors.green
              : AppColors.primary.withOpacity(0.15),
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
                  boxShadow: isCompleted
                      ? [
                          BoxShadow(
                            color: AppColors.green.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
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
                        color:
                            isCompleted ? AppColors.green : AppColors.primary,
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
