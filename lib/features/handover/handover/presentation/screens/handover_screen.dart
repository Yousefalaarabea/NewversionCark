import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../../config/routes/screens_name.dart';
import '../../../../../config/themes/app_colors.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../../notifications/presentation/cubits/notification_cubit.dart';
import '../cubits/contract_upload_cubit.dart';
import '../cubits/handover_cubit.dart';
import '../widgets/contract_upload_widget.dart';
import '../widgets/deposit_status_widget.dart';
import '../widgets/confirmation_checkboxes_widget.dart';

class HandoverScreen extends StatefulWidget {
  final String paymentMethod;
  final int rentalId;
  const HandoverScreen({super.key, required this.paymentMethod, required this.rentalId});

  @override
  State<HandoverScreen> createState() => _HandoverScreenState();
}

class _HandoverScreenState extends State<HandoverScreen> {
  @override
  void initState() {
    super.initState();
    print("🔍 [HandoverScreen] Initializing with rentalId: ${widget.rentalId}");
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ContractUploadCubit()),
        BlocProvider(create: (context) => HandoverCubit()..setRentalId(widget.rentalId)),
      ],
      child: HandoverScreenContent(paymentMethod: widget.paymentMethod),
    );
  }
}

class HandoverScreenContent extends StatefulWidget {
  final String paymentMethod;
  const HandoverScreenContent({Key? key, required this.paymentMethod}) : super(key: key);

  @override
  State<HandoverScreenContent> createState() => _HandoverScreenContentState();
}

