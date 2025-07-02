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
  void initState() {
    super.initState();
    
    // Initialize form fields with existing usage policy if available
    if (widget.carData.usagePolicy != null) {
      _dailyKmLimitController.text = widget.carData.usagePolicy!.dailyKmLimit.toString();
      _extraKmCostController.text = widget.carData.usagePolicy!.extraKmCost.toString();
      _dailyHourLimitController.text = widget.carData.usagePolicy!.dailyHourLimit.toString();
      _extraHourCostController.text = widget.carData.usagePolicy!.extraHourCost.toString();
    }
  }

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

      // Create complete car with all data from three steps
      final car = widget.carData.copyWith(
        rentalOptions: widget.rentalOptions,
        usagePolicy: policy,
      );

      // Finally call addCar with complete data
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
              // Add extra padding at bottom for buttons
              SizedBox(height: 80.h),
            ],
          );
        },
      ),
      // Replace FloatingActionButton with bottom buttons
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate back to CarRentalOptionsScreen with current data
                  final currentCar = widget.carData.copyWith(
                    rentalOptions: widget.rentalOptions,
                    usagePolicy: _formKey.currentState!.validate() 
                        ? CarUsagePolicy(
                            dailyKmLimit: int.parse(_dailyKmLimitController.text),
                            extraKmCost: double.parse(_extraKmCostController.text),
                            dailyHourLimit: int.parse(_dailyHourLimitController.text),
                            extraHourCost: double.parse(_extraHourCostController.text),
                          )
                        : null,
                  );
                  Navigator.pop(context, currentCar);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black87,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Previous'),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1a237e),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
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