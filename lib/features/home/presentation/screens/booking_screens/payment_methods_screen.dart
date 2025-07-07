import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/config/themes/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_cark/features/home/presentation/screens/booking_screens/saved_trips_screen.dart';
import '../../cubit/trip_cubit.dart';
import 'package:test_cark/core/booking_service.dart';
import 'package:test_cark/config/routes/screens_name.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../model/car_model.dart';
import '../../model/trip_details_model.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final CarModel? car;
  final double? totalPrice;
  final String? bookingRequestId;
  final Map<String, dynamic>? bookingData;

  const PaymentMethodsScreen({
    super.key,
    this.car,
    this.totalPrice,
    this.bookingRequestId,
    this.bookingData,
  });

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  bool _agreedToTerms = false;
  String? _selectedMethod; // 'card' or 'saving_card'

  // Helper methods to extract data from notification
  double get depositAmount {
    if (widget.bookingData != null &&
        widget.bookingData!['depositAmount'] != null) {
      return double.tryParse(widget.bookingData!['depositAmount'].toString()) ??
          0.0;
    }
    if (widget.totalPrice != null) {
      return (widget.totalPrice! * 0.2);
    }
    return 0.0;
  }

  String get carName {
    if (widget.bookingData != null && widget.bookingData!['carName'] != null) {
      return widget.bookingData!['carName'];
    }
    if (widget.car != null) {
      return '${widget.car!.brand} ${widget.car!.model}';
    }
    return 'Car';
  }

  double get totalAmount {
    if (widget.bookingData != null &&
        widget.bookingData!['totalAmount'] != null) {
      return double.tryParse(widget.bookingData!['totalAmount'].toString()) ??
          0.0;
    }
    if (widget.totalPrice != null) {
      return widget.totalPrice!;
    }
    return 0.0;
  }

  double get remainingAmount {
    if (widget.bookingData != null &&
        widget.bookingData!['remainingAmount'] != null) {
      return double.tryParse(
              widget.bookingData!['remainingAmount'].toString()) ??
          0.0;
    }
    return 0.0;
  }

  List<Map<String, dynamic>> get paymentMethods {
    if (widget.bookingData != null &&
        widget.bookingData!['paymentMethods'] != null) {
      final methods = widget.bookingData!['paymentMethods'] as List;
      return methods
          .map((method) => Map<String, dynamic>.from(method))
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
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
                      // Section 1: Car Information
                      if (widget.bookingData != null) ...[
                        Text('Car Information',
                            style: TextStyle(
                                fontSize: 18.sp, fontWeight: FontWeight.bold)),
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
                                  children: [
                                    Icon(Icons.directions_car,
                                        color: AppColors.primary, size: 22.sp),
                                    SizedBox(width: 6.w),
                                    Expanded(
                                      child: Text(
                                        carName,
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Total Amount:',
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey[700])),
                                    Text(
                                        '${totalAmount.toStringAsFixed(2)} EGP',
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Remaining Amount:',
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey[700])),
                                    Text(
                                        '${remainingAmount.toStringAsFixed(2)} EGP',
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24.h),
                      ],

                      // Section 2: Deposit Amount
                      Text('Deposit Amount',
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.bold)),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.attach_money,
                                          color: AppColors.primary,
                                          size: 22.sp),
                                      SizedBox(width: 6.w),
                                      Text('Deposit',
                                          style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(depositAmount.toStringAsFixed(2),
                                          style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary)),
                                      SizedBox(width: 4.w),
                                      Text('EGP',
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              color: Colors.grey[700],
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                  'This deposit is required to secure your booking. It will be held and may be refunded according to our policy.',
                                  style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey[700])),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),

                      // Section 3: Available Payment Methods
                      Text('Available Payment Methods',
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10.h),

                      // سكشن واحد فقط: saved card ثم new card
                      if (paymentMethods.isNotEmpty) ...[
                        // عرض كل الكروت المحفوظة
                        ...paymentMethods.map((method) {
                          final type = method['type'] ?? '';
                          final last4 = method['last4'] ?? '';
                          final brand = method['brand'] ?? '';
                          final id = method['id']?.toString() ?? '';
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMethod = id; // استخدم ID الكارت
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 8.h),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _selectedMethod == id
                                      ? Colors.blue
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(10.r),
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 14.h),
                              child: Row(
                                children: [
                                  _getPaymentIcon(type, brand),
                                  SizedBox(width: 14.w),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('$brand',
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold)),
                                      Text('•••• $last4',
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              letterSpacing: 2,
                                              color: Colors.grey[600])),
                                    ],
                                  ),
                                  Spacer(),
                                  if (_selectedMethod == id)
                                    Icon(Icons.check_circle,
                                        color: Colors.blue, size: 20.sp),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        // بعد الكروت المحفوظة، اعرض New card واحدة فقط
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMethod = 'new_card';
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 8.h),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedMethod == 'new_card'
                                    ? Colors.blue
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 14.h),
                            child: Row(
                              children: [
                                FaIcon(FontAwesomeIcons.solidCreditCard,
                                    color: Colors.black, size: 24.sp),
                                SizedBox(width: 14.w),
                                Text('New card',
                                    style: TextStyle(fontSize: 16.sp)),
                                Spacer(),
                                if (_selectedMethod == 'new_card')
                                  Icon(Icons.check_circle,
                                      color: Colors.blue, size: 20.sp),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        // إذا لم يوجد saved card، فقط new card
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMethod = 'new_card';
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 8.h),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedMethod == 'new_card'
                                    ? Colors.blue
                                    : Colors.grey[300]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 14.h),
                            child: Row(
                              children: [
                                FaIcon(FontAwesomeIcons.solidCreditCard,
                                    color: Colors.black, size: 24.sp),
                                SizedBox(width: 14.w),
                                Text('New card',
                                    style: TextStyle(fontSize: 16.sp)),
                                Spacer(),
                                if (_selectedMethod == 'new_card')
                                  Icon(Icons.check_circle,
                                      color: Colors.blue, size: 20.sp),
                              ],
                            ),
                          ),
                        ),
                      ],

                      SizedBox(height: 24.h),

                      // Section 4: Unavailable Methods
                      Padding(
                        padding:
                            EdgeInsets.only(left: 4.w, bottom: 6.h, top: 12.h),
                        child: Text(
                          'Unavailable',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: Colors.grey[700]),
                        ),
                      ),
                      Card(
                        color: Colors.grey[200],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Row(
                            children: [
                              FaIcon(FontAwesomeIcons.wallet,
                                  color: Colors.grey, size: 28.sp),
                              SizedBox(width: 12.w),
                              Text('Saving Wallet',
                                  style: TextStyle(
                                      fontSize: 16.sp, color: Colors.grey)),
                              Spacer(),
                              Text('Unavailable',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Card(
                        color: Colors.grey[200],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Row(
                            children: [
                              Image.asset(
                                  'assets/images/img/vodafone_logo.jpeg',
                                  width: 32.w,
                                  height: 24.h),
                              SizedBox(width: 12.w),
                              Text('Vodafone Cash',
                                  style: TextStyle(
                                      fontSize: 16.sp, color: Colors.grey)),
                              Spacer(),
                              Text('Unavailable',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Card(
                        color: Colors.grey[200],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Row(
                            children: [
                              Icon(Icons.account_balance_wallet,
                                  color: Colors.grey, size: 28.sp),
                              SizedBox(width: 12.w),
                              Text('Fawry',
                                  style: TextStyle(
                                      fontSize: 16.sp, color: Colors.grey)),
                              Spacer(),
                              Text('Unavailable',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold)),
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
                      style:
                          TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
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
                      ? () async {
                          // تحقق إذا كان _selectedMethod يطابق أحد الكروت المحفوظة
                          if (_selectedMethod != null &&
                              paymentMethods.any((m) => m['id'].toString() == _selectedMethod)) {
                            final method = paymentMethods.firstWhere((m) => m['id'].toString() == _selectedMethod);
                            final rentalId =
                                widget.bookingData?['rentalId']?.toString() ?? '';
                            final savedCardId = method['id']?.toString() ?? '';
                            final amountCents =
                                (depositAmount * 100).toInt().toString();
                            final paymentMethod = 'saved_card';
                            try {
                              final bookingService = BookingService();
                              final result = await bookingService
                                  .paySelfDriveDepositWithSavedCard(
                                rentalId: rentalId,
                                savedCardId: savedCardId,
                                amountCents: amountCents,
                                paymentMethod: paymentMethod,
                              );
                              if (context.mounted) {
                                await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(24)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.green[100],
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(18),
                                            child: Icon(Icons.check_circle,
                                                color: Colors.green, size: 64),
                                          ),
                                          SizedBox(height: 24),
                                          Text('Deposit Paid Successfully!',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(height: 12),
                                          Text(
                                              'Your deposit has been paid and your booking is now confirmed.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey[700])),
                                          SizedBox(height: 24),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primary,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                Navigator
                                                    .pushNamedAndRemoveUntil(
                                                  context,
                                                  ScreensName.homeScreen,
                                                  (route) => false,
                                                );
                                              },
                                              child: Text('Go to Home',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          } else if (_selectedMethod == 'new_card') {
                            final rentalId =
                                widget.bookingData?['rentalId']?.toString() ??
                                    '';
                            final amountCents =
                                (depositAmount * 100).toInt().toString();
                            final paymentMethod = 'new_card';
                            try {
                              final bookingService = BookingService();
                              final result = await bookingService
                                  .paySelfDriveDepositWithNewCard(
                                rentalId: rentalId,
                                amountCents: amountCents,
                                paymentMethod: paymentMethod,
                              );
                              // استقبل رابط الدفع من الـ response
                              final iframeUrl = result['iframe_url'] ?? '';
                              if (iframeUrl.isNotEmpty) {
                                // افتح صفحة الدفع داخل التطبيق وانتظر النتيجة
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PaymentWebViewScreen(url: iframeUrl),
                                  ),
                                );
                                // بعد رجوع المستخدم من صفحة الدفع
                                await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(24)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: Colors.green[100],
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(18),
                                            child: Icon(Icons.check_circle,
                                                color: Colors.green, size: 64),
                                          ),
                                          SizedBox(height: 24),
                                          Text('Deposit Paid Successfully!',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(height: 12),
                                          Text(
                                              'Your deposit has been paid and your booking is now confirmed.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.grey[700])),
                                          SizedBox(height: 24),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primary,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14),
                                              ),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                Navigator
                                                    .pushNamedAndRemoveUntil(
                                                  context,
                                                  ScreensName.homeScreen,
                                                  (route) => false,
                                                );
                                              },
                                              child: Text('Go to Home',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          }
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
                    'Pay Deposit ${depositAmount.toStringAsFixed(2)} EGP',
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getPaymentIcon(String type, String brand) {
    switch (type.toLowerCase()) {
      case 'card':
        if (brand.toLowerCase().contains('mastercard')) {
          return FaIcon(FontAwesomeIcons.ccMastercard,
              color: Colors.red[700], size: 28.sp);
        } else if (brand.toLowerCase().contains('visa')) {
          return FaIcon(FontAwesomeIcons.ccVisa,
              color: Colors.blue[700], size: 28.sp);
        } else {
          return FaIcon(FontAwesomeIcons.solidCreditCard,
              color: Colors.grey[700], size: 28.sp);
        }
      default:
        return FaIcon(FontAwesomeIcons.solidCreditCard,
            color: Colors.grey[700], size: 28.sp);
    }
  }
}

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  const PaymentWebViewScreen({super.key, required this.url});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late InAppWebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Payment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final uri = navigationAction.request.url.toString();
          // إذا الرابط فيه get_acs_page أو أي شرط خاص بالرد الجديد
          if (uri.contains('get_acs_page')) {
            await controller.loadUrl(urlRequest: URLRequest(url: WebUri(uri)));
            return NavigationActionPolicy.CANCEL;
          }
          return NavigationActionPolicy.ALLOW;
        },
      ),
    );
  }
}
