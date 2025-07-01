// import 'dart:io';
//
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/utils/assets_manager.dart';
// import '../../../../core/utils/text_manager.dart';
// import '../../../../core/services/notification_service.dart';
// import 'package:test_cark/features/home/presentation/model/car_model.dart';
// import '../../../auth/presentation/cubits/auth_cubit.dart';
// import '../widgets/add_car_form.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../cubits/add_car_cubit.dart';
// import '../cubits/add_car_state.dart';
// import 'package:image_picker/image_picker.dart';
//
// class AddCarScreen extends StatefulWidget {
//   final CarModel? carToEdit;
//
//   const AddCarScreen({super.key, this.carToEdit});
//
//   @override
//   State<AddCarScreen> createState() => _AddCarScreenState();
// }
//
// class _AddCarScreenState extends State<AddCarScreen> {
//   late final GlobalKey<FormState> _formKey;
//   late final TextEditingController _modelController;
//   late final TextEditingController _brandController;
//   late final TextEditingController _carTypeController;
//   late final TextEditingController _carCategoryController;
//   late final TextEditingController _plateNumberController;
//   late final TextEditingController _yearController;
//   late final TextEditingController _colorController;
//   late final TextEditingController _seatingCapacityController;
//   late final TextEditingController _transmissionTypeController;
//   late final TextEditingController _fuelTypeController;
//   late final TextEditingController _odometerController;
//
//   File? _carImage;
//   final ImagePicker _picker = ImagePicker();
//
//   @override
//   void initState() {
//     super.initState();
//     _formKey = GlobalKey<FormState>();
//     _modelController = TextEditingController(text: widget.carToEdit?.model);
//     _brandController = TextEditingController(text: widget.carToEdit?.brand);
//     _carTypeController = TextEditingController(text: widget.carToEdit?.carType);
//     _carCategoryController = TextEditingController(text: widget.carToEdit?.carCategory);
//     _plateNumberController = TextEditingController(text: widget.carToEdit?.plateNumber);
//     _yearController = TextEditingController(text: widget.carToEdit?.year?.toString() ?? '');
//     _colorController = TextEditingController(text: widget.carToEdit?.color);
//     _seatingCapacityController = TextEditingController(text: widget.carToEdit?.seatingCapacity?.toString() ?? '');
//     _transmissionTypeController = TextEditingController(text: widget.carToEdit?.transmissionType);
//     _fuelTypeController = TextEditingController(text: widget.carToEdit?.fuelType);
//     _odometerController = TextEditingController(text: widget.carToEdit?.currentOdometerReading?.toString() ?? '');
//   }
//
//   @override
//   void dispose() {
//     _modelController.dispose();
//     _brandController.dispose();
//     _carTypeController.dispose();
//     _carCategoryController.dispose();
//     _plateNumberController.dispose();
//     _yearController.dispose();
//     _colorController.dispose();
//     _seatingCapacityController.dispose();
//     _transmissionTypeController.dispose();
//     _fuelTypeController.dispose();
//     _odometerController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<AddCarCubit, AddCarState>(
//       listener: (context, state) {
//         if (state is AddCarSuccess) {
//           context.read<AddCarCubit>().fetchCarsFromServer();
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Operation completed successfully!'),
//               backgroundColor: Colors.green,
//               duration: const Duration(seconds: 2),
//             ),
//           );
//         } else if (state is AddCarError) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.message),
//               backgroundColor: Colors.red,
//               duration: const Duration(seconds: 3),
//             ),
//           );
//         }
//       },
//       builder: (context, state) {
//         return BlocBuilder<AuthCubit, AuthState>(
//           builder: (context, state) {
//             final authCubit = context.read<AuthCubit>();
//             return Scaffold(
//               appBar: AppBar(
//                 title: Text(widget.carToEdit != null
//                     ? 'Edit Car'
//                     : TextManager.addCarTitle.tr()),
//               ),
//               body: Stack(
//                 children: [
//                   SingleChildScrollView(
//                     padding: EdgeInsets.all(16.w),
//                     child: Column(
//                       children: [
//                         // Logo Section
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Image.asset(AssetsManager.carSignUp, height: 0.05.sh),
//                             SizedBox(width: 0.02.sw),
//                             Image.asset(AssetsManager.carkSignUp, height: 0.03.sh),
//                           ],
//                         ),
//                         SizedBox(height: 24.h),
//
//                         // Car Photo Section
//                         GestureDetector(
//                           onTap: () async {
//                             final pickedFile = await _picker.pickImage(source: ImageSource.camera);
//                             if (pickedFile != null) {
//                               setState(() {
//                                 _carImage = File(pickedFile.path);
//                               });
//                             }
//                           },
//                           child: AnimatedContainer(
//                             duration: Duration(milliseconds: 400),
//                             curve: Curves.easeInOut,
//                             width: 150.w,
//                             height: 150.w,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[200],
//                               borderRadius: BorderRadius.circular(10.r),
//                               border: Border.all(color: Colors.grey, width: 1.w),
//                               boxShadow: _carImage != null
//                                   ? [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.1),
//                                         blurRadius: 8,
//                                         offset: Offset(0, 4),
//                                       ),
//                                     ]
//                                   : [],
//                             ),
//                             child: _carImage != null
//                                 ? ClipRRect(
//                                     borderRadius: BorderRadius.circular(10.r),
//                                     child: Image.file(
//                                       _carImage!,
//                                       fit: BoxFit.cover,
//                                       width: double.infinity,
//                                       height: double.infinity,
//                                     ),
//                                   )
//                                 : Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(
//                                         Icons.camera_alt,
//                                         size: 50.w,
//                                         color: Colors.grey[600],
//                                       ),
//                                       SizedBox(height: 8.h),
//                                       Text(
//                                         'Add Car Photo',
//                                         style: TextStyle(color: Colors.grey[700]),
//                                       ),
//                                     ],
//                                   ),
//                           ),
//                         ),
//                         SizedBox(height: 24.h),
//
//                         // Form Section
//                         AddCarForm(
//                           formKey: _formKey,
//                           modelController: _modelController,
//                           brandController: _brandController,
//                           carTypeController: _carTypeController,
//                           carCategoryController: _carCategoryController,
//                           plateNumberController: _plateNumberController,
//                           yearController: _yearController,
//                           colorController: _colorController,
//                           seatingCapacityController: _seatingCapacityController,
//                           transmissionTypeController: _transmissionTypeController,
//                           fuelTypeController: _fuelTypeController,
//                           odometerController: _odometerController,
//                         ),
//                         SizedBox(height: 80.h),
//                       ],
//                     ),
//                   ),
//                   Positioned(
//                     right: 16.w,
//                     bottom: 16.h,
//                     child: FloatingActionButton(
//                       onPressed: () async {
//                         if (_formKey.currentState!.validate()) {
//                           if (_carImage == null) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('Please add a car photo!'),
//                                 backgroundColor: Colors.red,
//                               ),
//                             );
//                             return;
//                           }
//                           final car = CarModel(
//                             id: widget.carToEdit?.id ?? DateTime.now().millisecondsSinceEpoch,
//                             model: _modelController.text,
//                             brand: _brandController.text,
//                             carType: _carTypeController.text,
//                             carCategory: _carCategoryController.text,
//                             plateNumber: _plateNumberController.text,
//                             year: int.tryParse(_yearController.text) ?? 0,
//                             color: _colorController.text,
//                             seatingCapacity: int.tryParse(_seatingCapacityController.text) ?? 0,
//                             transmissionType: _transmissionTypeController.text,
//                             fuelType: _fuelTypeController.text,
//                             currentOdometerReading: int.tryParse(_odometerController.text) ?? 0,
//                             availability: true,
//                             currentStatus: 'Available',
//                             approvalStatus: false,
//                             rentalOptions: RentalOptions(
//                               availableWithoutDriver: false,
//                               availableWithDriver: false,
//                               dailyRentalPrice: 0.0,
//                             ),
//                             ownerId: authCubit.userModel?.id ?? '2',
//                           );
//
//                           if (widget.carToEdit != null) {
//                             context.read<AddCarCubit>().updateCar(car);
//                           } else {
//                             context.read<AddCarCubit>().addCar(car);
//                           }
//
//                           if (authCubit.userModel != null) {
//                             final ownerName =
//                                 '${authCubit.userModel!.firstName} ${authCubit.userModel!.lastName}';
//                             await NotificationService().sendNewCarNotification(
//                               carBrand: car.brand,
//                               carModel: car.model,
//                               ownerName: ownerName,
//                             );
//                           }
//                         }
//                       },
//                       backgroundColor: const Color(0xFF1a237e),
//                       child: Icon(
//                         widget.carToEdit != null ? Icons.save : Icons.arrow_forward,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
//
//
//// v2
// import 'dart:io';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../config/themes/app_colors.dart';
// import '../../../../core/utils/assets_manager.dart';
// import '../../../../core/utils/text_manager.dart';
// import '../../../../core/services/notification_service.dart';
// import 'package:test_cark/features/home/presentation/model/car_model.dart';
// import '../../../auth/presentation/cubits/auth_cubit.dart';
// import '../widgets/add_car_form.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../cubits/add_car_cubit.dart';
// import '../cubits/add_car_state.dart';
// import 'package:image_picker/image_picker.dart';
//
// class AddCarScreen extends StatefulWidget {
//   final CarModel? carToEdit;
//
//   const AddCarScreen({super.key, this.carToEdit});
//
//   @override
//   State<AddCarScreen> createState() => _AddCarScreenState();
// }
//
// class _AddCarScreenState extends State<AddCarScreen> with SingleTickerProviderStateMixin {
//   late final GlobalKey<FormState> _formKey;
//   late final TextEditingController _modelController;
//   late final TextEditingController _brandController;
//   late final TextEditingController _carTypeController;
//   late final TextEditingController _carCategoryController;
//   late final TextEditingController _plateNumberController;
//   late final TextEditingController _yearController;
//   late final TextEditingController _colorController;
//   late final TextEditingController _seatingCapacityController;
//   late final TextEditingController _transmissionTypeController;
//   late final TextEditingController _fuelTypeController;
//   late final TextEditingController _odometerController;
//
//   File? _carImage;
//   final ImagePicker _picker = ImagePicker();
//
//   late AnimationController _animationController;
//   late Animation<Offset> _slideAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _formKey = GlobalKey<FormState>();
//     _modelController = TextEditingController(text: widget.carToEdit?.model);
//     _brandController = TextEditingController(text: widget.carToEdit?.brand);
//     _carTypeController = TextEditingController(text: widget.carToEdit?.carType);
//     _carCategoryController = TextEditingController(text: widget.carToEdit?.carCategory);
//     _plateNumberController = TextEditingController(text: widget.carToEdit?.plateNumber);
//     _yearController = TextEditingController(text: widget.carToEdit?.year?.toString() ?? '');
//     _colorController = TextEditingController(text: widget.carToEdit?.color);
//     _seatingCapacityController = TextEditingController(text: widget.carToEdit?.seatingCapacity?.toString() ?? '');
//     _transmissionTypeController = TextEditingController(text: widget.carToEdit?.transmissionType);
//     _fuelTypeController = TextEditingController(text: widget.carToEdit?.fuelType);
//     _odometerController = TextEditingController(text: widget.carToEdit?.currentOdometerReading?.toString() ?? '');
//
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     );
//
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(-1.0, 0.0),
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
//     _modelController.dispose();
//     _brandController.dispose();
//     _carTypeController.dispose();
//     _carCategoryController.dispose();
//     _plateNumberController.dispose();
//     _yearController.dispose();
//     _colorController.dispose();
//     _seatingCapacityController.dispose();
//     _transmissionTypeController.dispose();
//     _fuelTypeController.dispose();
//     _odometerController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _pickImage() async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       setState(() {
//         _carImage = File(pickedFile.path);
//       });
//     }
//   }
//
//   void _removeImage() {
//     setState(() {
//       _carImage = null;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<AddCarCubit, AddCarState>(
//       listener: (context, state) {
//         if (state is AddCarSuccess) {
//           context.read<AddCarCubit>().fetchCarsFromServer();
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Operation completed successfully!'),
//               backgroundColor: Colors.green,
//               duration: const Duration(seconds: 2),
//             ),
//           );
//         } else if (state is AddCarError) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(state.message),
//               backgroundColor: Colors.red,
//               duration: const Duration(seconds: 3),
//             ),
//           );
//         }
//       },
//       builder: (context, state) {
//         return BlocBuilder<AuthCubit, AuthState>(
//           builder: (context, authState) {
//             final authCubit = context.read<AuthCubit>();
//             return Scaffold(
//               appBar: AppBar(
//                 title: Text(widget.carToEdit != null ? 'Edit Car' : TextManager.addCarTitle.tr()),
//                 centerTitle: true,
//                 backgroundColor: Colors.white,
//                 foregroundColor: Colors.black,
//                 elevation: 0.5,
//               ),
//               backgroundColor: Colors.grey[50],
//               body: Stack(
//                 children: [
//                   SingleChildScrollView(
//                     padding: EdgeInsets.all(16.w),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Center(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               SlideTransition(
//                                 position: _slideAnimation,
//                                 child: Image.asset(AssetsManager.carSignUp, height: 0.05.sh),
//                               ),
//                               SizedBox(width: 0.02.sw),
//                               Image.asset(AssetsManager.carkSignUp, height: 0.03.sh),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 32.h),
//
//                         // Car Photo Section
//                         Text(
//                           'Car Photo',
//                           style: TextStyle(
//                             fontSize: 20.sp,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         SizedBox(height: 16.h),
//                         Center(
//                           child: InkWell(
//                             onTap: _pickImage,
//                             borderRadius: BorderRadius.circular(15.r),
//                             child: Container(
//                               width: 0.8.sw,
//                               height: 160.h,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(15.r),
//                                 border: Border.all(
//                                   color: _carImage != null || (widget.carToEdit?.imageUrl != null && widget.carToEdit!.imageUrl!.isNotEmpty)
//                                       ? AppColors.primary
//                                       : Colors.grey[300]!,
//                                   width: 1.5.w,
//                                 ),
//                               ),
//                               child: Stack(
//                                 alignment: Alignment.center,
//                                 children: [
//                                   ClipRRect(
//                                     borderRadius: BorderRadius.circular(14.r),
//                                     child: _carImage != null
//                                         ? Image.file(
//                                       _carImage!,
//                                       fit: BoxFit.cover,
//                                       width: double.infinity,
//                                       height: double.infinity,
//                                     )
//                                         : (widget.carToEdit?.imageUrl != null && widget.carToEdit!.imageUrl!.isNotEmpty)
//                                         ? CachedNetworkImage(
//                                       imageUrl: widget.carToEdit!.imageUrl!,
//                                       fit: BoxFit.cover,
//                                       width: double.infinity,
//                                       height: double.infinity,
//                                       placeholder: (context, url) => Center(
//                                         child: CircularProgressIndicator(color: AppColors.primary),
//                                       ),
//                                       errorWidget: (context, url, error) => _buildUploadBox(),
//                                     )
//                                         : _buildUploadBox(),
//                                   ),
//                                   if (_carImage != null || (widget.carToEdit?.imageUrl != null && widget.carToEdit!.imageUrl!.isNotEmpty))
//                                     Positioned(
//                                       top: 8.h,
//                                       right: 8.w,
//                                       child: GestureDetector(
//                                         onTap: _removeImage,
//                                         child: CircleAvatar(
//                                           radius: 14.r,
//                                           backgroundColor: Colors.red.withOpacity(0.9),
//                                           child: Icon(Icons.close, color: Colors.white, size: 16.sp),
//                                         ),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//
//                         SizedBox(height: 32.h),
//                         Text('Car Details', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
//                         SizedBox(height: 16.h),
//                         Card(
//                           elevation: 4,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
//                           margin: EdgeInsets.zero,
//                           child: Padding(
//                             padding: EdgeInsets.all(16.w),
//                             child: AddCarForm(
//                               formKey: _formKey,
//                               modelController: _modelController,
//                               brandController: _brandController,
//                               carTypeController: _carTypeController,
//                               carCategoryController: _carCategoryController,
//                               plateNumberController: _plateNumberController,
//                               yearController: _yearController,
//                               colorController: _colorController,
//                               seatingCapacityController: _seatingCapacityController,
//                               transmissionTypeController: _transmissionTypeController,
//                               fuelTypeController: _fuelTypeController,
//                               odometerController: _odometerController,
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 80.h),
//                       ],
//                     ),
//                   ),
//                   Positioned(
//                     right: 16.w,
//                     bottom: 16.h,
//                     child: FloatingActionButton.extended(
//                       onPressed: (state is AddCarLoading) ? null : () async {
//                         if (_formKey.currentState!.validate()) {
//                           final car = CarModel(
//                             id: widget.carToEdit?.id ?? DateTime.now().millisecondsSinceEpoch,
//                             model: _modelController.text,
//                             brand: _brandController.text,
//                             carType: _carTypeController.text,
//                             carCategory: _carCategoryController.text,
//                             plateNumber: _plateNumberController.text,
//                             year: int.tryParse(_yearController.text) ?? 0,
//                             color: _colorController.text,
//                             seatingCapacity: int.tryParse(_seatingCapacityController.text) ?? 0,
//                             transmissionType: _transmissionTypeController.text,
//                             fuelType: _fuelTypeController.text,
//                             currentOdometerReading: int.tryParse(_odometerController.text) ?? 0,
//                             availability: true,
//                             currentStatus: 'Available',
//                             approvalStatus: false,
//                             rentalOptions: RentalOptions(
//                               availableWithoutDriver: false,
//                               availableWithDriver: false,
//                               dailyRentalPrice: 0.0,
//                             ),
//                             ownerId: authCubit.userModel?.id ?? '2',
//                           );
//
//                           if (widget.carToEdit != null) {
//                             context.read<AddCarCubit>().updateCar(car);
//                           } else {
//                             context.read<AddCarCubit>().addCar(car);
//                           }
//
//                           if (authCubit.userModel != null) {
//                             final ownerName = '${authCubit.userModel!.firstName} ${authCubit.userModel!.lastName}';
//                             await NotificationService().sendNewCarNotification(
//                               carBrand: car.brand,
//                               carModel: car.model,
//                               ownerName: ownerName,
//                             );
//                           }
//                         }
//                       },
//                       backgroundColor: const Color(0xFF1a237e),
//                       icon: Icon(widget.carToEdit != null ? Icons.save : Icons.add, color: Colors.white),
//                       label: Text(widget.carToEdit != null ? 'Save Changes' : 'Add Car', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
//                     ),
//                   ),
//                   if (state is AddCarLoading)
//                     Container(
//                       color: Colors.black.withOpacity(0.5),
//                       child: const Center(
//                         child: CircularProgressIndicator(color: AppColors.primary),
//                       ),
//                     ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildUploadBox() {
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       color: Colors.white,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Image.asset(
//             AssetsManager.carSignUp,
//             width: 50.w,
//             height: 50.h,
//             color: AppColors.primary,
//           ),
//           SizedBox(height: 10.h),
//           Text(
//             'Tap to upload car photo',
//             style: TextStyle(
//               color: AppColors.primary,
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../core/utils/assets_manager.dart';
import '../../../../core/utils/text_manager.dart';
import '../../../../core/services/notification_service.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../widgets/add_car_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/add_car_cubit.dart';
import '../cubits/add_car_state.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../config/routes/screens_name.dart';

class AddCarScreen extends StatefulWidget {
  final CarModel? carToEdit;

  const AddCarScreen({super.key, this.carToEdit});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> with SingleTickerProviderStateMixin {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _modelController;
  late final TextEditingController _brandController;
  late final TextEditingController _carTypeController;
  late final TextEditingController _carCategoryController;
  late final TextEditingController _plateNumberController;
  late final TextEditingController _yearController;
  late final TextEditingController _colorController;
  late final TextEditingController _seatingCapacityController;
  late final TextEditingController _transmissionTypeController;
  late final TextEditingController _fuelTypeController;
  late final TextEditingController _odometerController;

  File? _carImage;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _modelController = TextEditingController(text: widget.carToEdit?.model);
    _brandController = TextEditingController(text: widget.carToEdit?.brand);
    _carTypeController = TextEditingController(text: widget.carToEdit?.carType);
    _carCategoryController = TextEditingController(text: widget.carToEdit?.carCategory);
    _plateNumberController = TextEditingController(text: widget.carToEdit?.plateNumber);
    _yearController = TextEditingController(text: widget.carToEdit?.year?.toString() ?? '');
    _colorController = TextEditingController(text: widget.carToEdit?.color);
    _seatingCapacityController = TextEditingController(text: widget.carToEdit?.seatingCapacity?.toString() ?? '');
    _transmissionTypeController = TextEditingController(text: widget.carToEdit?.transmissionType);
    _fuelTypeController = TextEditingController(text: widget.carToEdit?.fuelType);
    _odometerController = TextEditingController(text: widget.carToEdit?.currentOdometerReading?.toString() ?? '');

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _modelController.dispose();
    _brandController.dispose();
    _carTypeController.dispose();
    _carCategoryController.dispose();
    _plateNumberController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _seatingCapacityController.dispose();
    _transmissionTypeController.dispose();
    _fuelTypeController.dispose();
    _odometerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _carImage = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _carImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCarCubit, AddCarState>(
      listener: (context, state) async {
        if (state is AddCarSuccess) {
          context.read<AddCarCubit>().fetchCarsFromServer();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Operation completed successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          // Navigate to rental option screen after successful add/edit
          Navigator.pushNamed(context, ScreensName.rentalOptionScreen);
        } else if (state is AddCarError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        return BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            final authCubit = context.read<AuthCubit>();
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.carToEdit != null ? 'Edit Car' : TextManager.addCarTitle.tr()),
                centerTitle: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0.5,
              ),
              backgroundColor: Colors.grey[50],
              body: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SlideTransition(
                                position: _slideAnimation,
                                child: Image.asset(AssetsManager.carSignUp, height: 0.05.sh),
                              ),
                              SizedBox(width: 0.02.sw),
                              Image.asset(AssetsManager.carkSignUp, height: 0.03.sh),
                            ],
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // Car Photo Section
                        Text(
                          'Car Photo',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Center(
                          child: InkWell(
                            onTap: _pickImage,
                            borderRadius: BorderRadius.circular(15.r),
                            child: Container(
                              width: 0.8.sw,
                              height: 160.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15.r),
                                border: Border.all(
                                  color: _carImage != null || (widget.carToEdit?.imageUrl != null && widget.carToEdit!.imageUrl!.isNotEmpty)
                                      ? AppColors.primary
                                      : Colors.grey[300]!,
                                  width: 1.5.w,
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14.r),
                                    child: _carImage != null
                                        ? Image.file(
                                      _carImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    )
                                        : (widget.carToEdit?.imageUrl != null && widget.carToEdit!.imageUrl!.isNotEmpty)
                                        ? CachedNetworkImage(
                                      imageUrl: widget.carToEdit!.imageUrl!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(color: AppColors.primary),
                                      ),
                                      errorWidget: (context, url, error) => _buildUploadBox(),
                                    )
                                        : _buildUploadBox(),
                                  ),
                                  if (_carImage != null || (widget.carToEdit?.imageUrl != null && widget.carToEdit!.imageUrl!.isNotEmpty))
                                    Positioned(
                                      top: 8.h,
                                      right: 8.w,
                                      child: GestureDetector(
                                        onTap: _removeImage,
                                        child: CircleAvatar(
                                          radius: 14.r,
                                          backgroundColor: Colors.red.withOpacity(0.9),
                                          child: Icon(Icons.close, color: Colors.white, size: 16.sp),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 32.h),
                        Text('Car Details', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                        SizedBox(height: 16.h),
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: EdgeInsets.all(16.w),
                            child: AddCarForm(
                              formKey: _formKey,
                              modelController: _modelController,
                              brandController: _brandController,
                              carTypeController: _carTypeController,
                              carCategoryController: _carCategoryController,
                              plateNumberController: _plateNumberController,
                              yearController: _yearController,
                              colorController: _colorController,
                              seatingCapacityController: _seatingCapacityController,
                              transmissionTypeController: _transmissionTypeController,
                              fuelTypeController: _fuelTypeController,
                              odometerController: _odometerController,
                            ),
                          ),
                        ),
                        SizedBox(height: 80.h),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 16.w,
                    bottom: 16.h,
                    child: FloatingActionButton.extended(
                      onPressed: (state is AddCarLoading) ? null : () async {
                        if (_formKey.currentState!.validate()) {
                          final car = CarModel(
                            id: widget.carToEdit?.id ?? DateTime.now().millisecondsSinceEpoch,
                            model: _modelController.text,
                            brand: _brandController.text,
                            carType: _carTypeController.text,
                            carCategory: _carCategoryController.text,
                            plateNumber: _plateNumberController.text,
                            year: int.tryParse(_yearController.text) ?? 0,
                            color: _colorController.text,
                            seatingCapacity: int.tryParse(_seatingCapacityController.text) ?? 0,
                            transmissionType: _transmissionTypeController.text,
                            fuelType: _fuelTypeController.text,
                            currentOdometerReading: int.tryParse(_odometerController.text) ?? 0,
                            availability: true,
                            currentStatus: 'Available',
                            approvalStatus: false,
                            rentalOptions: RentalOptions(
                              availableWithoutDriver: false,
                              availableWithDriver: false,
                              dailyRentalPrice: 0.0,
                            ),
                            ownerId: authCubit.userModel?.id ?? '2',
                          );

                          if (widget.carToEdit != null) {
                            context.read<AddCarCubit>().updateCar(car);
                          } else {
                            context.read<AddCarCubit>().addCar(car);
                          }

                          if (authCubit.userModel != null) {
                            final ownerName = '${authCubit.userModel!.firstName} ${authCubit.userModel!.lastName}';
                            await NotificationService().sendNewCarNotification(
                              carBrand: car.brand,
                              carModel: car.model,
                              ownerName: ownerName,
                            );
                          }
                        }
                      },
                      backgroundColor: const Color(0xFF1a237e),
                      icon: Icon(widget.carToEdit != null ? Icons.save : Icons.add, color: Colors.white),
                      label: Text(widget.carToEdit != null ? 'Save Changes' : 'Add Car', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
                    ),
                  ),
                  if (state is AddCarLoading)
                    Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUploadBox() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AssetsManager.carSignUp,
            width: 50.w,
            height: 50.h,
            color: AppColors.primary,
          ),
          SizedBox(height: 10.h),
          Text(
            'Tap to upload car photo',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

