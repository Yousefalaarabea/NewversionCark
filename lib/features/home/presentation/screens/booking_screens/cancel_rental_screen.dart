import 'package:flutter/material.dart';

class CancelRentalScreen extends StatelessWidget {
  static const routeName = '/cancel-rental';
  const CancelRentalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Cancelled'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cancel, color: Colors.red, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Rent is cancelled and deposit will be returned to Renter account.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              IconButton(
                icon: const Icon(Icons.home, size: 40, color: Colors.blue),
                tooltip: 'Go to Home',
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/homeScreen', (route) => false);
                },
              ),
              const SizedBox(height: 8),
              const Text('Back to Home'),
            ],
          ),
        ),
      ),
    );
  }
}