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
    Key? key,
    required this.handoverData,
    required this.logs,
  }) : super(key: key);

  @override
  State<OwnerDropOffScreen> createState() => _OwnerDropOffScreenState();
}

class _OwnerDropOffScreenState extends State<OwnerDropOffScreen> {
  String? _ownerNotes;

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
        title: Text('استلام السيارة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: BlocConsumer<OwnerDropOffCubit, OwnerDropOffState>(
        listener: (context, state) {
          if (state is OwnerDropOffError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is OwnerDropOffCashPaymentConfirmed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تم تأكيد استلام الدفع النقدي')),
            );
          } else if (state is OwnerDropOffNotesAdded) {
            setState(() {
              _ownerNotes = state.notes;
            });
          } else if (state is OwnerDropOffCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تم استلام السيارة بنجاح - انتهت الرحلة')),
            );
            // Navigate back to home or show completion screen
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        builder: (context, state) {
          if (state is OwnerDropOffLoading) {
            return Center(child: CircularProgressIndicator());
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
              logs = (state as OwnerDropOffCompleted).logs;
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: AppColors.green, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'استلام السيارة',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'تم تسليم السيارة من المستأجر - يرجى مراجعة التفاصيل',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Handover Summary
                  _buildSummaryCard(handoverData),
                  SizedBox(height: 16),

                  // Car Images
                  if (handoverData.carImagePath != null || handoverData.odometerImagePath != null)
                    _buildImagesCard(handoverData),
                  SizedBox(height: 16),

                  // Excess Charges
                  if (handoverData.excessCharges != null)
                    _buildExcessChargesCard(handoverData),
                  SizedBox(height: 16),

                  // Payment Status
                  _buildPaymentStatusCard(handoverData),
                  SizedBox(height: 16),

                  // Renter Notes
                  if (handoverData.renterNotes != null && handoverData.renterNotes!.isNotEmpty)
                    _buildRenterNotesCard(handoverData),
                  SizedBox(height: 16),

                  // Owner Notes
                  _buildOwnerNotesCard(),
                  SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(handoverData, state),
                ],
              ),
            );
          }

          return Center(child: Text('جاري تحميل البيانات...'));
        },
      ),
    );
  }

  Widget _buildSummaryCard(PostTripHandoverModel handoverData) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'ملخص التسليم',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildSummaryItem('معرف الرحلة', handoverData.tripId),
          _buildSummaryItem('معرف السيارة', handoverData.carId),
          _buildSummaryItem('تاريخ تسليم المستأجر', 
            handoverData.renterHandoverDate?.toString().substring(0, 19) ?? 'غير محدد'),
          _buildSummaryItem('قراءة العداد النهائية', 
            handoverData.finalOdometerReading?.toString() ?? 'غير محدد'),
        ],
      ),
    );
  }

  Widget _buildImagesCard(PostTripHandoverModel handoverData) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.photo_library, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'الصور المرفوعة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (handoverData.carImagePath != null) ...[
            Text('صورة السيارة:', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(handoverData.carImagePath!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
          if (handoverData.odometerImagePath != null) ...[
            Text('صورة العداد:', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
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
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'حالة الدفع',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildSummaryItem('طريقة الدفع', _getPaymentMethodText(handoverData.paymentMethod)),
          _buildSummaryItem('حالة الدفع', _getPaymentStatusText(handoverData.paymentStatus)),
          if (handoverData.paymentAmount != null)
            _buildSummaryItem('المبلغ', '${handoverData.paymentAmount!.toStringAsFixed(2)} ريال'),
          
          // Cash payment confirmation button
          if (handoverData.paymentMethod == 'cash' && 
              handoverData.paymentStatus != 'completed')
            Padding(
              padding: EdgeInsets.only(top: 16),
              child: CustomElevatedButton(
                onPressed: _confirmCashPayment,
                text: 'تأكيد استلام الدفع النقدي',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRenterNotesCard(PostTripHandoverModel handoverData) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'ملاحظات المستأجر',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              handoverData.renterNotes!,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerNotesCard() {
    return HandoverNotesWidget(
      title: 'ملاحظات المالك',
      initialValue: _ownerNotes,
      onNotesChanged: (notes) {
        context.read<OwnerDropOffCubit>().addOwnerNotes(notes);
      },
      hintText: 'أضف ملاحظاتك حول استلام السيارة...',
    );
  }

  Widget _buildActionButtons(PostTripHandoverModel handoverData, OwnerDropOffState state) {
    final canComplete = handoverData.renterHandoverStatus == 'completed' &&
                       (handoverData.paymentMethod != 'cash' || 
                        handoverData.paymentStatus == 'completed');

    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canComplete ? _completeHandover : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canComplete ? AppColors.green : Colors.grey,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'إكمال الاستلام',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
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
        return 'فيزا';
      case 'wallet':
        return 'محفظة';
      case 'cash':
        return 'نقدي';
      default:
        return method;
    }
  }

  String _getPaymentStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'completed':
        return 'مكتمل';
      case 'failed':
        return 'فشل';
      default:
        return status ?? 'غير محدد';
    }
  }
} 