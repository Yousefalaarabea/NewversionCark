import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/features/home/presentation/widgets/filter_widgets/car_transmission_widget.dart';

import '../filter_widgets/car_category_widget.dart';
import '../filter_widgets/car_type_widget.dart';
import '../filter_widgets/driver_option_widget.dart';
import '../filter_widgets/fuel_type_widget.dart';

class FilterSectionWidget extends StatelessWidget {
  const FilterSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Car Type, Category, Fuel Type, Driver Option, Transmission
        const CarTypeWidget(),
        SizedBox(height: 0.04.sh),

        // const CarCategoryWidget(),
        // SizedBox(height: 0.04.sh),
        //
        // const FuelTypeWidget(),
        // SizedBox(height: 0.04.sh),
        //
        // const DriverOption(),
        // SizedBox(height: 0.04.sh),
        //
        // const TransmissionWidget(),
        // SizedBox(height: 0.04.sh),
      ],
    );
  }
}
