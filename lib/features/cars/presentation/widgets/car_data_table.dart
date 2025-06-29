import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../home/presentation/widgets/home_widgets/car_card_widget.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';


class CarDataTable extends StatelessWidget {
  final List<CarModel> cars;
  final Function(CarModel) onEdit;
  final Function(CarModel) onDelete;
  final Function(CarModel) onViewDetails;

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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cars.length,
      itemBuilder: (context, index) {
        final car = cars[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: CarCardWidget(
            car: car,
            onTap: () => onViewDetails(car),
            onEdit: () => onEdit(car),
            onDelete: () => onDelete(car),
          ),
        );
      },
    );
  }
} 