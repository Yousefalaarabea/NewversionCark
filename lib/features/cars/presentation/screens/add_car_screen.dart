import 'dart:io';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../core/utils/assets_manager.dart';
import '../../../../core/utils/text_manager.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../notifications/presentation/cubits/notification_cubit.dart';
import '../widgets/add_car_form.dart';
import '../cubits/add_car_cubit.dart';
import '../cubits/add_car_state.dart';
import '../../../../config/routes/screens_name.dart';
import 'package:test_cark/features/cars/presentation/models/car_rental_options.dart';
import 'package:test_cark/features/cars/presentation/models/car_usage_policy.dart';

class AddCarScreen extends StatefulWidget {
  final CarModel? carToEdit;
  final CarRentalOptions? rentalOptionsToEdit;
  final CarUsagePolicy? usagePolicyToEdit;

  const AddCarScreen({super.key, this.carToEdit, this.rentalOptionsToEdit, this.usagePolicyToEdit});

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
  late final TextEditingController _currentStatusController;
  late final GlobalKey<FormFieldState> _plateNumberFieldKey;
  String? _plateNumberError;

  File? _carImage;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _plateNumberFieldKey = GlobalKey<FormFieldState>();
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
    _currentStatusController = TextEditingController(text: widget.carToEdit?.currentStatus ?? 'Available');

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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
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
    _currentStatusController.dispose();
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

  String _parseErrorMessage(String message) {
    try {
      final Map<String, dynamic> errorJson = jsonDecode(message);
      final errors = errorJson.entries.map((entry) {
        final field = entry.key.replaceAll('_', ' ').capitalize();
        final errorList = entry.value is List ? entry.value as List : [entry.value];
        if (entry.key == 'plate_number') {
          setState(() {
            _plateNumberError = errorList.join(', ');
          });
        }
        return '$field: ${errorList.join(', ')}';
      }).join('\n');
      return errors.isNotEmpty ? errors : 'An error occurred. Please check your input.';
    } catch (e) {
      return message.isNotEmpty ? message : 'An error occurred. Please check your input.';
    }
  }

