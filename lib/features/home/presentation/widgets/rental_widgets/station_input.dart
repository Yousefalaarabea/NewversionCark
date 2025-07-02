import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/place_suggestions_service.dart'; // غير مستخدم في هذا المقتطف
import '../../cubit/car_cubit.dart';
import '../../cubit/choose_car_state.dart';
import '../../model/location_model.dart';
import '../../screens/booking_screens/location_search_page.dart'; // الشاشة التي تم إصلاحها
import 'package:flutter_map/flutter_map.dart'; // يستخدم لـ LatLng
import 'package:latlong2/latlong.dart'; // يستخدم لـ LatLng

class StationInput extends StatefulWidget {
  final bool isPickup; // true => pickup, false => return

  const StationInput({required this.isPickup, super.key});

  @override
  State<StationInput> createState() => _StationInputState();
}

class _StationInputState extends State<StationInput> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    final cubit = context.read<CarCubit>();
    final initialStation = widget.isPickup ? cubit.state.pickupStation : cubit.state.returnStation;
    if (initialStation != null) {
      _controller.text = initialStation.name;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _openLocationSearch() async {
    setState(() {
      _isLoading = true;
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

        if (widget.isPickup) {
          context.read<CarCubit>().setPickupStation(location);
          print('DEBUG - Set pickup station: ${location.name}');
        } else {
          context.read<CarCubit>().setReturnStation(location);
          print('DEBUG - Set return station: ${location.name}');
        }

        // Show success feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('${widget.isPickup ? 'Pickup' : 'Return'} location selected'),
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
      print('Error selecting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error selecting location: $e'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CarCubit, ChooseCarState>(
      listenWhen: (previous, current) {
        return widget.isPickup
            ? previous.pickupStation != current.pickupStation
            : previous.returnStation != current.returnStation;
      },
      listener: (context, state) {
        final stationValue = widget.isPickup ? state.pickupStation : state.returnStation;
        if (stationValue != null && _controller.text != stationValue.name) {
          _controller.text = stationValue.name;
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              widget.isPickup ? 'Pick-up Location' : 'Return Location',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          
          // Input Field
          GestureDetector(
            onTap: _isLoading ? null : _openLocationSearch,
            child: AbsorbPointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: _controller.text.isNotEmpty 
                        ? Colors.green.withOpacity(0.3)
                        : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    width: 1.5,
                  ),
                  color: _controller.text.isNotEmpty 
                      ? Colors.green.withOpacity(0.05)
                      : null,
                ),
                child: TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: widget.isPickup 
                        ? 'Select Pick-up Location' 
                        : 'Select Return Location',
                    prefixIcon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Icon(
                            _controller.text.isNotEmpty 
                                ? Icons.location_on 
                                : Icons.location_on_outlined,
                            color: _controller.text.isNotEmpty 
                                ? Colors.green 
                                : Theme.of(context).hintColor,
                          ),
                    suffixIcon: _controller.text.isNotEmpty
                        ? Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20.sp,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Helper text
          if (_controller.text.isNotEmpty)
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
          
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}