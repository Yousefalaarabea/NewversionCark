// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:test_cark/config/routes/screens_name.dart';
// import 'package:test_cark/config/themes/app_colors.dart';
// import 'package:test_cark/core/services/notification_service.dart';
// import 'package:test_cark/features/auth/presentation/cubits/auth_cubit.dart';
// import 'package:test_cark/features/notifications/presentation/cubits/notification_cubit.dart';
// import '../../model/car_model.dart';
//
// class BookingRequestScreen extends StatefulWidget {
//   const BookingRequestScreen({super.key});
//
//   @override
//   State<BookingRequestScreen> createState() => _BookingRequestScreenState();
// }
//
// class _BookingRequestScreenState extends State<BookingRequestScreen> {
//   bool _isLoading = false;
//   List<Map<String, dynamic>> _pendingRequests = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadPendingRequests();
//   }
//
//   Future<void> _loadPendingRequests() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final authCubit = context.read<AuthCubit>();
//       final currentUser = authCubit.userModel;
//
//       if (currentUser != null) {
//         // Load notifications for the current user
//         await context.read<NotificationCubit>().fetchAllNotificationsForUser(currentUser.id);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading requests: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
//
//   void _proceedToDepositPayment(Map<String, dynamic> request) {
//     Navigator.pushNamed(
//       context,
//       ScreensName.depositPaymentScreen,
//       arguments: {
//         'car': request['car'],
//         'totalPrice': request['totalPrice'],
//         'requestId': request['requestId'],
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Booking Requests'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : BlocBuilder<NotificationCubit, dynamic>(
//               builder: (context, state) {
//                 if (state is NotificationLoaded) {
//                   final bookingNotifications = state.notifications
//                       .where((notification) =>
//                           notification.type == 'booking' &&
//                           notification.title.contains('accepted'))
//                       .toList();
//
//                   if (bookingNotifications.isEmpty) {
//                     return _buildEmptyState();
//                   }
//
//                   return ListView.builder(
//                     padding: EdgeInsets.all(16.r),
//                     itemCount: bookingNotifications.length,
//                     itemBuilder: (context, index) {
//                       final notification = bookingNotifications[index];
//                       return _buildRequestCard(notification);
//                     },
//                   );
//                 }
//
//                 return _buildEmptyState();
//               },
//             ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.hourglass_empty,
//             size: 64.sp,
//             color: Colors.grey[400],
//           ),
//           SizedBox(height: 16.h),
//           Text(
//             'No pending booking requests',
//             style: TextStyle(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.w500,
//               color: Colors.grey[600],
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Text(
//             'Your booking requests will appear here',
//             style: TextStyle(
//               fontSize: 14.sp,
//               color: Colors.grey[500],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildRequestCard(notification) {
//     return Card(
//       margin: EdgeInsets.only(bottom: 16.h),
//       elevation: 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(16.r),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.check_circle,
//                   color: Colors.green,
//                   size: 24.sp,
//                 ),
//                 SizedBox(width: 8.w),
//                 Expanded(
//                   child: Text(
//                     'Booking Accepted!',
//                     style: TextStyle(
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12.h),
//             Text(
//               notification.body ?? 'Your booking request has been accepted by the car owner.',
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 color: Colors.grey[700],
//               ),
//             ),
//             SizedBox(height: 16.h),
//             Container(
//               padding: EdgeInsets.all(12.r),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8.r),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.info_outline,
//                     color: AppColors.primary,
//                     size: 20.sp,
//                   ),
//                   SizedBox(width: 8.w),
//                   Expanded(
//                     child: Text(
//                       'Please proceed to pay the deposit to confirm your booking.',
//                       style: TextStyle(
//                         fontSize: 13.sp,
//                         color: AppColors.primary,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 16.h),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () => _proceedToDepositPayment({
//                   'car': CarModel.mock(), // This should be the actual car data
//                   'totalPrice': 500.0, // This should be the actual price
//                   'requestId': notification.id,
//                 }),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   foregroundColor: Colors.white,
//                   padding: EdgeInsets.symmetric(vertical: 12.h),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.r),
//                   ),
//                 ),
//                 child: Text(
//                   'Proceed to Pay Deposit',
//                   style: TextStyle(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }