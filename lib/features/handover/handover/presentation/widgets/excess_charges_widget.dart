import 'package:flutter/material.dart';
import '../../../../../config/themes/app_colors.dart';
import '../models/excess_charges_model.dart';

class ExcessChargesWidget extends StatelessWidget {
  final ExcessChargesModel excessCharges;
  final String paymentMethod;
  final String? paymentStatus;

  const ExcessChargesWidget({
    Key? key,
    required this.excessCharges,
    required this.paymentMethod,
    this.paymentStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.onPrimaryFixed),
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
          // Header
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'رسوم الزيادة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Kilometers section
          _buildSection(
            title: 'الكيلومترات',
            icon: Icons.speed,
            items: [
              _buildItem('المتفق عليه', '${excessCharges.agreedKilometers} كم'),
              _buildItem('الفعلي', '${excessCharges.actualKilometers} كم'),
              if (excessCharges.extraKilometers > 0)
                _buildItem(
                  'الزيادة',
                  '${excessCharges.extraKilometers} كم',
                  isExtra: true,
                ),
              if (excessCharges.extraKilometers > 0)
                _buildItem(
                  'سعر الكم الزائد',
                  '${excessCharges.extraKmRate} ريال',
                ),
              if (excessCharges.extraKilometers > 0)
                _buildItem(
                  'تكلفة الكم الزائد',
                  '${excessCharges.extraKmCost.toStringAsFixed(2)} ريال',
                  isTotal: true,
                ),
            ],
          ),

          SizedBox(height: 16),

          // Hours section
          _buildSection(
            title: 'الوقت',
            icon: Icons.access_time,
            items: [
              _buildItem('المتفق عليه', '${excessCharges.agreedHours} ساعة'),
              _buildItem('الفعلي', '${excessCharges.actualHours} ساعة'),
              if (excessCharges.extraHours > 0)
                _buildItem(
                  'الزيادة',
                  '${excessCharges.extraHours} ساعة',
                  isExtra: true,
                ),
              if (excessCharges.extraHours > 0)
                _buildItem(
                  'سعر الساعة الزائدة',
                  '${excessCharges.extraHourRate} ريال',
                ),
              if (excessCharges.extraHours > 0)
                _buildItem(
                  'تكلفة الساعات الزائدة',
                  '${excessCharges.extraHourCost.toStringAsFixed(2)} ريال',
                  isTotal: true,
                ),
            ],
          ),

          SizedBox(height: 16),

          // Total section
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimaryFixed,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.onPrimaryFixed),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إجمالي الرسوم الزائدة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryFixed,
                  ),
                ),
                Text(
                  '${excessCharges.totalExcessCost.toStringAsFixed(2)} ريال',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryFixed,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12),

          // Payment method and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPaymentInfo('طريقة الدفع', _getPaymentMethodText()),
              if (paymentStatus != null)
                _buildPaymentInfo('حالة الدفع', _getPaymentStatusText()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ...items,
      ],
    );
  }

  Widget _buildItem(String label, String value, {bool isExtra = false, bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isExtra ? Colors.red : Colors.grey[700],
              fontWeight: isExtra || isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: isExtra ? Colors.red : Colors.grey[700],
              fontWeight: isExtra || isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  String _getPaymentMethodText() {
    switch (paymentMethod) {
      case 'visa':
        return 'فيزا';
      case 'wallet':
        return 'محفظة';
      case 'cash':
        return 'نقدي';
      default:
        return paymentMethod;
    }
  }

  String _getPaymentStatusText() {
    switch (paymentStatus) {
      case 'pending':
        return 'في الانتظار';
      case 'completed':
        return 'مكتمل';
      case 'failed':
        return 'فشل';
      default:
        return paymentStatus ?? '';
    }
  }
} 