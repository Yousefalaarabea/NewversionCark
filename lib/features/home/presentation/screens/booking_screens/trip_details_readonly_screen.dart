import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../model/trip_details_model.dart';

class TripDetailsReadOnlyScreen extends StatefulWidget {
  final TripDetailsModel trip;
  const TripDetailsReadOnlyScreen({Key? key, required this.trip}) : super(key: key);

  @override
  State<TripDetailsReadOnlyScreen> createState() => _TripDetailsReadOnlyScreenState();
}

class _TripDetailsReadOnlyScreenState extends State<TripDetailsReadOnlyScreen> {
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Car and Trip Info
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: trip.car.imageUrl.isNotEmpty
                          ? Image.network(
                              trip.car.imageUrl,
                              width: 90,
                              height: 70,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 90,
                              height: 70,
                              color: Colors.grey[200],
                              child: const Icon(Icons.directions_car, size: 40, color: Colors.grey),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${trip.car.brand} ${trip.car.model}', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('Plate: ${trip.car.plateNumber}', style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 6),
                          Text('Pickup: ${trip.pickupLocation}', style: theme.textTheme.bodyMedium),
                          Text('Dropoff: ${trip.dropoffLocation}', style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 6),
                          Text('Start: ${trip.startDate.toLocal()}', style: theme.textTheme.bodySmall),
                          Text('End: ${trip.endDate.toLocal()}', style: theme.textTheme.bodySmall),
                          const SizedBox(height: 6),
                          Text('Total Price: ${trip.totalPrice.toStringAsFixed(2)} EGP', style: theme.textTheme.bodyMedium),
                          Text('Payment: ${trip.paymentMethod}', style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 6),
                          Text('Renter: ${trip.renterName}', style: theme.textTheme.bodySmall),
                          Text('Owner: ${trip.ownerName}', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Map Section
            if (trip.pickupLocationLat != null && trip.pickupLocationLng != null)
              SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(trip.pickupLocationLat!, trip.pickupLocationLng!),
                    zoom: 14,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('pickup'),
                      position: LatLng(trip.pickupLocationLat!, trip.pickupLocationLng!),
                      infoWindow: const InfoWindow(title: 'Pickup Location'),
                    ),
                  },
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),
            if (trip.pickupLocationLat == null || trip.pickupLocationLng == null)
              Container(
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('No map location available'),
              ),
            const SizedBox(height: 18),
            // Instructions Section
            Card(
              color: Colors.blue[50],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('🚗 Your Driver is Here', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('⏰ Do Not Be Late'),
                    SizedBox(height: 8),
                    Text('✍️ You can add extra instructions if needed.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _instructionsController,
              decoration: const InputDecoration(
                labelText: 'Extra Instructions',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              readOnly: false,
            ),
            const SizedBox(height: 20),
            // Trip With Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(trip.car.imageUrl),
                  radius: 24,
                ),
                title: const Text('Trip With'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text('Driver: ${trip.car.driverName ?? 'N/A'}'),
                    Text('Car: ${trip.car.brand} ${trip.car.model}'),
                    Text('Plate: ${trip.car.plateNumber}'),
                    Text('Rating: ${trip.car.driverRating?.toStringAsFixed(1) ?? 'N/A'}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 