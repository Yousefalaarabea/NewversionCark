import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:latlong2/latlong.dart' as _carRating;
import 'package:latlong2/latlong.dart' as _renterRating;

import '../../../../../config/themes/app_colors.dart';
import '../../../../../core/api_service.dart';
import '../../../../../core/widgets/custom_elevated_button.dart';
import '../../../../notifications/presentation/cubits/notification_cubit.dart';
import '../cubits/owner_drop_off_cubit.dart';
import '../models/post_trip_handover_model.dart';
import '../models/handover_log_model.dart';
import '../widgets/excess_charges_widget.dart';
import '../widgets/handover_notes_widget.dart';

class OwnerDropOffScreen extends StatefulWidget {
  final Map<String, dynamic> notificationData;

  const OwnerDropOffScreen({
    super.key,
    required this.notificationData,
  });

  @override
  State<OwnerDropOffScreen> createState() => _OwnerDropOffScreenState();
}

class _OwnerDropOffScreenState extends State<OwnerDropOffScreen> {
  String? _ownerNotes;
  bool _contractConfirmed = false;
  File? _carImageFile;
  File? _odometerImageFile;
  late double _odometer = widget.notificationData['odometerValue'];
  final TextEditingController _renterNotesController = TextEditingController();

  //
  // late final Map<String, dynamic> data;
  // late final Map<String, dynamic> carDetails;
  // late final Map<String, dynamic> odometerDetails;
  // late final Map<String, dynamic> tripDetails;

  @override
  void initState() {
    super.initState();
    // Extract data from notificationData, fallback to empty maps if missing
    // data = widget.notificationData['data']  ? widget.notificationData['data'] : {};
    // carDetails = data['carDetails'] is Map<String, dynamic> ? data['carDetails'] : {};
    // odometerDetails = data['odometerDetails'] is Map<String, dynamic> ? data['odometerDetails'] : {};
    // tripDetails = data['tripDetails'] is Map<String, dynamic> ? data['tripDetails'] : {};
  }

