import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/themes/app_colors.dart';
import '../cubits/handover_cubit.dart';

class ConfirmationCheckboxesWidget extends StatelessWidget {
  final String paymentMethod;

  const ConfirmationCheckboxesWidget({Key? key, required this.paymentMethod}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HandoverCubit, HandoverState>(
      builder: (context, state) {
        bool isContractSigned = false;
        bool isRemainingAmountReceived = false;

        if (state is HandoverConfirmationsUpdated) {
          isContractSigned = state.isContractSigned;
          isRemainingAmountReceived = state.isRemainingAmountReceived;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confirmations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Contract signing confirmation
            _buildCheckbox(
              context,
              title: 'I confirm that I have signed the contract',
              subtitle: 'Please ensure you have signed the rental contract',
              value: isContractSigned,
              onChanged: (value) {
                context.read<HandoverCubit>().updateContractSigned(value ?? false);
              },
            ),
            
            const SizedBox(height: 12),

            // Show this only if payment is cash
            if (paymentMethod.toLowerCase() == 'Cash')
              _buildCheckbox(
                context,
                title: 'I confirm that I have received the remaining amount',
                subtitle: 'If payment was cash, confirm you received the balance',
                value: isRemainingAmountReceived,
                onChanged: (value) {
                  context.read<HandoverCubit>().updateRemainingAmountReceived(value ?? false);
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildCheckbox(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value ? AppColors.primary : AppColors.gray.withOpacity(0.3),
        ),
        color: value ? AppColors.primary.withOpacity(0.05) : AppColors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: value ? AppColors.primary : AppColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 