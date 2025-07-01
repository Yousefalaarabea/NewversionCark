import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/themes/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// done
class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  bool _agreedToTerms = false;
  String? _selectedMethod; // 'card', 'new_card', 'saving_card'

  // Dummy data for saved cards (replace with actual user data if needed)
  final List<Map<String, String>> _savedCards = [
    {'type': 'mastercard', 'last4': '7492'},
    {'type': 'visa', 'last4': '1234'}, // Added a Visa card for demonstration
  ];

  @override
  Widget build(BuildContext context) {
    final double deposit = 500.0; // Dummy deposit value as per your code
    final bool isPayButtonEnabled = _agreedToTerms && _selectedMethod != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Deposit'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: false, // Center the app bar title
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w), // Apply horizontal padding
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 16.h), // Apply vertical padding to scrollable content
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Deposit Amount Display
                      // Text(
                      //   'This is the deposit amount',
                      //   style: TextStyle(
                      //     fontSize: 18.sp,
                      //     fontWeight: FontWeight.w600,
                      //     color: Colors.grey[800],
                      //   ),
                      // ),
                      SizedBox(height: 12.h), // Space after title
                      Card(
                        elevation: 4, // Increased elevation for a nicer look
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                        margin: EdgeInsets.zero, // Remove default card margin
                        child: Padding(
                          padding: EdgeInsets.all(20.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Deposit Amount',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${deposit.toStringAsFixed(2)} EGP',
                                    style: TextStyle(
                                      fontSize: 32.sp, // Larger font size for prominence
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary, // Primary color for emphasis
                                    ),
                                  ),
                                  Icon(Icons.payments, color: AppColors.primary, size: 36.sp),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              Divider(color: Colors.grey[300]),
                              SizedBox(height: 10.h),
                              Text(
                                'This deposit is required to secure your booking. It will be held and may be refunded according to our policy.',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[700],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 30.h), // Increased space between sections

                      // Section 2: Payment Methods Selection
                      Text(
                        'Choose a Payment Method',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 15.h), // Space after title

                      // Saved Cards Sub-section
                      Text(
                        'Saved Cards',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      // Loop through saved cards
                      ..._savedCards.map((card) {
                        // Use 'card' as the methodKey for the first saved card (MasterCard)
                        // and 'saving_card' for the second (Visa) as per your original code's logic
                        final String methodKey = card['type'] == 'mastercard' ? 'card' : 'saving_card';
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: _buildPaymentOptionCard(
                            title: '${card['type']!.toUpperCase()} •••• ${card['last4']}',
                            iconWidget: card['type'] == 'mastercard'
                                ? FaIcon(FontAwesomeIcons.ccMastercard, color: Colors.red[700], size: 28.sp)
                                : FaIcon(FontAwesomeIcons.ccVisa, color: Colors.blue[800], size: 28.sp),
                            methodKey: methodKey,
                            selectedMethod: _selectedMethod,
                            onTap: () {
                              setState(() {
                                _selectedMethod = methodKey;
                              });
                            },
                          ),
                        );
                      }).toList(),

                      SizedBox(height: 20.h), // Space between saved cards and new method

                      // New Payment Method Sub-section
                      Text(
                        'New Payment Method',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: _buildPaymentOptionCard(
                          title: 'New Card',
                          iconWidget: FaIcon(FontAwesomeIcons.solidCreditCard, color: Colors.black, size: 24.sp),
                          methodKey: 'new_card',
                          selectedMethod: _selectedMethod,
                          onTap: () {
                            setState(() {
                              _selectedMethod = 'new_card';
                            });
                          },
                        ),
                      ),

                      SizedBox(height: 30.h), // Increased space between sections

                      // Section 3: Unavailable Methods
                      Text(
                        'Unavailable Methods',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 15.h), // Space after title

                      _buildUnavailablePaymentCard(
                        title: 'Saving Wallet',
                        iconWidget: FaIcon(FontAwesomeIcons.wallet, color: Colors.grey, size: 28.sp),
                      ),
                      SizedBox(height: 10.h),
                      _buildUnavailablePaymentCard(
                        title: 'Vodafone Cash',
                        iconWidget: Image.asset(
                          'assets/images/img/vodafone_logo.jpeg',
                          width: 32.w,
                          height: 24.h,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.phone_android, color: Colors.grey, size: 28.sp); // Fallback icon
                          },
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _buildUnavailablePaymentCard(
                        title: 'Fawry',
                        icon: Icon(Icons.account_balance_wallet, color: Colors.grey, size: 28.sp),
                      ),
                      SizedBox(height: 20.h), // Space before terms and conditions
                    ],
                  ),
                ),
              ),

              // Section 4: Terms and Conditions Agreement
              Padding(
                padding: EdgeInsets.only(bottom: 10.h), // Space above the button
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align text to top if it wraps
                  children: [
                    SizedBox(
                      width: 24.w, // Standard checkbox size
                      height: 24.h,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'By choosing a payment method, you agree with our terms and conditions for payments.',
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h), // Space between checkbox and button

              // Section 5: Pay Button
              SizedBox(
                width: double.infinity,
                height: 55.h, // Slightly taller button
                child: ElevatedButton(
                  onPressed: isPayButtonEnabled
                      ? () {
                    // Show dummy payment successful dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Payment Successful'),
                        content: Text('Thank you! Your deposit of ${deposit.toStringAsFixed(2)} EGP has been processed.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                    // TODO: Implement actual payment logic here
                  }
                      : null, // Button is disabled if onPressed is null
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPayButtonEnabled
                        ? (AppColors.primary ?? Colors.blue[900]) // Use primary color when enabled
                        : Colors.grey[400], // Grey when disabled
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r), // More rounded corners
                    ),
                    elevation: isPayButtonEnabled ? 5 : 0, // Add elevation when enabled
                  ),
                  child: Text(
                    'Pay Deposit ${deposit.toStringAsFixed(2)} EGP',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // Explicitly white text color
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h), // Space at the very bottom
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build payment option cards
  Widget _buildPaymentOptionCard({
    required String title,
    Icon? icon, // Keep this for standard Material Icons
    Widget? iconWidget, // Use this for FaIcon or Image.asset
    required String methodKey,
    required String? selectedMethod,
    required VoidCallback onTap,
  }) {
    final bool isSelected = selectedMethod == methodKey;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 4 : 1, // Higher elevation when selected
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2.5 : 1, // Thicker border when selected
          ),
        ),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          child: Row(
            children: [
              iconWidget ?? icon!, // Use iconWidget if provided, else use icon
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build unavailable payment method cards
  Widget _buildUnavailablePaymentCard({
    required String title,
    Icon? icon, // Keep this for standard Material Icons
    Widget? iconWidget, // Use this for FaIcon or Image.asset
  }) {
    return Card(
      color: Colors.grey[100], // Lighter grey background
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        child: Row(
          children: [
            iconWidget ?? icon!, // Use iconWidget if provided, else use icon
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey, // Greyed out text
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              'Unavailable',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
