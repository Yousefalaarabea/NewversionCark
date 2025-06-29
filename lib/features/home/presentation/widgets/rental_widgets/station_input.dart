import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/utils/place_suggestions_service.dart';
import '../../cubit/car_cubit.dart';
import '../../cubit/choose_car_state.dart';
import '../../model/location_model.dart';
import '../../screens/booking_screens/location_search_page.dart';

class StationInput extends StatefulWidget {
  final bool isPickup; // true => pickup, false => return

  const StationInput({required this.isPickup, super.key});

  @override
  State<StationInput> createState() => _StationInputState();
}

class _StationInputState extends State<StationInput> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

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

  void _onTextChanged(String text) {
    final cubit = context.read<CarCubit>();
    final location = LocationModel(name: text, address: '', description: '');
    if (widget.isPickup) {
      cubit.setPickupStation(location);
    } else {
      cubit.setReturnStation(location);
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
        children: [
          TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onTextChanged,
            decoration: InputDecoration(
              hintText: widget.isPickup ? 'Enter Pick-up Location' : 'Enter Return Station',
              prefixIcon: Icon(
                Icons.location_on,
                color: Theme.of(context).hintColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
