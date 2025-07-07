import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../config/routes/screens_name.dart';
import '../../../../../config/themes/app_colors.dart';
import '../../../../../main.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../model/trip_details_model.dart';
import 'package:dio/dio.dart';
import '../../model/car_model.dart';

class TripDetailsConfirmationScreen extends StatefulWidget {
  static const routeName = ScreensName.tripDetailsConfirmationScreen;
  final TripDetailsModel tripDetails;
  final int? rentalId;

  const TripDetailsConfirmationScreen({
    super.key, 
    required this.tripDetails,
    this.rentalId,
  });

  @override
  State<TripDetailsConfirmationScreen> createState() => _TripDetailsConfirmationScreenState();
}

class _TripDetailsConfirmationScreenState extends State<TripDetailsConfirmationScreen> {
  late TripDetailsModel tripDetails;
  bool _loadingCar = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    tripDetails = widget.tripDetails;
    // إذا كانت بيانات السيارة ناقصة (مثلاً brand أو model أو year افتراضي)
    if (_shouldFetchCarDetails(tripDetails.car)) {
      _fetchCarDetails(tripDetails.car.id);
    }
  }

  bool _shouldFetchCarDetails(CarModel car) {
    // إذا كان البراند أو الموديل أو السنة غير متوفرين أو افتراضيين
    return car.id != 0 && (car.brand == 'Unavailable' || car.model == 'Unavailable' || car.year == 0);
  }

  Future<void> _fetchCarDetails(int carId) async {
    setState(() { _loadingCar = true; _error = null; });
    try {
      final dio = Dio();

      final response = await dio.get('https://reject-guests-creek-friday.trycloudflare.com/api/cars/$carId');
      if (response.statusCode == 200 && response.data != null) {
        final car = CarModel.fromJson(response.data);
        setState(() {
          tripDetails = TripDetailsModel(
            car: car,
            pickupLocation: tripDetails.pickupLocation,
            dropoffLocation: tripDetails.dropoffLocation,
            startDate: tripDetails.startDate,
            endDate: tripDetails.endDate,
            totalPrice: tripDetails.totalPrice,
            paymentMethod: tripDetails.paymentMethod,
            renterName: tripDetails.renterName,
            ownerName: tripDetails.ownerName,
            pickupLocationLat: tripDetails.pickupLocationLat,
            pickupLocationLng: tripDetails.pickupLocationLng,
            extraInstructions: tripDetails.extraInstructions,
          );
          _loadingCar = false;
        });
      } else {
        setState(() { _error = 'Failed to fetch car details.'; _loadingCar = false; });
      }
    } catch (e) {
      setState(() { _error = 'Error: $e'; _loadingCar = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Trip Details'),
      ),
      body: SafeArea(
        child: _loadingCar
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // صورة السيارة أو الأيقونة
                              buildCarImage(tripDetails.car),
                              const SizedBox(height: 18),
                              // بيانات السيارة
                              if (tripDetails.car != null)
                                Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // عنوان السيارة
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: theme.primaryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(Icons.directions_car, color: theme.primaryColor, size: 20),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                '${tripDetails.car.brand} ${tripDetails.car.model}',
                                                style: theme.textTheme.titleLarge?.copyWith(
                                                  fontWeight: FontWeight.w600, 
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        
                                        // الصف الأول من البيانات
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildCarDetailItem(
                                                Icons.calendar_today,
                                                'Year',
                                                '${tripDetails.car.year}',
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildCarDetailItem(
                                                Icons.color_lens,
                                                'Color',
                                                tripDetails.car.color ?? 'Unavailable',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        
                                        // الصف الثاني من البيانات
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildCarDetailItem(
                                                Icons.directions_car,
                                                'Type',
                                                tripDetails.car.carType ?? 'Unavailable',
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildCarDetailItem(
                                                Icons.category,
                                                'Category',
                                                tripDetails.car.carCategory ?? 'Unavailable',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        
                                        // الصف الثالث من البيانات
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildCarDetailItem(
                                                Icons.settings,
                                                'Transmission',
                                                tripDetails.car.transmissionType ?? 'Unavailable',
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildCarDetailItem(
                                                Icons.local_gas_station,
                                                'Fuel',
                                                tripDetails.car.fuelType ?? 'Unavailable',
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        
                                        // الصف الرابع من البيانات
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildCarDetailItem(
                                                Icons.event_seat,
                                                'Seats',
                                                '${tripDetails.car.seatingCapacity ?? 0}',
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _buildCarDetailItem(
                                                Icons.confirmation_number,
                                                'Plate Number',
                                                tripDetails.car.plateNumber ?? 'Unavailable',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 18),
                              // Section 2: Pickup & Dropoff + Dates
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Icon(Icons.radio_button_checked, color: theme.primaryColor, size: 22),
                                          Container(
                                            width: 2,
                                            height: 38,
                                            color: Colors.grey[300],
                                          ),
                                          const Icon(Icons.location_on, color: Colors.red, size: 24),
                                        ],
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text('Pickup', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                                const SizedBox(width: 8),
                                                Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(_formatDate(tripDetails.startDate), style: theme.textTheme.bodyMedium?.copyWith(color: Colors.blue)),
                                              ],
                                            ),
                                            Text(tripDetails.pickupLocation, style: theme.textTheme.bodyLarge),
                                            const SizedBox(height: 18),
                                            Row(
                                              children: [
                                                Text('Dropoff', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                                                const SizedBox(width: 8),
                                                Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(_formatDate(tripDetails.endDate), style: theme.textTheme.bodyMedium?.copyWith(color: Colors.blue)),
                                              ],
                                            ),
                                            Text(tripDetails.dropoffLocation, style: theme.textTheme.bodyLarge),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              // Section 3: Price with money icon on the right side of the card
                              Card(
                                color: theme.colorScheme.primary.withOpacity(0.07),
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text('Total Price:', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                            const SizedBox(width: 8),
                                            Text('${tripDetails.totalPrice.toStringAsFixed(2)} EGP', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.green[700])),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => _showPricingDetails(context),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: theme.primaryColor.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.attach_money, color: Colors.green, size: 28),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              // Section 4: Renter & Payment
                              Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.person, color: theme.primaryColor),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Renter', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                            Text(tripDetails.renterName, style: theme.textTheme.bodyMedium),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Icon(Icons.account_balance_wallet, color: Colors.orange[700], size: 22),
                                                const SizedBox(width: 6),
                                                Text('Payment Method:', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                                const SizedBox(width: 4),
                                                Text(tripDetails.paymentMethod, style: theme.textTheme.bodyLarge),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Sticky action buttons
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final rentalId = widget.rentalId ?? tripDetails.rentalId;
                                  print('🔍 [TripDetailsConfirmationScreen] Continue button pressed');
                                  print('🔍 [TripDetailsConfirmationScreen] widget.rentalId: [38;5;5m${widget.rentalId}[0m');
                                  print('🔍 [TripDetailsConfirmationScreen] tripDetails.rentalId: ${tripDetails.rentalId}');
                                  print('🔍 [TripDetailsConfirmationScreen] Final rentalId: $rentalId (type: ${rentalId.runtimeType})');
                                  
                                  if (rentalId != null && rentalId is int) {
                                    print('✅ [TripDetailsConfirmationScreen] Valid rentalId found: $rentalId');
                                    
                                    final arguments = {
                                      'paymentMethod': tripDetails.paymentMethod,
                                      'rentalId': rentalId,
                                    };
                                    print('🔍 [TripDetailsConfirmationScreen] Navigation arguments: $arguments');
                                    
                                    Navigator.pushNamed(
                                      context,
                                      ScreensName.handoverScreen,
                                      arguments: arguments,
                                    );
                                  } else {
                                    print('❌ [TripDetailsConfirmationScreen] Invalid or missing rentalId: $rentalId');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: Rental ID is missing or invalid!'),
                                        backgroundColor: Colors.red,
                                        duration: Duration(seconds: 3),
                                        action: SnackBarAction(
                                          label: 'Close',
                                          textColor: Colors.white,
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                          },
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Confirm ->'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/cancel-rental');
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showPricingDetails(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text('Booking Overview', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildOverviewItem(Icons.check_circle, tr("third_party_insurance"),
                    AppColors.primary),
                _buildOverviewItem(
                    Icons.check_circle, tr("collision_damage_waiver"), AppColors.primary),
                _buildOverviewItem(
                    Icons.check_circle, tr("theft_protection"), AppColors.primary),
                _buildOverviewItem(
                    Icons.check_circle, tr("km_included"), AppColors.primary),
                _buildOverviewItem(
                    Icons.check_circle, tr("flexible_booking"), AppColors.primary),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Back to Confirmation'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCarImage(CarModel car) {
    final imageUrl = car.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.network(
          imageUrl,
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.directions_car, size: 90, color: Colors.grey),
      );
    }
  }

  Widget _buildCarDetailItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 