import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/routes/screens_name.dart';
import '../../../../core/utils/assets_manager.dart';
import '../../../../core/utils/text_manager.dart';
import '../../../../core/services/notification_service.dart';
import 'package:test_cark/features/home/presentation/model/car_model.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';
import '../widgets/add_car_form.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/add_car_cubit.dart';
import '../cubits/add_car_state.dart';

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

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _modelController = TextEditingController(text: widget.carToEdit?.model);
    _brandController = TextEditingController(text: widget.carToEdit?.brand);
    _carTypeController = TextEditingController(text: widget.carToEdit?.carType);
    _carCategoryController =
        TextEditingController(text: widget.carToEdit?.carCategory);
    _plateNumberController =
        TextEditingController(text: widget.carToEdit?.plateNumber);
    _yearController =
        TextEditingController(text: widget.carToEdit?.year.toString());
    _colorController = TextEditingController(text: widget.carToEdit?.color);
    _seatingCapacityController = TextEditingController(
        text: widget.carToEdit?.seatingCapacity.toString());
    _transmissionTypeController =
        TextEditingController(text: widget.carToEdit?.transmissionType);
    _fuelTypeController =
        TextEditingController(text: widget.carToEdit?.fuelType);
    _odometerController = TextEditingController(
        text: widget.carToEdit?.currentOdometerReading.toString());
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
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Car "${state.car.brand} ${state.car.model}" added successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Navigate to OwnerHomeScreen
          Navigator.pushNamedAndRemoveUntil(
              context, ScreensName.ownerHomeScreen, (route) => false);

          // Show additional feedback
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your car is now available for rent!'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (state is AddCarError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
                            Image.asset(AssetsManager.carSignUp,
                                height: 0.05.sh),
                            SizedBox(width: 0.02.sw),
                            Image.asset(AssetsManager.carkSignUp,
                                height: 0.03.sh),
                          ],
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
                          transmissionTypeController:
                              _transmissionTypeController,
                          fuelTypeController: _fuelTypeController,
                          odometerController: _odometerController,
                        ),
                        // Add extra padding at bottom for FAB
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
                          final car = CarModel(
                            id: DateTime.now().millisecondsSinceEpoch,
                            model: _modelController.text,
                            brand: _brandController.text,
                            carType: _carTypeController.text,
                            carCategory: _carCategoryController.text,
                            plateNumber: _plateNumberController.text,
                            year: int.parse(_yearController.text),
                            color: _colorController.text,
                            seatingCapacity:
                                int.parse(_seatingCapacityController.text),
                            transmissionType: _transmissionTypeController.text,
                            fuelType: _fuelTypeController.text,
                            currentOdometerReading:
                                int.parse(_odometerController.text),
                            availability: true,
                            currentStatus: 'Available',
                            approvalStatus: false,
                            rentalOptions: RentalOptions(
                              availableWithoutDriver: false,
                              availableWithDriver: false,
                              dailyRentalPrice: 0.0,
                            ),
                            ownerId: authCubit.userModel!.id,
                          );
                          
                          // Add car using the cubit
                          context.read<AddCarCubit>().addCar(car);
                          
                          // Send notification with owner name
                          final ownerName =
                              '${authCubit.userModel!.firstName} ${authCubit.userModel!.lastName}';
                          await NotificationService().sendNewCarNotification(
                            carBrand: car.brand,
                            carModel: car.model,
                            ownerName: ownerName,
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
      },
    );
  }
}
