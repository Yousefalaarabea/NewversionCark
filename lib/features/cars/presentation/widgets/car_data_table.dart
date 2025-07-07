import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../home/presentation/widgets/home_widgets/car_card_widget.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';
import 'package:test_cark/features/cars/presentation/cubits/add_car_state.dart';


class CarDataTable extends StatelessWidget {
  final List<CarBundle> cars;
  final Function(CarBundle) onEdit;
  final Function(CarBundle) onDelete;
  final Function(CarBundle) onViewDetails;

  const CarDataTable({
    super.key,
    required this.cars,
    required this.onEdit,
    required this.onDelete,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cars.length,
      itemBuilder: (context, index) {
        final bundle = cars[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: CarCardWidget(
            car: bundle.car,
            rentalOptions: bundle.rentalOptions,
            onTap: () => onViewDetails(bundle),
            onEdit: () => onEdit(bundle),
            onDelete: () => onDelete(bundle),
          ),
        );
      },
    );
  }
} 