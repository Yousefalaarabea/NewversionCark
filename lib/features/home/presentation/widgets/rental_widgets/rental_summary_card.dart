import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:test_cark/features/home/presentation/widgets/rental_widgets/show_edit_bottom_sheet.dart';
import '../../cubit/car_cubit.dart';

class RentalSummaryCard extends StatelessWidget {
  const RentalSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CarCubit>().state;

    return GestureDetector(
      onTap: () => showEditBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.red),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    state.pickupStation != null ? state.pickupStation!.name : 'Pick-up Station',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  Text(
                    state.dateRange != null
                        ? '${DateFormat('MMM dd').format(state.dateRange!.start)} - ${DateFormat('MMM dd').format(state.dateRange!.end)}'
                        : 'Select Date Range',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const Icon(Icons.edit, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}