class _HandoverScreenContentState extends State<HandoverScreenContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Owner Pick-Up Handover',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
          // Debug button to check rentalId status
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              final cubit = context.read<HandoverCubit>();
              print('🔍 [HandoverScreen] Debug - Current rentalId: ${cubit.rentalId}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('rentalId: ${cubit.rentalId}'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Check rentalId status',
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning message
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12, top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.yellow.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Do not hand over your car until you receive a notification confirming the Renter Handover.',
                    style: TextStyle(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // باقي الصفحة كما هي
          Expanded(
            child: BlocListener<HandoverCubit, HandoverState>(
              listener: (context, state) {
                if (state is HandoverSuccess) {
                  // Send notification to renter that owner has submitted handover
                  _notifyRenterHandoverSubmitted();

                  Navigator.pushReplacementNamed(
                    context,
                    ScreensName.ownerHomeScreen,
                  );
                } else if (state is HandoverCancelled) {
                  _showSuccessSnackBar(context, state.message);
                  // Navigate to owner home after cancellation
                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      ScreensName.ownerHomeScreen,
                      (route) => false,
                    );
                  });
                } else if (state is HandoverFailure) {
                  _showErrorSnackBar(context, state.error);
                }
              },
              child: BlocBuilder<HandoverCubit, HandoverState>(
                builder: (context, handoverState) {
                  if (handoverState is HandoverLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _buildHeader(context),
                        const SizedBox(height: 24),

                        // Deposit Status
                        const DepositStatusWidget(),
                        const SizedBox(height: 24),

                        // Check if deposit is paid
                        if (handoverState is HandoverDataLoaded &&
                            !handoverState.contract.isDepositPaid)
                          _buildDepositWarning(context, handoverState.contract)
                        else ...[
                          // Contract Upload
                          const ContractUploadWidget(),
                          const SizedBox(height: 24),

                          // Confirmations
                          ConfirmationCheckboxesWidget(paymentMethod: widget.paymentMethod),
                          const SizedBox(height: 32),

                          // Action Buttons
                          _buildActionButtons(context),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.primary.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.handshake,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Car Handover Process',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Complete the handover process to finalize the rental',
                  style: TextStyle(
                    color: AppColors.gray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositWarning(BuildContext context, contract) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.red.withOpacity(0.1),
        border: Border.all(color: AppColors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                color: AppColors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Deposit Required',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Please ensure the deposit of ${contract.depositAmount.toStringAsFixed(2)} EGP is paid before proceeding with the handover.',
            style: TextStyle(
              color: AppColors.red,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return BlocBuilder<HandoverCubit, HandoverState>(
      builder: (context, handoverState) {
        return BlocBuilder<ContractUploadCubit, ContractUploadState>(
          builder: (context, contractState) {
            var canSendHandover;
            if (widget.paymentMethod == 'Cash') {
              print("ANAAAAAAAAAAAAA CUbiiiiiiiiiiiiiiiiiit   CASSSSSSSSSSSSSSH");
              canSendHandover = handoverState is HandoverConfirmationsUpdated &&
                handoverState.isContractSigned &&
                handoverState.isRemainingAmountReceived &&
                contractState is ContractUploadSuccess;
            } else {
              print("ANAAAAAAAAAAAAA CUbiiiiiiiiiiiiiiiiiit  MSHHHHHHHHHHHHH   CASSSSSSSSSSSSSSH");
              canSendHandover = handoverState is HandoverConfirmationsUpdated &&
                handoverState.isContractSigned &&
                contractState is ContractUploadSuccess;
            }
            return Column(
              children: [
                // Send Handover Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: canSendHandover
                        ? () => _sendHandover(context)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: handoverState is HandoverSending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                            ),
                          )
                        : const Text(
                            'Send Handover',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.white
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

              ],
            );
          },
        );
      },
    );
  }

  void _sendHandover(BuildContext context) {
    final contractUploadCubit = context.read<ContractUploadCubit>();
    final handoverCubit = context.read<HandoverCubit>();

    final handoverState = context.read<HandoverCubit>().state;
    final paymentMethod = widget.paymentMethod.toLowerCase();
    bool canSend = false;
    if (handoverState is HandoverConfirmationsUpdated) {
      if (paymentMethod == 'cash') {
        canSend = handoverState.isContractSigned && handoverState.isRemainingAmountReceived;
        print("ANAAAAAAAAAAAAA CASSSSSSSSSSSSSSH");
      } else {
        canSend = handoverState.isContractSigned;
        print("ANAAAAAAAAAAAAA MESSSHHHHHHHHHHHHHHHHH     CASSSSSSSSSSSSSSH");
      }
    }
    if (contractUploadCubit.hasContractImage && canSend) {
      print("ANAAAAAAAAAAAAA BA3333333333t   mn screeeeeeeeeeeen");

      handoverCubit.sendHandover(
        contractImagePath: contractUploadCubit.contractImagePath!,
        paymentMethod: paymentMethod,
      );
    }
  }

  // void _showCancelDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Cancel Handover'),
  //       content: const Text(
  //         'Are you sure you want to cancel the handover? This will refund the deposit to your wallet.',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('No'),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pushNamed(context, '/cancel-rental');
  //             context.read<HandoverCubit>().cancelHandover();
  //           },
  //           style: TextButton.styleFrom(foregroundColor: AppColors.red),
  //           child: const Text('Yes, Cancel'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Handover Process Help'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Ensure deposit is paid'),
            SizedBox(height: 8),
            Text('2. Upload signed contract image'),
            SizedBox(height: 8),
            Text('3. Confirm contract signing'),
            SizedBox(height: 8),
            Text('4. Confirm remaining amount received'),
            SizedBox(height: 8),
            Text('5. Click "Send Handover" to complete'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _notifyRenterHandoverSubmitted() async {
    try {
      // Get current user (owner)
      final authCubit = context.read<AuthCubit>();
      final currentUser = authCubit.userModel;

      if (currentUser == null) {
        throw Exception('User not found');
      }

      // Get the latest booking request for this owner
      final bookingRequestsQuery = await FirebaseFirestore.instance
          .collection('booking_requests')
          .where('ownerId', isEqualTo: currentUser.id)
          .where('status', isEqualTo: 'deposit_paid')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (bookingRequestsQuery.docs.isNotEmpty) {
        final bookingData = bookingRequestsQuery.docs.first.data();
        final renterId = bookingData['renterId'] as String?;
        final carBrand = bookingData['carBrand'] as String? ?? '';
        final carModel = bookingData['carModel'] as String? ?? '';
        final ownerName = '${currentUser.firstName} ${currentUser.lastName}';

        if (renterId != null) {
          // Send in-app notification to renter that owner has completed handover
          context.read<NotificationCubit>().sendHandoverNotification(
            carBrand: carBrand,
            carModel: carModel,
            type: 'handover_started',
            userName: ownerName,
          );

          // Update booking status to 'owner_handover_completed'
          await FirebaseFirestore.instance
              .collection('booking_requests')
              .doc(bookingRequestsQuery.docs.first.id)
              .update({
            'status': 'owner_handover_completed',
            'ownerHandoverCompletedAt': DateTime.now().toIso8601String(),
          });

          print('Owner handover notification sent to renter: $renterId');
        }
      } else {
        print('No booking request found for owner: ${currentUser.id}');
      }
    } catch (e) {
      print('Error notifying renter: $e');
      // Don't throw the error to avoid crashing the app
    }
  }
}