  @override
  void dispose() {
    _renterNotesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isCarImage) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        if (isCarImage) {
          _carImageFile = File(image.path);
        } else {
          _odometerImageFile = File(image.path);
        }
      });
    }
  }

  void _confirmCashPayment() {
    context.read<OwnerDropOffCubit>().confirmCashPayment();
  }

  void _completeHandover() async {
    print('🟡 [OwnerDropOffScreen] Confirm Drop off pressed');
    if (_carImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture a photo of the car after the trip.')),
      );
      return;
    }
    if (_odometerImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture a photo of the final odometer.')),
      );
      return;
    }
    final odometerValue = _odometer;
    if (odometerValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid odometer value.')),
      );
      return;
    }
    final notes = _ownerNotes ?? '';
    final confirmExcessCash = false;
    final rentalId = widget.notificationData['rentalId'].toString();
    print('🟡 [OwnerDropOffScreen] Calling completeOwnerDropoffHandover with: carImageFile=${_carImageFile!.path}, odometerImageFile=${_odometerImageFile!.path}, odometerValue=$odometerValue, notes=$notes, confirmExcessCash=$confirmExcessCash, rentalId=$rentalId');
    context.read<OwnerDropOffCubit>().completeOwnerDropoffHandover(
      carImageFile: _carImageFile!,
      odometerImageFile: _odometerImageFile!,
      odometerValue: odometerValue,
      notes: notes,
      confirmExcessCash: confirmExcessCash,
      rentalId: rentalId,
    );
  }

  // --- BottomSheet for renter rating only after dropoff ---
  void _showRenterRatingBottomSheet(BuildContext context, String rentalId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        double _renterRating = 5;
        final TextEditingController _renterNotesController = TextEditingController();
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
                    const Text('Congratulations! Your trip completed 🎉', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 16),
                    const Text('Please rate the renter'),
                    const SizedBox(height: 16),
                    const Text('Renter Rating'),
                    RatingBar.builder(
                      initialRating: _renterRating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setModalState(() => _renterRating = rating);
                      },
                    ),
                    TextField(
                      controller: _renterNotesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes about the renter',
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final cubit = context.read<OwnerDropOffCubit>();
                          final renterSuccess = await cubit.sendRenterRating(
                            rentalId: rentalId,
                            rating: _renterRating.round(),
                            notes: _renterNotesController.text,
                          );
                          if (renterSuccess) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(content: Text('Renter rating sent successfully!')),
                            );
                            Navigator.pop(this.context); // رجوع للصفحة السابقة أو الرئيسية
                          }
                        },
                        child: const Text('Submit'),
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
    return BlocConsumer<OwnerDropOffCubit, OwnerDropOffState>(
      listener: (context, state) {
        if (state is OwnerDropOffCompletedGeneric) {
          print('✅ OwnerDropOffCompletedGeneric state received, showing rating bottom sheet');
          _showRenterRatingBottomSheet(context, widget.notificationData['rentalId'].toString());
        } else if (state is OwnerDropOffError) {
          print('❌ OwnerDropOffError: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Car Pickup'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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
                          color: AppColors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.check_circle, color: AppColors.green, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Car Pickup Process',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Car has been returned by renter - Please review all details',
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

                // Handover Summary
                _buildSummaryCard(),
                const SizedBox(height: 20),

                // Car Images (from camera)
                _buildImagesCard(),
                const SizedBox(height: 20),

                // Excess Charges
                // if (data['excessAmount'] != null)
                //   _buildExcessChargesCard(),
                // const SizedBox(height: 20),

                // Payment Status
                _buildPaymentStatusCard(),
                const SizedBox(height: 20),

                // Renter Notes
                // if ((data['renterNotes'] ?? '').toString().isNotEmpty)
                //   _buildRenterNotesCard(),
                // const SizedBox(height: 20),

                // Owner Notes
                _buildOwnerNotesCard(),
                const SizedBox(height: 20),

                // Contract Confirmation
                _buildContractConfirmationCard(),
                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Handover Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryItem('Car Name', widget.notificationData['carName'].toString() ?? ''),
          _buildSummaryItem('Renter Name', widget.notificationData['renterName'].toString() ?? 'Not specified'),
          _buildSummaryItem('Final Odometer Reading', widget.notificationData['odometerValue'].toString() ?? 'Not specified'),
        ],
      ),
    );
  }

  Widget _buildImagesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_camera, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Capture Images',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('Car Image:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _carImageFile != null
                        ? Image.file(_carImageFile!, height: 120)
                        : OutlinedButton.icon(
                            onPressed: () => _pickImage(true),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Take Car Photo'),
                          ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    const Text('Odometer Image:', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _odometerImageFile != null
                        ? Image.file(_odometerImageFile!, height: 120)
                        : OutlinedButton.icon(
                            onPressed: () => _pickImage(false),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Take Odometer Photo'),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExcessChargesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
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
          const Text('Excess Charges', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Amount: ${widget.notificationData['excessAmount'] ?? 'N/A'} EGP'),
          Text('Status: ${widget.notificationData['excessPaidStatus'] ?? 'N/A'}'),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.payment, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Payment Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryItem('Payment Method', widget.notificationData['paymentMethod'] ?? ''),
          _buildSummaryItem('Payment Status', widget.notificationData['excessPaidStatus'] ?? ''),
          if (widget.notificationData['excessAmount'] != null)
            _buildSummaryItem('Amount', '${widget.notificationData['excessAmount']} EGP'),
        ],
      ),
    );
  }

  Widget _buildRenterNotesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.note, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Renter Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[50]!, Colors.grey[100]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              widget.notificationData['renterNotes'] ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerNotesCard() {
    return HandoverNotesWidget(
      title: 'Owner Notes',
      initialValue: _ownerNotes,
      onNotesChanged: (notes) {
        setState(() {
          _ownerNotes = notes;
        });
      },
      hintText: 'Add your notes about car pickup...',
    );
  }

  Widget _buildContractConfirmationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.verified_user,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Contract Confirmation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _contractConfirmed,
                onChanged: (value) {
                  setState(() {
                    _contractConfirmed = value ?? false;
                  });
                },
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'I confirm that I have reviewed all data, verified its accuracy, received the payment, and hereby declare the contract completed successfully.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final canComplete = _carImageFile != null && _odometerImageFile != null && _contractConfirmed;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      child: ElevatedButton(
        onPressed: canComplete ? _completeHandover : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canComplete ? AppColors.green : Colors.grey,
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
              'Complete Drop off',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}