import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/themes/app_colors.dart';

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            // Add new payment method button
            _buildAddPaymentMethodButton(),
            SizedBox(height: 24.h),
            
            // Payment methods list
            Expanded(
              child: _buildPaymentMethodsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPaymentMethodButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton.icon(
        onPressed: () {
          // Navigate to add payment method screen
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Payment Method'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    // Mock data - in a real app, this would come from a database
    final mockPaymentMethods = [
      {
        'id': '1',
        'type': 'card',
        'name': 'Visa ending in 1234',
        'isDefault': true,
        'expiryDate': '12/25',
      },
      {
        'id': '2',
        'type': 'card',
        'name': 'Mastercard ending in 5678',
        'isDefault': false,
        'expiryDate': '08/26',
      },
      {
        'id': '3',
        'type': 'wallet',
        'name': 'PayPal',
        'isDefault': false,
        'email': 'user@example.com',
      },
    ];

    if (mockPaymentMethods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card,
              size: 64.sp,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              'No payment methods yet',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add a payment method to make bookings easier',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: mockPaymentMethods.length,
      itemBuilder: (context, index) {
        final paymentMethod = mockPaymentMethods[index];
        return _buildPaymentMethodCard(paymentMethod);
      },
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> paymentMethod) {
    final type = paymentMethod['type'] as String;
    final isDefault = paymentMethod['isDefault'] as bool;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: _getPaymentMethodColor(type).withOpacity(0.1),
              ),
              child: Icon(
                _getPaymentMethodIcon(type),
                size: 30.sp,
                color: _getPaymentMethodColor(type),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        paymentMethod['name'],
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isDefault) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Text(
                            'DEFAULT',
                            style: TextStyle(
                              fontSize: 8.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  if (type == 'card') ...[
                    Text(
                      'Expires: ${paymentMethod['expiryDate']}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ] else if (type == 'wallet') ...[
                    Text(
                      paymentMethod['email'],
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                // Handle menu selection
                switch (value) {
                  case 'edit':
                    // Navigate to edit payment method
                    break;
                  case 'set_default':
                    // Set as default payment method
                    break;
                  case 'delete':
                    // Delete payment method
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                if (!isDefault)
                  const PopupMenuItem(
                    value: 'set_default',
                    child: Text('Set as Default'),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPaymentMethodColor(String type) {
    switch (type) {
      case 'card':
        return Colors.blue;
      case 'wallet':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentMethodIcon(String type) {
    switch (type) {
      case 'card':
        return Icons.credit_card;
      case 'wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }
} 