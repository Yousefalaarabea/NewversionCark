import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart'; // تأكد من إضافة هذا الباكج في pubspec.yaml
import 'package:test_cark/features/home/presentation/model/car_model.dart';
import '../../../../config/routes/screens_name.dart';
import '../../../auth/presentation/widgets/image_upload_widget.dart';
import '../cubits/add_car_cubit.dart';
import '../cubits/add_car_state.dart';
import 'package:test_cark/features/cars/presentation/models/car_rental_options.dart';

class CarRentalOptionsScreen extends StatefulWidget {
  final CarModel carData;

  const CarRentalOptionsScreen({super.key, required this.carData});

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

  final _dailyPriceWithDriverController = TextEditingController();
  final _monthlyPriceWithDriverController = TextEditingController();
  final _yearlyPriceWithDriverController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dailyPriceController.dispose();
    _monthlyPriceController.dispose();
    _yearlyPriceController.dispose();
    _dailyPriceWithDriverController.dispose();
    _monthlyPriceWithDriverController.dispose();
    _yearlyPriceWithDriverController.dispose();
    super.dispose();
  }

  void _updatePrices(String value, {bool withDriver = false}) {
    if (value.isNotEmpty) {
      try {
        final daily = double.parse(value);
        final monthly = (daily * 30 * 0.9).toStringAsFixed(2);
        final yearly = (daily * 365 * 0.8).toStringAsFixed(2);

        setState(() {
          if (withDriver) {
            _monthlyPriceWithDriverController.text = monthly;
            _yearlyPriceWithDriverController.text = yearly;
          } else {
            _monthlyPriceController.text = monthly;
            _yearlyPriceController.text = yearly;
          }
        });
      } catch (_) {
        setState(() {
          if (withDriver) {
            _monthlyPriceWithDriverController.clear();
            _yearlyPriceWithDriverController.clear();
          } else {
            _monthlyPriceController.clear();
            _yearlyPriceController.clear();
          }
        });
      }
    } else {
      setState(() {
        if (withDriver) {
          _monthlyPriceWithDriverController.clear();
          _yearlyPriceWithDriverController.clear();
        } else {
          _monthlyPriceController.clear();
          _yearlyPriceController.clear();
        }
      });
    }
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

    if ((_availableWithoutDriver && _dailyPriceController.text.isEmpty) ||
        (_availableWithDriver &&
            _dailyPriceWithDriverController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Please enter the daily rental price for selected options'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final rentalOptions = CarRentalOptions(
      availableWithoutDriver: _availableWithoutDriver,
      availableWithDriver: _availableWithDriver,
      dailyRentalPrice:
          _availableWithoutDriver && _dailyPriceController.text.isNotEmpty
              ? double.tryParse(_dailyPriceController.text)
              : null,
      monthlyRentalPrice:
          _availableWithoutDriver && _monthlyPriceController.text.isNotEmpty
              ? double.tryParse(_monthlyPriceController.text)
              : null,
      yearlyRentalPrice:
          _availableWithoutDriver && _yearlyPriceController.text.isNotEmpty
              ? double.tryParse(_yearlyPriceController.text)
              : null,
      dailyRentalPriceWithDriver: _availableWithDriver &&
              _dailyPriceWithDriverController.text.isNotEmpty
          ? double.tryParse(_dailyPriceWithDriverController.text)
          : null,
      monthlyPriceWithDriver: _availableWithDriver &&
              _monthlyPriceWithDriverController.text.isNotEmpty
          ? double.tryParse(_monthlyPriceWithDriverController.text)
          : null,
      yearlyPriceWithDriver: _availableWithDriver &&
              _yearlyPriceWithDriverController.text.isNotEmpty
          ? double.tryParse(_yearlyPriceWithDriverController.text)
          : null,
    );

    Navigator.pushNamed(
      context,
      ScreensName.usagePolicyScreen,
      arguments: {
        'car': widget.carData,
        'rentalOptions': rentalOptions,
      },
    );
  }

  Widget _buildPricingSection({
    required String title,
    required TextEditingController dailyCtrl,
    required TextEditingController monthlyCtrl,
    required TextEditingController yearlyCtrl,
    required bool withDriver,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1a237e),
          ),
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: dailyCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Daily Price',
            prefixIcon: const Icon(Icons.attach_money),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Color(0xFF1a237e), width: 2),
            ),
          ),
          onChanged: (value) => _updatePrices(value, withDriver: withDriver),
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
        TextFormField(
          controller: monthlyCtrl,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Monthly Price (auto-calculated)',
            prefixIcon: const Icon(Icons.calendar_month),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Color(0xFF1a237e), width: 2),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: yearlyCtrl,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Yearly Price (auto-calculated)',
            prefixIcon: const Icon(Icons.calendar_today),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: const BorderSide(color: Color(0xFF1a237e), width: 2),
            ),
          ),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCarCubit, AddCarState>(
      listener: (context, state) {
        if (state is AddCarSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Rental options saved!'),
                backgroundColor: Colors.green),
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
            centerTitle: true,
            backgroundColor: const Color(0xFF1a237e),
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
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
                      SizedBox(height: 24.h),
                      Text(
                        'Choose How to Rent Your Car',
                        // Updated for owner's perspective
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildOptionTile(
                              title: 'Self-Drive Rental',
                              // Owner's perspective
                              description:
                                  'Offer your car for independent driving.',
                              // Owner's perspective
                              isSelected: _availableWithoutDriver,
                              onTap: () {
                                setState(() {
                                  _availableWithoutDriver =
                                      !_availableWithoutDriver;
                                });
                              },
                              icon: LucideIcons.car,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: _buildOptionTile(
                              title: 'With Driver Rental',
                              // Owner's perspective
                              description:
                                  'Provide your car with a professional driver.',
                              // Owner's perspective
                              isSelected: _availableWithDriver,
                              onTap: () {
                                setState(() {
                                  _availableWithDriver = !_availableWithDriver;
                                });
                              },
                              icon: LucideIcons.userCheck,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SizeTransition(
                              sizeFactor: animation,
                              axisAlignment: -1.0,
                              child: child,
                            ),
                          );
                        },
                        child: _availableWithoutDriver
                            ? _buildPricingSection(
                                title: 'Pricing (Self-Drive)',
                                dailyCtrl: _dailyPriceController,
                                monthlyCtrl: _monthlyPriceController,
                                yearlyCtrl: _yearlyPriceController,
                                withDriver: false,
                              )
                            : const SizedBox.shrink(),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SizeTransition(
                              sizeFactor: animation,
                              axisAlignment: -1.0,
                              child: child,
                            ),
                          );
                        },
                        child: _availableWithDriver
                            ? Column(
                                children: [
                                  _buildPricingSection(
                                    title: 'Pricing (With Driver)',
                                    dailyCtrl: _dailyPriceWithDriverController,
                                    monthlyCtrl:
                                        _monthlyPriceWithDriverController,
                                    yearlyCtrl:
                                        _yearlyPriceWithDriverController,
                                    withDriver: true,
                                  ),
                                  FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: SlideTransition(
                                      position: _slideAnimation,
                                      child: ImageUploadWidget(
                                        label:
                                            'Upload Driving License (Driver\'s)',
                                        // Clarified for owner
                                        icon: Icons.camera_alt,
                                        onImageSelected: (file) {
                                          setState(() {
                                            _driverLicenseImage = file;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 32.h),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                      SizedBox(height: 32.h),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _navigateToUsagePolicy,
                          label: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.h, horizontal: 24.w),
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1a237e),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                            elevation: 4,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h), // Add some bottom padding
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(20.w),
        // Use a fixed height or min/max height if you want more control
        // constraints: BoxConstraints(minHeight: 180.h), // Example
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFe3f2fd) : Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF1a237e) : Colors.grey.shade300,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF1a237e).withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            if (!isSelected)
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40.sp,
              color:
                  isSelected ? const Color(0xFF1a237e) : Colors.grey.shade600,
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF1a237e) : Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: isSelected
                    ? const Color(0xFF1a237e).withOpacity(0.8)
                    : Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 10.h),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: const Color(0xFF1a237e),
                size: 24.sp,
              )
            else
              Icon(
                Icons.radio_button_off,
                color: Colors.grey.shade400,
                size: 24.sp,
              ),
          ],
        ),
      ),
    );
  }
}
