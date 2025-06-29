import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/styles_manager.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';
import '../widgets/car_detail_section.dart';
import 'add_car_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/add_car_cubit.dart';
import '../cubits/add_car_state.dart';

class ViewCarDetailsScreen extends StatelessWidget {
  final CarModel car;

  const ViewCarDetailsScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCarCubit, AddCarState>(
      listener: (context, state) {
        if (state is AddCarSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Car updated!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else if (state is AddCarError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('${car.brand} ${car.model}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddCarScreen(carToEdit: car),
                    ),
                  ).then((_) {
                    Navigator.pop(context); // Return to previous screen after edit
                  });
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Car Image Section
                Container(
                  height: 200.h,
                  width: double.infinity,
                  decoration: StylesManager.carImageDecoration,
                  child: Icon(
                    Icons.directions_car,
                    size: 100.sp,
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: 16.h),

                // Basic Information Section
                CarDetailSection(
                  title: 'Basic Information',
                  details: [
                    MapEntry('Brand', car.brand),
                    MapEntry('Model', car.model),
                    MapEntry('Year', car.year.toString()),
                    MapEntry('Color', car.color),
                    MapEntry('Plate Number', car.plateNumber),
                  ],
                ),

                // Technical Details Section
                CarDetailSection(
                  title: 'Technical Details',
                  details: [
                    MapEntry('Car Type', car.carType),
                    MapEntry('Category', car.carCategory),
                    MapEntry('Transmission', car.transmissionType),
                    MapEntry('Fuel Type', car.fuelType),
                    MapEntry('Seating Capacity', '${car.seatingCapacity} seats'),
                  ],
                ),

                // Status Section
                CarDetailSection(
                  title: 'Current Status',
                  details: [
                    MapEntry('Odometer Reading', '${car.currentOdometerReading} km'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 