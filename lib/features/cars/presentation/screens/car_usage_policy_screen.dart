import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../home/presentation/model/car_model.dart';
import '../cubits/add_car_cubit.dart';
import '../cubits/add_car_state.dart';
import '../models/car_usage_policy.dart';

class CarUsagePolicyScreen extends StatefulWidget {
  final CarModel carData;
  final RentalOptions rentalOptions;

  const CarUsagePolicyScreen({
    super.key,
    required this.carData,
    required this.rentalOptions,
  });

  @override
  State<CarUsagePolicyScreen> createState() => _CarUsagePolicyScreenState();
}

class _CarUsagePolicyScreenState extends State<CarUsagePolicyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dailyKmLimitController = TextEditingController();
  final _extraKmCostController = TextEditingController();
  final _dailyHourLimitController = TextEditingController();
  final _extraHourCostController = TextEditingController();

  @override
  void dispose() {
    _dailyKmLimitController.dispose();
    _extraKmCostController.dispose();
    _dailyHourLimitController.dispose();
    _extraHourCostController.dispose();
    super.dispose();
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final policy = CarUsagePolicy(
        dailyKmLimit: int.parse(_dailyKmLimitController.text),
        extraKmCost: double.parse(_extraKmCostController.text),
        dailyHourLimit: int.parse(_dailyHourLimitController.text),
        extraHourCost: double.parse(_extraHourCostController.text),
      );

      final car = widget.carData.copyWith(
        rentalOptions: widget.rentalOptions,
      );

      context.read<AddCarCubit>().addCar(car);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usage Policy'),
      ),
      body: BlocConsumer<AddCarCubit, AddCarState>(
        listener: (context, state) {
          if (state is AddCarSuccess) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/ownerNavigationScreen',
              (route) => false,
            );
          } else if (state is AddCarError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AddCarLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Set Usage Limits',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      _buildInputField(
                        controller: _dailyKmLimitController,
                        label: 'Daily Kilometer Limit',
                        hint: 'e.g., 200',
                        suffix: 'KM',
                        inputType: TextInputType.number,
                      ),
                      SizedBox(height: 16.h),
                      _buildInputField(
                        controller: _extraKmCostController,
                        label: 'Extra Kilometer Cost',
                        hint: 'e.g., 2.5',
                        suffix: 'EGP',
                        inputType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      SizedBox(height: 16.h),
                      _buildInputField(
                        controller: _dailyHourLimitController,
                        label: 'Daily Hour Limit',
                        hint: 'e.g., 8',
                        suffix: 'Hours',
                        inputType: TextInputType.number,
                      ),
                      SizedBox(height: 16.h),
                      _buildInputField(
                        controller: _extraHourCostController,
                        label: 'Extra Hour Cost',
                        hint: 'e.g., 10',
                        suffix: 'EGP',
                        inputType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 16.w,
                bottom: 16.h,
                child: FloatingActionButton(
                  onPressed: _submitForm,
                  backgroundColor: const Color(0xFF1a237e),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    required TextInputType inputType,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      keyboardType: inputType,
      validator: _validateNumber,
      inputFormatters: [
        if (inputType == TextInputType.number)
          FilteringTextInputFormatter.digitsOnly
        else
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
    );
  }
} 