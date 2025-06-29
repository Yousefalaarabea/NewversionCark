import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'car_category_widget.dart';
import 'car_transmission_widget.dart';
import 'car_type_widget.dart';
import 'driver_option_widget.dart';
import 'fuel_type_widget.dart';

class CarFilters extends StatelessWidget {
  const CarFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Car Type Filter Widget
        const CarTypeWidget(),

        SizedBox(height: 0.05.sh),

        // Car Category Filter Widget
        const CarCategoryWidget(),

        SizedBox(height: 0.05.sh),

        // Car Transmission Filter Widget
        const CarTransmissionWidget(),

        SizedBox(height: 0.05.sh),

        // Driver Option Filter Widget
        const DriverOptionWidget(),

        SizedBox(height: 0.05.sh),

        // Car Fuel Type Filter Widget
        const FuelTypeWidget(),
      ],
    );
  }
}
