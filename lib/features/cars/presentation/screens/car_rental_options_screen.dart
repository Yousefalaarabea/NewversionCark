// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:test_cark/features/home/presentation/model/car_model.dart';
// import '../../../../config/routes/screens_name.dart';
// import '../../../auth/presentation/widgets/image_upload_widget.dart';
// import '../cubits/add_car_cubit.dart';
// import '../cubits/add_car_state.dart';
//
// class CarRentalOptionsScreen extends StatefulWidget {
//   final CarModel carData;
//
//   const CarRentalOptionsScreen({
//     super.key,
//     required this.carData,
//   });
//
//   @override
//   State<CarRentalOptionsScreen> createState() => _CarRentalOptionsScreenState();
// }
//
// class _CarRentalOptionsScreenState extends State<CarRentalOptionsScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//
//   bool _availableWithoutDriver = false;
//   bool _availableWithDriver = false;
//   File? _driverLicenseImage;
//   final _dailyPriceController = TextEditingController();
//   final _monthlyPriceController = TextEditingController();
//   final _yearlyPriceController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//
//   @override
//   void initState() {
//     super.initState();
//
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));
//
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0.0, 0.5),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeOutCubic,
//     ));
//
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _dailyPriceController.dispose();
//     _monthlyPriceController.dispose();
//     _yearlyPriceController.dispose();
//     super.dispose();
//   }
//
//   void _updatePrices(String value) {
//     if (value.isNotEmpty) {
//       try {
//         final dailyPrice = double.parse(value);
//         final monthlyPrice =
//             (dailyPrice * 30 * 0.9).toStringAsFixed(2); // 10% discount
//         final yearlyPrice =
//             (dailyPrice * 365 * 0.8).toStringAsFixed(2); // 20% discount
//
//         setState(() {
//           _monthlyPriceController.text = monthlyPrice;
//           _yearlyPriceController.text = yearlyPrice;
//         });
//       } catch (e) {
//         // Handle invalid number input
//         _monthlyPriceController.text = '';
//         _yearlyPriceController.text = '';
//       }
//     } else {
//       _monthlyPriceController.text = '';
//       _yearlyPriceController.text = '';
//     }
//   }
//
//   void _submitForm() {
//     if (!_availableWithDriver && !_availableWithoutDriver) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select a rental option'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     setState(() {
//       _availableWithDriver = true;
//       _availableWithoutDriver = true;
//     });
//   }
//
//   void _savePricing() {
//     if (_dailyPriceController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter the daily rental price'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     final options = RentalOptions(
//       availableWithoutDriver: _availableWithoutDriver,
//       availableWithDriver: _availableWithDriver,
//       dailyRentalPrice: double.parse(_dailyPriceController.text),
//     );
//
//     final car = widget.carData.copyWith(rentalOptions: options);
//     context.read<AddCarCubit>().addCar(car);
//   }
//
//   void _navigateToUsagePolicy() {
//     if (!_availableWithDriver && !_availableWithoutDriver) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select a rental option'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     if (_dailyPriceController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter the daily rental price'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     final options = RentalOptions(
//       availableWithoutDriver: _availableWithoutDriver,
//       availableWithDriver: _availableWithDriver,
//       dailyRentalPrice: double.parse(_dailyPriceController.text),
//     );
//
//     Navigator.pushNamed(
//       context,
//       ScreensName.usagePolicyScreen,
//       arguments: {
//         'car': widget.carData,
//         'rentalOptions': options,
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<AddCarCubit, AddCarState>(
//       listener: (context, state) {
//         if (state is AddCarSuccess) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Rental options saved!'), backgroundColor: Colors.green),
//           );
//         } else if (state is AddCarError) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(state.message), backgroundColor: Colors.red),
//           );
//         }
//       },
//       builder: (context, state) {
//         return Scaffold(
//           appBar: AppBar(
//             title: const Text('Rental Options'),
//           ),
//           body: Stack(
//             children: [
//               SingleChildScrollView(
//                 padding: EdgeInsets.all(16.w),
//                 child: FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: SlideTransition(
//                     position: _slideAnimation,
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Rental Options',
//                             style: TextStyle(
//                               fontSize: 20.sp,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           SizedBox(height: 24.h),
//
//                           // Driver Options
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: _buildOptionTile(
//                                   'Without\nDriver',
//                                   _availableWithoutDriver,
//                                   (value) {
//                                     setState(() {
//                                       _availableWithoutDriver = value ?? false;
//                                     });
//                                   },
//                                   icon: FontAwesomeIcons.idCard,
//                                 ),
//                               ),
//                               SizedBox(width: 16.w),
//                               Expanded(
//                                 child: _buildOptionTile(
//                                   'With Driver',
//                                   _availableWithDriver,
//                                   (value) {
//                                     setState(() {
//                                       _availableWithDriver = value ?? false;
//                                     });
//                                   },
//                                   icon: FontAwesomeIcons.userTie,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           if (_availableWithDriver) ...[
//                             SizedBox(height: 24.h),
//                             FadeTransition(
//                               opacity: _fadeAnimation,
//                               child: SlideTransition(
//                                 position: _slideAnimation,
//                                 child: ImageUploadWidget(
//                                   label: 'Upload Driving License (Camera Only)',
//                                   icon: Icons.file_upload,
//                                   onImageSelected: (file) {
//                                     setState(() {
//                                       _driverLicenseImage = file;
//                                     });
//                                   },
//                                 ),
//                               ),
//                             ),
//                           ],
//                           SizedBox(height: 32.h),
//
//                           // Pricing Fields
//                           if (_availableWithDriver || _availableWithoutDriver) ...[
//                             Text(
//                               'Set Pricing',
//                               style: TextStyle(
//                                 fontSize: 18.sp,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 16.h),
//
//                             // Daily Price
//                             TextFormField(
//                               controller: _dailyPriceController,
//                               keyboardType: TextInputType.number,
//                               decoration: InputDecoration(
//                                 labelText: 'Daily Price',
//                                 prefixIcon: Icon(Icons.attach_money),
//                               ),
//                               onChanged: _updatePrices,
//                               validator: (value) {
//                                 if (value == null || value.isEmpty) {
//                                   return 'Please enter the daily rental price';
//                                 }
//                                 if (double.tryParse(value) == null) {
//                                   return 'Please enter a valid number';
//                                 }
//                                 return null;
//                               },
//                             ),
//                             SizedBox(height: 16.h),
//
//                             // Monthly Price (Read-only)
//                             TextFormField(
//                               controller: _monthlyPriceController,
//                               readOnly: true,
//                               decoration: InputDecoration(
//                                 labelText: 'Monthly Price (auto-calculated)',
//                                 prefixIcon: Icon(Icons.calendar_month),
//                               ),
//                             ),
//                             SizedBox(height: 16.h),
//
//                             // Yearly Price (Read-only)
//                             TextFormField(
//                               controller: _yearlyPriceController,
//                               readOnly: true,
//                               decoration: InputDecoration(
//                                 labelText: 'Yearly Price (auto-calculated)',
//                                 prefixIcon: Icon(Icons.calendar_today),
//                               ),
//                             ),
//
//                             // Add extra padding at bottom for FAB
//                             SizedBox(height: 80.h),
//                           ],
//                           SizedBox(height: 32.h),
//                           Center(
//                             child: ElevatedButton.icon(
//                               onPressed: _navigateToUsagePolicy,
//                               icon: const Icon(Icons.arrow_forward, color: Colors.white),
//                               label: Padding(
//                                 padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 24.w),
//                                 child: Text(
//                                   'Continue',
//                                   style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFF1a237e),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 elevation: 4,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildOptionTile(String title, bool value, Function(bool?) onChanged, {IconData? icon}) {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(
//           color: value ? const Color(0xFF1a237e) : Colors.grey[300]!,
//           width: value ? 2 : 1,
//         ),
//       ),
//       child: Column(
//         children: [
//           if (icon != null) ...[
//             FaIcon(icon, size: 28.sp, color: value ? const Color(0xFF1a237e) : Colors.black54),
//             SizedBox(height: 8.h),
//           ],
//           Text(
//             title,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: value ? FontWeight.bold : FontWeight.normal,
//               color: value ? const Color(0xFF1a237e) : Colors.black87,
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Checkbox(
//             value: value,
//             onChanged: onChanged,
//             activeColor: const Color(0xFF1a237e),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(4),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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

    final rentalOptions = RentalOptions(
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
