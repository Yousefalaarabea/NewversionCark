import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/themes/app_colors.dart';
import '../cubits/handover_cubit.dart';

class DepositStatusWidget extends StatelessWidget {
  const DepositStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HandoverCubit, HandoverState>(
      builder: (context, state) {
        if (state is HandoverDataLoaded) {
          final contract = state.contract;
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: contract.isDepositPaid 
                  ? AppColors.green.withOpacity(0.1)
                  : AppColors.red.withOpacity(0.1),
              border: Border.all(
                color: contract.isDepositPaid 
                    ? AppColors.green.withOpacity(0.3)
                    : AppColors.red.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  contract.isDepositPaid 
                      ? Icons.check_circle
                      : Icons.error,
                  color: contract.isDepositPaid 
                      ? AppColors.green
                      : AppColors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deposit Status',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contract.isDepositPaid
                            ? 'Deposit paid: ${contract.depositAmount.toStringAsFixed(2)} EGP'
                            : 'Deposit not paid: ${contract.depositAmount.toStringAsFixed(2)} EGP',
                        style: TextStyle(
                          color: contract.isDepositPaid 
                              ? AppColors.green
                              : AppColors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }
} 