  @override
  Widget build(BuildContext context) {
    String? imagePath = widget.carToEdit?.imageUrl;
    return BlocConsumer<AddCarCubit, AddCarState>(
      listener: (context, state) async {
        if (state is AddCarSuccess) {
          await context.read<AddCarCubit>().fetchCarsFromServer();
          await context.read<AuthCubit>().loadUserData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Car "${state.carBundle.car.brand} ${state.carBundle.car.model}" ${widget.carToEdit != null ? 'updated' : 'added'} successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pushNamedAndRemoveUntil(context, ScreensName.ownerHomeScreen, (route) => false);
          if (widget.carToEdit == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your car is now available for rent!'),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else if (state is AddCarError) {
          setState(() {
            _plateNumberError = null; // Reset error before parsing
          });
          final errorMessage = _parseErrorMessage(state.message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
          if (state.message.contains('plate_number')) {
            _plateNumberFieldKey.currentState?.validate();
          }
        }
      },
      builder: (context, state) {
        return BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            final authCubit = context.read<AuthCubit>();
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.carToEdit != null ? 'Edit Car' : TextManager.addCarTitle.tr(),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                backgroundColor: AppColors.primary,
                elevation: 2,
                shadowColor: Colors.black54,
              ),
              backgroundColor: Colors.grey[100],
              body: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SlideTransition(
                                  position: _slideAnimation,
                                  child: Image.asset(AssetsManager.carSignUp, height: 0.05.sh, color: AppColors.primary),
                                ),
                                SizedBox(width: 0.02.sw),
                                Image.asset(AssetsManager.carkSignUp, height: 0.03.sh),
                              ],
                            ),
                          ),
                          SizedBox(height: 32.h),
                          Text(
                            'Car Photo',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
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
                                height: 180.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15.r),
                                  border: Border.all(
                                    color: _carImage != null || (imagePath?.isNotEmpty == true)
                                        ? AppColors.primary
                                        : Colors.grey[300]!,
                                    width: 2.w,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8.r,
                                      offset: Offset(0, 4.h),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14.r),
                                      child: (
                                        _carImage != null
                                          ? Image.file(_carImage!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                                          : (() {
                                              final path = imagePath;
                                              if (path != null && path.isNotEmpty) {
                                                return Image.file(File(path), fit: BoxFit.cover, width: double.infinity, height: double.infinity);
                                              } else {
                                                return _buildUploadBox();
                                              }
                                            })()
                                      ),
                                    ),
                                    if (_carImage != null || (imagePath?.isNotEmpty == true))
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
                          Text(
                            'Car Details',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Card(
                            elevation: 6,
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
                                plateNumberFieldKey: _plateNumberFieldKey,
                                plateNumberError: _plateNumberError,
                                yearController: _yearController,
                                colorController: _colorController,
                                seatingCapacityController: _seatingCapacityController,
                                transmissionTypeController: _transmissionTypeController,
                                fuelTypeController: _fuelTypeController,
                                odometerController: _odometerController,
                                currentStatusController: _currentStatusController,
                              ),
                            ),
                          ),
                          SizedBox(height: 80.h),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16.w,
                    bottom: 16.h,
                    child: AnimatedScale(
                      scale: (state is AddCarLoading) ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: FloatingActionButton.extended(
                        onPressed: (state is AddCarLoading) ? null : () async {
                          setState(() {
                            _plateNumberError = null; // Reset error before submission
                          });
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
                              currentStatus: _currentStatusController.text,
                              approvalStatus: false,
                              avgRating: 0.0,
                              totalReviews: 0,
                              ownerId: authCubit.userModel?.id ?? '2',
                              imageUrl: _carImage?.path,
                            );

                            final result = await Navigator.pushNamed(
                              context,
                              ScreensName.rentalOptionScreen,
                              arguments: car,
                            );

                            if (result is CarModel) {
                              setState(() {
                                _modelController.text = result.model;
                                _brandController.text = result.brand;
                                _carTypeController.text = result.carType;
                                _carCategoryController.text = result.carCategory;
                                _plateNumberController.text = result.plateNumber;
                                _yearController.text = result.year.toString();
                                _colorController.text = result.color;
                                _seatingCapacityController.text = result.seatingCapacity.toString();
                                _transmissionTypeController.text = result.transmissionType;
                                _fuelTypeController.text = result.fuelType;
                                _odometerController.text = result.currentOdometerReading.toString();
                                _currentStatusController.text = result.currentStatus;
                                _carImage = (result.imageUrl?.isNotEmpty == true && result.imageUrl != 'https://cdn-icons-png.flaticon.com/512/743/743007.png')
                                    ? File(result.imageUrl!)
                                    : null;
                              });
                            } else {
                              if (widget.carToEdit != null) {
                                //context.read<AddCarCubit>().updateCar(car);
                              } else {
                                //context.read<AddCarCubit>().addCar(car);
                              }

                              if (authCubit.userModel != null) {
                                final ownerName = '${authCubit.userModel!.firstName} ${authCubit.userModel!.lastName}';
                                // Send in-app notification for new car
                                context.read<NotificationCubit>().addNotification(
                                  title: 'New Car Added',
                                  message: '$ownerName has added a new ${car.brand} ${car.model} to the platform',
                                  type: 'car_added',
                                  data: {
                                    'carBrand': car.brand,
                                    'carModel': car.model,
                                    'ownerName': ownerName,
                                  },
                                );
                              }
                            }
                          }
                        },
                        backgroundColor: AppColors.primary,
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        icon: Icon(widget.carToEdit != null ? Icons.save : Icons.arrow_forward, color: Colors.white),
                        label: Text(
                          widget.carToEdit != null ? 'Save Changes' : 'Next',
                          style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600),
                        ),
                      ),
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
          // Icon(Icons.add_a_photo, size: 50.sp, color: AppColors.primary),
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

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}