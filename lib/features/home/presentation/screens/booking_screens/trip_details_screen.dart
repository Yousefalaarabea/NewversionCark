import 'package:flutter/material.dart';

class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // يمكن لاحقاً تمرير بيانات الرحلة عبر arguments
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: const [
                  Icon(Icons.directions_car, size: 64, color: Colors.blue),
                  SizedBox(height: 16),
                  Text('Your Trip is Ongoing', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Chip(label: Text('Ongoing', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Trip Details:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Placeholder details
            const Text('Car: BMW X5'),
            const Text('Start Date: 2024-06-01'),
            const Text('End Date: 2024-06-07'),
            const Text('Pickup Location: Downtown'),
            const Text('Odometer at Pickup: 12345'),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Back to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}