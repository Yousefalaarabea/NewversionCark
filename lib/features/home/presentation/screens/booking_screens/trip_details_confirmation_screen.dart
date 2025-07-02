import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../config/routes/screens_name.dart';
import '../../../../../config/themes/app_colors.dart';
import '../../model/trip_details_model.dart';

class TripDetailsConfirmationScreen extends StatelessWidget {
  static const routeName = ScreensName.tripDetailsConfirmationScreen;
  final TripDetailsModel tripDetails;

  const TripDetailsConfirmationScreen({super.key, required this.tripDetails});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Trip Details'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section 1: Car Details
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: tripDetails.car.imageUrl.isNotEmpty
                                  ? Image.network(
                                      tripDetails.car.imageUrl,
                                      width: 110,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 110,
                                      height: 90,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.directions_car, size: 50, color: Colors.grey),
                                    ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${tripDetails.car.brand} ${tripDetails.car.model}',
                                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                                      const SizedBox(width: 6),
                                      Text('Year: ${tripDetails.car.year}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.local_gas_station, size: 20, color: Colors.grey[600]),
                                      const SizedBox(width: 6),
                                      Text('Fuel: ${tripDetails.car.fuelType}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.confirmation_number, size: 20, color: Colors.grey[600]),
                                      const SizedBox(width: 6),
                                      Text('Plate: ${tripDetails.car.plateNumber}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                ],
                              ),
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
                        Navigator.pushNamed(context,
                            ScreensName.handoverScreen,
                          arguments: {
                            'paymentMethod': tripDetails.paymentMethod,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Continue'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/cancel-rental');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                _buildOverviewItem(Icons.check_circle,
                    tr("collision_damage_waiver"), AppColors.primary),
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
} 