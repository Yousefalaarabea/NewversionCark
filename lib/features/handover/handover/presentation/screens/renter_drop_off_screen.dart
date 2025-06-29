import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../config/routes/screens_name.dart';
import '../../../../../config/themes/app_colors.dart';
import '../../../../../core/widgets/custom_elevated_button.dart';
import '../cubits/renter_drop_off_cubit.dart';
import '../widgets/excess_charges_widget.dart';
import '../widgets/handover_notes_widget.dart';
import '../widgets/image_upload_widget.dart';

class RenterDropOffScreen extends StatefulWidget {
  final String tripId;
  final String carId;
  final String renterId;
  final String ownerId;
  final String paymentMethod;

  const RenterDropOffScreen({
    Key? key,
    required this.tripId,
    required this.carId,
    required this.renterId,
    required this.ownerId,
    required this.paymentMethod,
  }) : super(key: key);

  @override
  State<RenterDropOffScreen> createState() => _RenterDropOffScreenState();
}

class _RenterDropOffScreenState extends State<RenterDropOffScreen> {
  final TextEditingController _odometerController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  String? _carImagePath;
  String? _odometerImagePath;
  int? _finalOdometerReading;
  String? _renterNotes;

  @override
  void initState() {
    super.initState();
    _initializeHandover();
  }

