import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/themes/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


import '../../model/car_model.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final CarModel car;
  final double totalPrice;

  const PaymentMethodsScreen({
    super.key,
    required this.car,
    required this.totalPrice,
  });

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  bool _agreedToTerms = false;
  String? _selectedMethod; // 'card' or 'saving_card'

  @override
  Widget build(BuildContext context) {
    final double deposit = (widget.totalPrice * 0.2);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Deposit'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Default Deposit Amount
                      Text('Default Deposit Amount', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8.h),
                      Material(
                        elevation: 3,
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.attach_money, color: AppColors.primary, size: 22.sp),
                                      SizedBox(width: 6.w),
                                      Text('Deposit', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(deposit.toStringAsFixed(2), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                      SizedBox(width: 4.w),
                                      Text('EGP', style: TextStyle(fontSize: 16.sp, color: Colors.grey[700], fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text('This deposit is required to secure your booking. It will be held and may be refunded according to our policy.', style: TextStyle(fontSize: 13.sp, color: Colors.grey[700])),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // Section 2: Saved
                      Text('Saved', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10.h),
                      GestureDetector(
                        onTap: () {
                          setState(() { _selectedMethod = 'card'; });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _selectedMethod == 'card' ? Colors.blue : Colors.grey[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10.r),
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          child: Row(
                            children: [
                              FaIcon(FontAwesomeIcons.ccMastercard, color: Colors.red[700], size: 28.sp),
                              SizedBox(width: 14.w),
                              Text('•••• 7492', style: TextStyle(fontSize: 18.sp, letterSpacing: 2)),
                              Spacer(),
                              Text('View more', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 15.sp)),
                              Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 16.sp),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // Section 3: New payment method
                      Text('New payment method', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10.h),
                      GestureDetector(
                        onTap: () {
                          setState(() { _selectedMethod = 'new_card'; });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: _selectedMethod == 'new_card' ? Colors.blue : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          child: Row(
                            children: [
                              FaIcon(FontAwesomeIcons.solidCreditCard, color: Colors.black, size: 24.sp),
                              SizedBox(width: 14.w),
                              Text('New card', style: TextStyle(fontSize: 16.sp)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      GestureDetector(
                        onTap: () {
                          setState(() { _selectedMethod = 'saving_card'; });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: _selectedMethod == 'saving_card' ? Colors.blue : Colors.grey[300]!,
                              width: 2,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          child: Row(
                            children: [
                              FaIcon(FontAwesomeIcons.solidCreditCard, color: AppColors.primary, size: 24.sp),
                              SizedBox(width: 14.w),
                              Text('Saving Card', style: TextStyle(fontSize: 16.sp)),
                              SizedBox(width: 8.w),
                              Text('•••• 5678', style: TextStyle(fontSize: 16.sp, letterSpacing: 2)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // Section 4: Unavailable Methods
                      Padding(
                        padding: EdgeInsets.only(left: 4.w, bottom: 6.h, top: 12.h),
                        child: Text(
                          'Unavailable',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.grey[700]),
                        ),
                      ),
                      Card(
                        color: Colors.grey[200],
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Row(
                            children: [
                              FaIcon(FontAwesomeIcons.wallet, color: Colors.grey, size: 28.sp),
                              SizedBox(width: 12.w),
                              Text('Saving Wallet', style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
                              Spacer(),
                              Text('Unavailable', style: TextStyle(color: Colors.grey, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Card(
                        color: Colors.grey[200],
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Row(
                            children: [
                              Image.asset('assets/images/img/vodafone_logo.jpeg', width: 32.w, height: 24.h),
                              SizedBox(width: 12.w),
                              Text('Vodafone Cash', style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
                              Spacer(),
                              Text('Unavailable', style: TextStyle(color: Colors.grey, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Card(
                        color: Colors.grey[200],
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Row(
                            children: [
                              Icon(Icons.account_balance_wallet, color: Colors.grey, size: 28.sp),
                              SizedBox(width: 12.w),
                              Text('Fawry', style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
                              Spacer(),
                              Text('Unavailable', style: TextStyle(color: Colors.grey, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreedToTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Text(
                      'By choosing a payment method, you agree with our terms and conditions for payments.',
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: (_agreedToTerms && _selectedMethod != null)
                      ? () {
                          // TODO: Implement payment logic
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_agreedToTerms && _selectedMethod != null)
                        ? (AppColors.primary ?? Colors.blue[900])
                        : Colors.grey[400],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Pay Deposit ${deposit.toStringAsFixed(2)} EGP',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}