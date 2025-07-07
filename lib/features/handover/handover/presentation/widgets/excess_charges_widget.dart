import 'package:flutter/material.dart';
import '../../../../../config/themes/app_colors.dart';
import '../models/excess_charges_model.dart';

class ExcessChargesWidget extends StatelessWidget {
  final ExcessChargesModel excessCharges;
  final String paymentMethod;
  final String? paymentStatus;

  const ExcessChargesWidget({
    super.key,
    required this.excessCharges,
    required this.paymentMethod,
    this.paymentStatus,
  });

  @override
  Widget build(BuildContext context) {
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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Excess Charges',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Kilometers section
          _buildSection(
            title: 'Kilometers',
            icon: Icons.speed,
            items: [
              _buildItem('Agreed', '${excessCharges.agreedKilometers} km'),
              _buildItem('Actual', '${excessCharges.actualKilometers} km'),
              if (excessCharges.extraKilometers > 0)
                _buildItem(
                  'Extra',
                  '${excessCharges.extraKilometers} km',
                  isExtra: true,
                ),
              if (excessCharges.extraKilometers > 0)
                _buildItem(
                  'Extra km rate',
                  '${excessCharges.extraKmRate} EGP',
                ),
              if (excessCharges.extraKilometers > 0)
                _buildItem(
                  'Extra km cost',
                  '${excessCharges.extraKmCost.toStringAsFixed(2)} EGP',
                  isTotal: true,
                ),
            ],
          ),

          const SizedBox(height: 20),

          // Hours section
          _buildSection(
            title: 'Time',
            icon: Icons.access_time,
            items: [
              _buildItem('Agreed', '${excessCharges.agreedHours} Days'),
              _buildItem('Actual', '${excessCharges.actualHours} Days'),
              if (excessCharges.extraHours > 0)
                _buildItem(
                  'Extra',
                  '${excessCharges.extraHours} hours',
                  isExtra: true,
                ),
              if (excessCharges.extraHours > 0)
                _buildItem(
                  'Extra hour rate',
                  '${excessCharges.extraHourRate} EGP',
                ),
              if (excessCharges.extraHours > 0)
                _buildItem(
                  'Extra hours cost',
                  '${excessCharges.extraHourCost.toStringAsFixed(2)} EGP',
                  isTotal: true,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Total section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calculate, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Total Excess Charges',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${excessCharges.totalExcessCost.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Payment method and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPaymentInfo('Payment Method', _getPaymentMethodText()),
              if (paymentStatus != null)
                _buildPaymentInfo('Payment Status', _getPaymentStatusText()),
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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildItem(String label, String value, {bool isExtra = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isExtra ? Colors.red[600] : Colors.grey[700],
                fontWeight: isExtra || isTotal ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 1,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: isExtra ? Colors.red[600] : Colors.grey[700],
                fontWeight: isExtra || isTotal ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
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

  String _getPaymentMethodText() {
    switch (paymentMethod) {
      case 'visa':
        return 'Visa';
      case 'wallet':
        return 'Wallet';
      case 'cash':
        return 'Cash';
      default:
        return paymentMethod;
    }
  }

  String _getPaymentStatusText() {
    switch (paymentStatus) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      default:
        return paymentStatus ?? '';
    }
  }
} 