  @override
  void dispose() {
    _odometerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeHandover() {
    context.read<RenterDropOffCubit>().initializeHandover(
      tripId: widget.tripId,
      carId: widget.carId,
      renterId: widget.renterId,
      ownerId: widget.ownerId,
      paymentMethod: widget.paymentMethod,
    );
  }

  Future<void> _pickImage(ImageSource source, bool isCarImage) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        if (isCarImage) {
          await context.read<RenterDropOffCubit>().uploadCarImage(File(image.path));
        } else {
          await context.read<RenterDropOffCubit>().uploadOdometerImage(File(image.path));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في اختيار الصورة: $e')),
      );
    }
  }

  void _calculateExcessCharges() {
    if (_finalOdometerReading == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال قراءة العداد أولاً')),
      );
      return;
    }

    // Mock values - in real app these would come from trip data
    context.read<RenterDropOffCubit>().calculateExcessCharges(
      agreedKilometers: 200,
      agreedHours: 24,
      extraKmRate: 0.5,
      extraHourRate: 10.0,
    );
  }

  void _processPayment() {
    context.read<RenterDropOffCubit>().processPayment();
  }

  void _completeHandover() {
    context.read<RenterDropOffCubit>().completeRenterHandover();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تسليم السيارة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: BlocConsumer<RenterDropOffCubit, RenterDropOffState>(
        listener: (context, state) {
          if (state is RenterDropOffError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is RenterDropOffCarImageUploaded) {
            setState(() {
              _carImagePath = state.carImagePath;
            });
          } else if (state is RenterDropOffOdometerImageUploaded) {
            setState(() {
              _odometerImagePath = state.odometerImagePath;
            });
          } else if (state is RenterDropOffOdometerReadingSet) {
            setState(() {
              _finalOdometerReading = state.odometerReading;
            });
          } else if (state is RenterDropOffExcessCalculated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تم حساب الرسوم الزائدة بنجاح')),
            );
          } else if (state is RenterDropOffPaymentProcessed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تم معالجة الدفع بنجاح')),
            );
          } else if (state is RenterDropOffNotesAdded) {
            setState(() {
              _renterNotes = state.notes;
            });
          } else if (state is RenterDropOffCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('تم تسليم السيارة بنجاح')),
            );
            // Navigate to owner drop-off screen
            Navigator.pushReplacementNamed(
              context,
              ScreensName.ownerDropOffScreen,
              arguments: {
                'handoverData': state.handoverData,
                'logs': state.logs,
              },
            );
          }
        },
        builder: (context, state) {
          if (state is RenterDropOffLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.directions_car, color: AppColors.primary, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تسليم السيارة',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'قم بإكمال الخطوات التالية لتسليم السيارة',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Step 1: Upload car image
                _buildStepCard(
                  title: '1. صورة السيارة بعد الرحلة',
                  subtitle: 'قم برفع صورة للسيارة لتوثيق حالتها',
                  icon: Icons.camera_alt,
                  isCompleted: _carImagePath != null,
                  child: ImageUploadWidget(
                    imagePath: _carImagePath,
                    onImagePicked: (source) => _pickImage(source, true),
                    title: 'صورة السيارة',
                  ),
                ),
                SizedBox(height: 16),

                // Step 2: Upload odometer image
                _buildStepCard(
                  title: '2. صورة عداد المسافات',
                  subtitle: 'قم برفع صورة لعداد المسافات',
                  icon: Icons.speed,
                  isCompleted: _odometerImagePath != null,
                  child: ImageUploadWidget(
                    imagePath: _odometerImagePath,
                    onImagePicked: (source) => _pickImage(source, false),
                    title: 'صورة العداد',
                  ),
                ),
                SizedBox(height: 16),

                // Step 3: Enter odometer reading
                _buildStepCard(
                  title: '3. قراءة العداد النهائية',
                  subtitle: 'أدخل قراءة عداد المسافات الحالية',
                  icon: Icons.edit,
                  isCompleted: _finalOdometerReading != null,
                  child: TextFormField(
                    controller: _odometerController,
                    decoration: InputDecoration(
                      labelText: 'قراءة العداد (كم)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final reading = int.tryParse(value);
                      if (reading != null) {
                        context.read<RenterDropOffCubit>().setFinalOdometerReading(reading);
                      }
                    },
                  ),
                ),
                SizedBox(height: 16),

                // Step 4: Calculate excess charges
                if (_finalOdometerReading != null)
                  _buildStepCard(
                    title: '4. حساب الرسوم الزائدة',
                    subtitle: 'احسب الرسوم الإضافية إن وجدت',
                    icon: Icons.calculate,
                    isCompleted: state is RenterDropOffExcessCalculated || 
                                state is RenterDropOffPaymentProcessed ||
                                state is RenterDropOffCompleted,
                    child: Column(
                      children: [
                        CustomElevatedButton(
                          onPressed: _calculateExcessCharges,
                          text: 'حساب الرسوم الزائدة',
                        ),
                        if (state is RenterDropOffExcessCalculated) ...[
                          SizedBox(height: 16),
                          ExcessChargesWidget(
                            excessCharges: state.excessCharges,
                            paymentMethod: widget.paymentMethod,
                          ),
                          SizedBox(height: 16),
                          CustomElevatedButton(
                            onPressed: _processPayment,
                            text: 'معالجة الدفع',
                          ),
                        ],
                      ],
                    ),
                  ),
                SizedBox(height: 16),

                // Step 5: Add notes
                _buildStepCard(
                  title: '5. إضافة ملاحظات',
                  subtitle: 'أضف أي ملاحظات إضافية',
                  icon: Icons.note_add,
                  isCompleted: _renterNotes != null && _renterNotes!.isNotEmpty,
                  child: HandoverNotesWidget(
                    title: 'ملاحظات المستأجر',
                    initialValue: _renterNotes,
                    onNotesChanged: (notes) {
                      context.read<RenterDropOffCubit>().addRenterNotes(notes);
                    },
                    hintText: 'أضف ملاحظاتك حول الرحلة أو حالة السيارة...',
                  ),
                ),
                SizedBox(height: 24),

                // Complete handover button
                if (_canCompleteHandover(state))
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _completeHandover,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'إكمال التسليم',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? AppColors.green : AppColors.primary.withOpacity(0.2),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCompleted ? AppColors.green : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCompleted ? Icons.check : icon,
                  color: isCompleted ? Colors.white : AppColors.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? AppColors.green : AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  bool _canCompleteHandover(RenterDropOffState state) {
    return _carImagePath != null &&
           _odometerImagePath != null &&
           _finalOdometerReading != null &&
           (state is RenterDropOffExcessCalculated ||
            state is RenterDropOffPaymentProcessed ||
            state is RenterDropOffCompleted);
  }
} 