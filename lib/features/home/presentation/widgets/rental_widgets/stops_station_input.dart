import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:test_cark/features/home/presentation/cubit/car_cubit.dart';
import 'package:test_cark/features/home/presentation/cubit/choose_car_state.dart';
import '../../model/location_model.dart';
import '../../screens/booking_screens/location_search_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class StopsStationInput extends StatefulWidget {
  const StopsStationInput({super.key});

  @override
  State<StopsStationInput> createState() => _StopsStationInputState();
}

class _StopsStationInputState extends State<StopsStationInput> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stops = context.watch<CarCubit>().state.stops;
    if (_controllers.length != stops.length) {
      _controllers.forEach((controller) => controller.dispose());
      _focusNodes.forEach((focusNode) => focusNode.dispose());
      _controllers.clear();
      _focusNodes.clear();
      for (var stop in stops) {
        _controllers.add(TextEditingController(text: stop.name));
        _focusNodes.add(FocusNode());
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
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

  Future<void> _selectStopLocation(int index) async {
    setState(() {
      // Show loading state for this specific stop
    });

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MapLocationSearchPage(),
        ),
      );

      if (result != null && result is Map<String, dynamic>) {
        final latLng = result['latLng'] as LatLng;
        final address = result['address'] as String;

        final location = LocationModel(
          name: address,
          address: address,
          description: '',
          lat: latLng.latitude,
          lng: latLng.longitude,
        );

        context.read<CarCubit>().updateStop(index, location);

        // Show success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Stop ${index + 1} location selected'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('Error selecting stop location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error selecting stop location: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarCubit, ChooseCarState>(
      builder: (context, state) {
        // Ensure controllers are in sync with the state
        if (_controllers.length != state.stops.length) {
          _controllers.forEach((c) => c.dispose());
          _focusNodes.forEach((f) => f.dispose());
          _controllers.clear();
          _focusNodes.clear();
          _controllers.addAll(state.stops.map((s) => TextEditingController(text: s.name)));
          _focusNodes.addAll(List.generate(state.stops.length, (index) => FocusNode()));
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
                    child: Column(
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 48.sp,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'No stops added yet.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Add stops to your journey',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ...List.generate(state.stops.length, (index) {
                _controllers[index].text = state.stops[index].name;
                final hasLocation = state.stops[index].name.isNotEmpty;
                
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stop label
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Text(
                          'Stop ${index + 1}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      
                      // Location input field
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectStopLocation(index),
                              child: AbsorbPointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: hasLocation 
                                          ? Colors.green.withOpacity(0.3)
                                          : Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                    color: hasLocation 
                                        ? Colors.green.withOpacity(0.05)
                                        : null,
                                  ),
                                  child: TextFormField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      hintText: 'Select Stop ${index + 1} Location',
                                      prefixIcon: Icon(
                                        hasLocation 
                                            ? Icons.location_on 
                                            : Icons.location_on_outlined,
                                        color: hasLocation 
                                            ? Colors.green 
                                            : Theme.of(context).hintColor,
                                      ),
                                      suffixIcon: hasLocation
                                          ? Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 20.sp,
                                            )
                                          : null,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12.w,
                                        vertical: 12.h,
                                      ),
                                    ),
                                  ),
                                ),
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
                      
                      // Helper text
                      if (hasLocation)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            'Tap to change location',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600],
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