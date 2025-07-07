import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../cubit/car_cubit.dart';

class PaymentMethodSelector extends StatefulWidget {
  const PaymentMethodSelector({super.key});

  @override
  State<PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<PaymentMethodSelector> {
  final List<Map<String, dynamic>> paymentMethods = [
    {
      'name': 'Visa',
      'icon': Icons.credit_card,
      'description': 'Pay with Visa card',
    },
    {
      'name': 'Cash',
      'icon': Icons.money,
      'description': 'Pay with cash',
    },
    // {
    //   'name': 'Digital Wallet',
    //   'icon': Icons.account_balance_wallet,
    //   'description': 'Pay with digital wallet',
    // },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarCubit, dynamic>(
      builder: (context, state) {
        final selectedPaymentMethod = state.selectedPaymentMethod;
        print("""""""""""""""""""""""""object""""""""""""""""""""""""");
        print(selectedPaymentMethod);
        print("""""""""""""""""""""""""object""""""""""""""""""""""""");
        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: (selectedPaymentMethod == null && state.showValidation)
                  ? Colors.red.shade300 
                  : Colors.grey.shade300,
              width: (selectedPaymentMethod == null && state.showValidation) ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.payment,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Payment Method *',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (selectedPaymentMethod == null && state.showValidation) ...[
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.warning,
                      color: Colors.red,
                      size: 16.sp,
                    ),
                  ],
                ],
              ),
              if (selectedPaymentMethod == null && state.showValidation) ...[
                SizedBox(height: 8.h),
                Text(
                  'Please select a payment method',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              SizedBox(height: 12.h),
              ...paymentMethods.map((method) => _buildPaymentOption(method, selectedPaymentMethod)).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentOption(Map<String, dynamic> method, String? selectedPaymentMethod) {
    final isSelected = selectedPaymentMethod == method['name'];
    
    return GestureDetector(
      onTap: () {
        context.read<CarCubit>().setSelectedPaymentMethod(method['name']);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                method['icon'],
                color: isSelected 
                    ? Colors.white
                    : Colors.grey.shade600,
                size: 18.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['name'],
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    method['description'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
} 