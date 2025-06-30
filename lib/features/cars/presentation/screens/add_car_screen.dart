import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

class AddCarScreen extends StatefulWidget {
  final CarModel? carToEdit;

  const AddCarScreen({super.key, this.carToEdit});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddCarCubit, AddCarState>(
      listener: (context, state) {
        if (state is AddCarSuccess) {
          context.read<AddCarCubit>().fetchCarsFromServer();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Operation completed successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
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
          builder: (context, state) {
            final authCubit = context.read<AuthCubit>();
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.carToEdit != null
                    ? 'Edit Car'
                    : TextManager.addCarTitle.tr()),
              ),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        // Logo Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(AssetsManager.carSignUp, height: 0.05.sh),
                            SizedBox(width: 0.02.sw),
                            Image.asset(AssetsManager.carkSignUp, height: 0.03.sh),
                          ],
                        ),
                        SizedBox(height: 24.h),

                        // Car Photo Section
                        GestureDetector(
                          onTap: () async {
                            final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                            if (pickedFile != null) {
                              setState(() {
                                _carImage = File(pickedFile.path);
                              });
                            }
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            width: 150.w,
                            height: 150.w,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: Colors.grey, width: 1.w),
                              boxShadow: _carImage != null
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: _carImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10.r),
                                    child: Image.file(
                                      _carImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 50.w,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'Add Car Photo',
                                        style: TextStyle(color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        SizedBox(height: 24.h),

                        // Form Section
                        AddCarForm(
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
                        SizedBox(height: 80.h),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 16.w,
                    bottom: 16.h,
                    child: FloatingActionButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (_carImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please add a car photo!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
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
                            final ownerName =
                                '${authCubit.userModel!.firstName} ${authCubit.userModel!.lastName}';
                            await NotificationService().sendNewCarNotification(
                              carBrand: car.brand,
                              carModel: car.model,
                              ownerName: ownerName,
                            );
                          }
                        }
                      },
                      backgroundColor: const Color(0xFF1a237e),
                      child: Icon(
                        widget.carToEdit != null ? Icons.save : Icons.arrow_forward,
                        color: Colors.white,
                      ),
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
} 