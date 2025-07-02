import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';

import '../../../../../config/themes/app_colors.dart';
import '../../../../../core/widgets/custom_elevated_button.dart';
import '../cubits/owner_drop_off_cubit.dart';
import '../models/post_trip_handover_model.dart';
import '../models/handover_log_model.dart';
import '../widgets/excess_charges_widget.dart';
import '../widgets/handover_notes_widget.dart';

class OwnerDropOffScreen extends StatefulWidget {
  final PostTripHandoverModel handoverData;
  final List<HandoverLogModel> logs;

  const OwnerDropOffScreen({
    super.key,
    required this.handoverData,
    required this.logs,
  });

  @override
  State<OwnerDropOffScreen> createState() => _OwnerDropOffScreenState();
}

class _OwnerDropOffScreenState extends State<OwnerDropOffScreen> {
  String? _ownerNotes;
  bool _contractConfirmed = false;

  @override
  void initState() {
    super.initState();
    _loadHandoverData();
  }

  void _loadHandoverData() {
    context.read<OwnerDropOffCubit>().loadHandoverData(
      widget.handoverData,
      widget.logs,
    );
  }

  void _confirmCashPayment() {
    context.read<OwnerDropOffCubit>().confirmCashPayment();
  }

  void _completeHandover() {
    context.read<OwnerDropOffCubit>().completeOwnerHandover();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Pickup'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocConsumer<OwnerDropOffCubit, OwnerDropOffState>(
        listener: (context, state) {
          if (state is OwnerDropOffError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is OwnerDropOffCashPaymentConfirmed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cash payment received successfully')),
            );
          } else if (state is OwnerDropOffNotesAdded) {
            setState(() {
              _ownerNotes = state.notes;
            });
          } else if (state is OwnerDropOffCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Car pickup completed successfully - Trip ended')),
            );
            // Navigate back to home or show completion screen
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          if (state is OwnerDropOffLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading data...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is OwnerDropOffDataLoaded || 
              state is OwnerDropOffCashPaymentConfirmed ||
              state is OwnerDropOffNotesAdded ||
              state is OwnerDropOffCompleted) {
            
            PostTripHandoverModel handoverData;
            List<HandoverLogModel> logs;
            
            if (state is OwnerDropOffDataLoaded) {
              handoverData = state.handoverData;
              logs = state.logs;
            } else if (state is OwnerDropOffCashPaymentConfirmed) {
              handoverData = state.handoverData;
              logs = widget.logs;
            } else if (state is OwnerDropOffNotesAdded) {
              handoverData = state.handoverData;
              logs = widget.logs;
            } else {
              handoverData = (state as OwnerDropOffCompleted).handoverData;
              logs = (state).logs;
            }

            return SingleChildScrollView(
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
                  _buildSummaryCard(handoverData),
                  const SizedBox(height: 20),

                  // Car Images
                  if (handoverData.carImagePath != null || handoverData.odometerImagePath != null)
                    _buildImagesCard(handoverData),
                  const SizedBox(height: 20),

                  // Excess Charges
                  if (handoverData.excessCharges != null)
                    _buildExcessChargesCard(handoverData),
                  const SizedBox(height: 20),

                  // Payment Status
                  _buildPaymentStatusCard(handoverData),
                  const SizedBox(height: 20),

                  // Renter Notes
                  if (handoverData.renterNotes != null && handoverData.renterNotes!.isNotEmpty)
                    _buildRenterNotesCard(handoverData),
                  const SizedBox(height: 20),

                  // Owner Notes
                  _buildOwnerNotesCard(),
                  const SizedBox(height: 20),

                  // Contract Confirmation
                  _buildContractConfirmationCard(),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(handoverData, state),
                ],
              ),
            );
          }

          return const Center(child: Text('Loading data...'));
        },
      ),
    );
  }

  Widget _buildSummaryCard(PostTripHandoverModel handoverData) {
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
          _buildSummaryItem('Trip ID', handoverData.tripId),
          _buildSummaryItem('Car ID', handoverData.carId),
          _buildSummaryItem('Renter Handover Date', 
            handoverData.renterHandoverDate?.toString().substring(0, 19) ?? 'Not specified'),
          _buildSummaryItem('Final Odometer Reading', 
            handoverData.finalOdometerReading?.toString() ?? 'Not specified'),
        ],
      ),
    );
  }

  Widget _buildImagesCard(PostTripHandoverModel handoverData) {
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
                child: const Icon(Icons.photo_library, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Uploaded Images',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (handoverData.carImagePath != null) ...[
            const Text('Car Image:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(handoverData.carImagePath!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (handoverData.odometerImagePath != null) ...[
            const Text('Odometer Image:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(handoverData.odometerImagePath!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExcessChargesCard(PostTripHandoverModel handoverData) {
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
      child: ExcessChargesWidget(
        excessCharges: handoverData.excessCharges!,
        paymentMethod: handoverData.paymentMethod,
        paymentStatus: handoverData.paymentStatus,
      ),
    );
  }

  Widget _buildPaymentStatusCard(PostTripHandoverModel handoverData) {
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
          _buildSummaryItem('Payment Method', _getPaymentMethodText(handoverData.paymentMethod)),
          _buildSummaryItem('Payment Status', _getPaymentStatusText(handoverData.paymentStatus)),
          if (handoverData.paymentAmount != null)
            _buildSummaryItem('Amount', '\$${handoverData.paymentAmount!.toStringAsFixed(2)}'),
          
          // Cash payment confirmation button
          if (handoverData.paymentMethod == 'cash' && 
              handoverData.paymentStatus != 'completed')
            Container(
              margin: const EdgeInsets.only(top: 16),
              child: ElevatedButton.icon(
                onPressed: _confirmCashPayment,
                icon: const Icon(Icons.payment, size: 18),
                label: const Text(
                  'Confirm Cash Payment Received',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRenterNotesCard(PostTripHandoverModel handoverData) {
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
              handoverData.renterNotes!,
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
        context.read<OwnerDropOffCubit>().addOwnerNotes(notes);
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

  Widget _buildActionButtons(PostTripHandoverModel handoverData, OwnerDropOffState state) {
    final canComplete = handoverData.renterHandoverStatus == 'completed' &&
                       (handoverData.paymentMethod != 'cash' || 
                        handoverData.paymentStatus == 'completed') &&
                       _contractConfirmed;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      child: ElevatedButton(
        onPressed: canComplete ? _completeHandover : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canComplete ? AppColors.green : Colors.grey,
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
              'Complete Pickup',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'visa':
        return 'Visa';
      case 'wallet':
        return 'Wallet';
      case 'cash':
        return 'Cash';
      default:
        return method;
    }
  }

  String _getPaymentStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      default:
        return status ?? 'Not specified';
    }
  }
} 