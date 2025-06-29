import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../cubits/add_car_cubit.dart';
import '../cubits/add_car_state.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';
import '../../../../config/routes/screens_name.dart';

class CarRentalOptionsScreen extends StatefulWidget {
  final CarModel carData;

  const CarRentalOptionsScreen({
    super.key,
    required this.carData,
  });

  @override
  State<CarRentalOptionsScreen> createState() => _CarRentalOptionsScreenState();
}

class _CarRentalOptionsScreenState extends State<CarRentalOptionsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _availableWithoutDriver = false;
  bool _availableWithDriver = false;
  final _dailyPriceController = TextEditingController();
  final _monthlyPriceController = TextEditingController();
  final _yearlyPriceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dailyPriceController.dispose();
    _monthlyPriceController.dispose();
    _yearlyPriceController.dispose();
    super.dispose();
  }

  void _updatePrices(String value) {
    if (value.isNotEmpty) {
      try {
        final dailyPrice = double.parse(value);
        final monthlyPrice =
            (dailyPrice * 30 * 0.9).toStringAsFixed(2); // 10% discount
        final yearlyPrice =
            (dailyPrice * 365 * 0.8).toStringAsFixed(2); // 20% discount

        setState(() {
          _monthlyPriceController.text = monthlyPrice;
          _yearlyPriceController.text = yearlyPrice;
        });
      } catch (e) {
        // Handle invalid number input
        _monthlyPriceController.text = '';
        _yearlyPriceController.text = '';
      }
    } else {
      _monthlyPriceController.text = '';
      _yearlyPriceController.text = '';
    }
  }

  void _submitForm() {
    if (!_availableWithDriver && !_availableWithoutDriver) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rental option'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _availableWithDriver = true;
      _availableWithoutDriver = true;
    });
  }

  void _savePricing() {
    if (_dailyPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the daily rental price'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final options = RentalOptions(
      availableWithoutDriver: _availableWithoutDriver,
      availableWithDriver: _availableWithDriver,
      dailyRentalPrice: double.parse(_dailyPriceController.text),
    );

    final car = widget.carData.copyWith(rentalOptions: options);
    context.read<AddCarCubit>().addCar(car);
  }

  void _navigateToUsagePolicy() {
    if (!_availableWithDriver && !_availableWithoutDriver) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rental option'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_dailyPriceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the daily rental price'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final options = RentalOptions(
      availableWithoutDriver: _availableWithoutDriver,
      availableWithDriver: _availableWithDriver,
      dailyRentalPrice: double.parse(_dailyPriceController.text),
    );

    Navigator.pushNamed(
      context,
      ScreensName.usagePolicyScreen,
      arguments: {
        'car': widget.carData,
        'rentalOptions': options,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCarCubit, AddCarState>(
      listener: (context, state) {
        if (state is AddCarSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rental options saved!'), backgroundColor: Colors.green),
          );
        } else if (state is AddCarError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Rental Options'),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rental Options',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Driver Options
                          Row(
                            children: [
                              Expanded(
                                child: _buildOptionTile(
                                  'Without\nDriver',
                                  _availableWithoutDriver,
                                  (value) {
                                    setState(() {
                                      _availableWithoutDriver = value ?? false;
                                      if (_availableWithoutDriver) {
                                        _availableWithDriver = false;
                                      }
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _buildOptionTile(
                                  'With Driver',
                                  _availableWithDriver,
                                  (value) {
                                    setState(() {
                                      _availableWithDriver = value ?? false;
                                      if (_availableWithDriver) {
                                        _availableWithoutDriver = false;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 32.h),

                          // Pricing Fields
                          if (_availableWithDriver || _availableWithoutDriver) ...[
                            Text(
                              'Set Pricing',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Daily Price
                            TextFormField(
                              controller: _dailyPriceController,
                              decoration: InputDecoration(
                                labelText: 'Daily Rental Price',
                                hintText: 'e.g., 500',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixText: 'EGP',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                              onChanged: _updatePrices,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the daily rental price';
                                }
                                final price = double.tryParse(value);
                                if (price == null || price <= 0) {
                                  return 'Please enter a valid price greater than 0';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),

                            // Monthly Price (Read-only)
                            TextFormField(
                              controller: _monthlyPriceController,
                              decoration: InputDecoration(
                                labelText: 'Monthly Rental Price (10% discount)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixText: 'EGP',
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              enabled: false,
                            ),
                            SizedBox(height: 16.h),

                            // Yearly Price (Read-only)
                            TextFormField(
                              controller: _yearlyPriceController,
                              decoration: InputDecoration(
                                labelText: 'Yearly Rental Price (20% discount)',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixText: 'EGP',
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              enabled: false,
                            ),

                            // Add extra padding at bottom for FAB
                            SizedBox(height: 80.h),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (_availableWithDriver || _availableWithoutDriver)
                Positioned(
                  right: 16.w,
                  bottom: 16.h,
                  child: FloatingActionButton(
                    onPressed: () {
                      if (!_availableWithDriver && !_availableWithoutDriver) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a rental option'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (_formKey.currentState!.validate()) {
                        final options = RentalOptions(
                          availableWithoutDriver: _availableWithoutDriver,
                          availableWithDriver: _availableWithDriver,
                          dailyRentalPrice: double.parse(_dailyPriceController.text),
                        );
                        Navigator.pushNamed(
                          context,
                          ScreensName.usagePolicyScreen,
                          arguments: {
                            'car': widget.carData,
                            'rentalOptions': options,
                          },
                        );
                      }
                    },
                    backgroundColor: const Color(0xFF1a237e),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(String title, bool value, Function(bool?) onChanged) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: value ? const Color(0xFF1a237e) : Colors.grey[300]!,
          width: value ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: value ? FontWeight.bold : FontWeight.normal,
              color: value ? const Color(0xFF1a237e) : Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1a237e),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
