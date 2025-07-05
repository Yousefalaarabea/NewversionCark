// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:test_cark/config/routes/screens_name.dart';
// import 'package:test_cark/config/themes/app_colors.dart';
// import 'package:test_cark/features/auth/presentation/cubits/auth_cubit.dart';
// import 'package:test_cark/features/notifications/presentation/cubits/notification_cubit.dart';
// import '../../../../auth/presentation/models/user_model.dart';
// import '../../model/car_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class DepositPaymentScreen extends StatefulWidget {
//   final CarModel car;
//   final double totalPrice;
//   final String? requestId;
//   final Map<String, dynamic>? bookingData;
//
//   const DepositPaymentScreen({
//     super.key,
//     required this.car,
//     required this.totalPrice,
//     this.requestId,
//     this.bookingData,
//   });
//
//   @override
//   State<DepositPaymentScreen> createState() => _DepositPaymentScreenState();
// }
//
// class _DepositPaymentScreenState extends State<DepositPaymentScreen> {
//   final TextEditingController _depositController = TextEditingController();
//   bool _isProcessing = false;
//   double _depositAmount = 0.0;
//
//   @override
//   void initState() {
//     super.initState();
//     // Set default deposit amount (usually 20% of total price)
//     _depositAmount = widget.totalPrice * 0.2;
//     _depositController.text = _depositAmount.toStringAsFixed(2);
//   }
//
//   @override
//   void dispose() {
//     _depositController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _processDepositPayment() async {
//     if (!mounted) return;
//
//     if (_depositController.text.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Please enter deposit amount')),
//         );
//       }
//       return;
//     }
//
//     setState(() {
//       _isProcessing = true;
//     });
//
//     try {
//       final authCubit = context.read<AuthCubit>();
//       final currentUser = authCubit.userModel;
//
//       if (currentUser == null) {
//         throw Exception('User not found');
//       }
//
//       final depositAmount = double.tryParse(_depositController.text);
//       if (depositAmount == null || depositAmount <= 0) {
//         throw Exception('Invalid deposit amount');
//       }
//
//       // Save booking to history
//       await _saveBookingToHistory(currentUser.id, depositAmount);
//
//       // Send notification to owner that deposit has been paid
//       await _notifyOwnerDepositPaid(currentUser, depositAmount);
//
//       // Mark the booking request as completed
//       await _markRequestAsCompleted();
//
//       // Show success message
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Deposit of \$${depositAmount.toStringAsFixed(2)} paid successfully!'),
//             backgroundColor: Colors.green,
//           ),
//         );
//
//         // Navigate to booking history or home
//         Navigator.pushNamedAndRemoveUntil(
//           context,
//           ScreensName.homeScreen,
//           (route) => false,
//         );
//       }
//     } catch (e) {
//       print('Error processing deposit payment: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isProcessing = false;
//         });
//       }
//     }
//   }
//
//   // Future<void> _saveBookingToHistory(String userId, double depositAmount) async {
//   //   try {
//   //     // This would typically save to a bookings collection in Firestore
//   //     // For now, we'll simulate the booking history save
//   //     print('Saving booking to history for user: $userId');
//   //     print('Car: ${widget.car.brand} ${widget.car.model}');
//   //     print('Total Price: \$${widget.totalPrice}');
//   //     print('Deposit Paid: \$${depositAmount}');
//   //
//   //     // In a real implementation, you would save this to Firestore
//   //     await FirebaseFirestore.instance.collection('bookings').add({
//   //       'userId': userId,
//   //       'carId': widget.car.id,
//   //       'carBrand': widget.car.brand,
//   //       'carModel': widget.car.model,
//   //       'totalPrice': widget.totalPrice,
//   //       'depositAmount': depositAmount,
//   //       'status': 'confirmed',
//   //       'createdAt': FieldValue.serverTimestamp(),
//   //       'bookingData': widget.bookingData,
//   //     });
//   //
//   //     print('Booking saved to history successfully');
//   //   } catch (e) {
//   //     print('Error saving booking to history: $e');
//   //     // Don't throw the error to avoid crashing the app
//   //   }
//   // }
//
//   Future<void> _notifyOwnerDepositPaid(UserModel currentUser, double depositAmount) async {
//     try {
//       final ownerId = widget.car.ownerId;
//       final renterName = '${currentUser.firstName} ${currentUser.lastName}';
//
//       // Update booking request status to 'deposit_paid'
//       if (widget.bookingData != null) {
//         try {
//           final bookingRequestsQuery = await FirebaseFirestore.instance
//               .collection('booking_requests')
//               .where('renterId', isEqualTo: currentUser.id)
//               .where('carId', isEqualTo: widget.car.id)
//               .where('status', isEqualTo: 'accepted')
//               .get();
//
//           if (bookingRequestsQuery.docs.isNotEmpty) {
//             final bookingRequestId = bookingRequestsQuery.docs.first.id;
//             await FirebaseFirestore.instance
//                 .collection('booking_requests')
//                 .doc(bookingRequestId)
//                 .update({
//               'status': 'deposit_paid',
//               'depositAmount': depositAmount,
//               'depositPaidAt': DateTime.now().toIso8601String(),
//             });
//           }
//         } catch (e) {
//           print('Error updating booking request: $e');
//           // Don't fail the notification if booking update fails
//         }
//       }
//
//       // Send in-app notification to owner that deposit has been paid
//       context.read<NotificationCubit>().sendPaymentNotification(
//         amount: depositAmount.toStringAsFixed(2),
//         carBrand: widget.car.brand,
//         carModel: widget.car.model,
//         type: 'deposit_paid',
//       );
//
//       // Send handover notification to owner
//       context.read<NotificationCubit>().sendHandoverNotification(
//         carBrand: widget.car.brand,
//         carModel: widget.car.model,
//         type: 'handover_started',
//         userName: renterName,
//       );
//
//       print('Owner notifications sent successfully');
//     } catch (e) {
//       print('Error notifying owner: $e');
//       // Don't throw the error to avoid crashing the app
//     }
//   }
//
//   Future<void> _markRequestAsCompleted() async {
//     try {
//       // Mark the booking request notification as read/completed
//       if (widget.requestId != null) {
//         // await context.read<NotificationCubit>().markAsRead(widget.requestId!);
//       }
//     } catch (e) {
//       print('Error marking request as completed: $e');
//       // Don't throw the error to avoid crashing the app
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Pay Deposit'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.r),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Car Details Card
//             _buildCarDetailsCard(),
//             SizedBox(height: 24.h),
//
//             // Deposit Amount Card
//             _buildDepositAmountCard(),
//             SizedBox(height: 24.h),
//
//             // Payment Method Card
//             _buildPaymentMethodCard(),
//             SizedBox(height: 32.h),
//
//             // Pay Button
//             _buildPayButton(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCarDetailsCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       child: Padding(
//         padding: EdgeInsets.all(16.r),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Car Details',
//               style: TextStyle(
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             SizedBox(height: 12.h),
//             Row(
//               children: [
//                 Container(
//                   width: 60.w,
//                   height: 60.h,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8.r),
//                     color: Colors.grey[200],
//                   ),
//                   child: Icon(Icons.directions_car, size: 30.sp, color: Colors.grey[600]),
//                 ),
//                 SizedBox(width: 12.w),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         '${widget.car.brand} ${widget.car.model}',
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       SizedBox(height: 4.h),
//                       Text(
//                         widget.car.carType,
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                       SizedBox(height: 4.h),
//                       Text(
//                         'Total Price: \$${widget.totalPrice.toStringAsFixed(2)}',
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           fontWeight: FontWeight.w500,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDepositAmountCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       child: Padding(
//         padding: EdgeInsets.all(16.r),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Deposit Amount',
//               style: TextStyle(
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             SizedBox(height: 12.h),
//             TextField(
//               controller: _depositController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: 'Deposit Amount',
//                 prefixText: '\$',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.r),
//                 ),
//                 hintText: 'Enter deposit amount',
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   _depositAmount = double.tryParse(value) ?? 0.0;
//                 });
//               },
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               'Recommended: 20% of total price (\$${(widget.totalPrice * 0.2).toStringAsFixed(2)})',
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPaymentMethodCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//       child: Padding(
//         padding: EdgeInsets.all(16.r),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Payment Method',
//               style: TextStyle(
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             SizedBox(height: 12.h),
//             Container(
//               padding: EdgeInsets.all(12.r),
//               decoration: BoxDecoration(
//                 color: Colors.grey[50],
//                 borderRadius: BorderRadius.circular(8.r),
//                 border: Border.all(color: Colors.grey[300]!),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.credit_card, color: AppColors.primary, size: 24.sp),
//                   SizedBox(width: 12.w),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Credit/Debit Card',
//                           style: TextStyle(
//                             fontSize: 16.sp,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         Text(
//                           'Secure payment via Stripe',
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16.sp),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPayButton() {
//     return SizedBox(
//       width: double.infinity,
//       height: 50.h,
//       child: ElevatedButton(
//         onPressed: _isProcessing ? null : _processDepositPayment,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primary,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8.r),
//           ),
//         ),
//         child: _isProcessing
//             ? SizedBox(
//                 width: 20.w,
//                 height: 20.h,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               )
//             : Text(
//                 'Pay Deposit \$${_depositAmount.toStringAsFixed(2)}',
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//       ),
//     );
//   }
// }