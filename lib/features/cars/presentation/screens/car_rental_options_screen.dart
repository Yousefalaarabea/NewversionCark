import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';
import '../../../../config/routes/screens_name.dart';
import '../../../auth/presentation/widgets/image_upload_widget.dart';
import '../cubits/add_car_cubit.dart';
import '../cubits/add_car_state.dart';

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
  File? _driverLicenseImage;
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
                                    });
                                  },
                                  icon: FontAwesomeIcons.idCard,
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
                                    });
                                  },
                                  icon: FontAwesomeIcons.userTie,
                                ),
                              ),
                            ],
                          ),
                          if (_availableWithDriver) ...[
                            SizedBox(height: 24.h),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: ImageUploadWidget(
                                  label: 'Upload Driving License (Camera Only)',
                                  icon: Icons.file_upload,
                                  onImageSelected: (file) {
                                    setState(() {
                                      _driverLicenseImage = file;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
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
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Daily Price',
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              onChanged: _updatePrices,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the daily rental price';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),

                            // Monthly Price (Read-only)
                            TextFormField(
                              controller: _monthlyPriceController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Monthly Price (auto-calculated)',
                                prefixIcon: Icon(Icons.calendar_month),
                              ),
                            ),
                            SizedBox(height: 16.h),

                            // Yearly Price (Read-only)
                            TextFormField(
                              controller: _yearlyPriceController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Yearly Price (auto-calculated)',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                            ),

                            // Add extra padding at bottom for FAB
                            SizedBox(height: 80.h),
                          ],
                          SizedBox(height: 32.h),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _navigateToUsagePolicy,
                              icon: const Icon(Icons.arrow_forward, color: Colors.white),
                              label: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 24.w),
                                child: Text(
                                  'Continue',
                                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1a237e),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(String title, bool value, Function(bool?) onChanged, {IconData? icon}) {
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
          if (icon != null) ...[
            FaIcon(icon, size: 28.sp, color: value ? const Color(0xFF1a237e) : Colors.black54),
            SizedBox(height: 8.h),
          ],
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
