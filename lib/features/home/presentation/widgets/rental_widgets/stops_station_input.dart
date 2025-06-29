import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/features/home/presentation/cubit/car_cubit.dart';
import 'package:test_cark/features/home/presentation/cubit/choose_car_state.dart';

import '../../model/location_model.dart';

class StopsStationInput extends StatefulWidget {
  const StopsStationInput({super.key});

  @override
  State<StopsStationInput> createState() => _StopsStationInputState();
}

class _StopsStationInputState extends State<StopsStationInput> {
  final List<TextEditingController> _controllers = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stops = context.watch<CarCubit>().state.stops;
    if (_controllers.length != stops.length) {
      _controllers.forEach((controller) => controller.dispose());
      _controllers.clear();
      for (var stop in stops) {
        _controllers.add(TextEditingController(text: stop.name));
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewStop() {
    context.read<CarCubit>().addStop(
        LocationModel(name: '', address: '', description: ''));
  }

  void _removeStop(int index) {
    context.read<CarCubit>().removeStop(index);
  }

  void _updateStop(int index, String name) {
    final location = LocationModel(name: name, address: '', description: '');
    context.read<CarCubit>().updateStop(index, location);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarCubit, ChooseCarState>(
      builder: (context, state) {
        // Ensure controllers are in sync with the state
        if (_controllers.length != state.stops.length) {
          _controllers.forEach((c) => c.dispose());
          _controllers.clear();
          _controllers.addAll(state.stops.map((s) => TextEditingController(text: s.name)));
        }

        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Stops Station',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              if (state.stops.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Text(
                      'No stops added yet.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ...List.generate(state.stops.length, (index) {
                _controllers[index].text = state.stops[index].name;
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controllers[index],
                          onChanged: (value) => _updateStop(index, value),
                          decoration: InputDecoration(
                            hintText: 'Enter stop ${index + 1}',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14.sp,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.r),
                              borderSide: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.primary),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 12.h),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () => _removeStop(index),
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Icon(
                            Icons.remove,
                            color: Colors.red,
                            size: 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              // Add new stop button
              GestureDetector(
                onTap: _addNewStop,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Theme.of(context).colorScheme.primary,
                        size: 18.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Add Stop',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 