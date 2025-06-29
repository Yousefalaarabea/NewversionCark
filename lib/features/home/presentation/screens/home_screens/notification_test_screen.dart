import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/services/notification_service.dart';
import '../../../../auth/presentation/cubits/auth_cubit.dart';

class NotificationTestScreen extends StatelessWidget {
  const NotificationTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test Notification System',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Test new car notification
            ElevatedButton(
              onPressed: () async {
                try {
                  await NotificationService().sendNewCarNotification(
                    carBrand: 'Tesla',
                    carModel: 'Model S',
                    ownerName: 'John Doe',
                  );
                  _showSnackBar(context, 'New car notification sent!', false);
                } catch (e) {
                  _showSnackBar(context, 'Error: $e', true);
                }
              },
              child: Text(
                'Test New Car Notification',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test car booked notification
            ElevatedButton(
              onPressed: () async {
                try {
                  final authCubit = context.read<AuthCubit>();
                  final currentUser = authCubit.userModel;

                  if (currentUser == null) {
                    _showSnackBar(context, 'No user logged in', true);
                    return;
                  }

                  await NotificationService().sendCarBookedNotification(
                    ownerId: currentUser.id,
                    renterName: 'Test Renter',
                    carBrand: 'BMW',
                    carModel: 'X5',
                  );
                  _showSnackBar(
                      context, 'Car booked notification sent!', false);
                } catch (e) {
                  _showSnackBar(context, 'Error: $e', true);
                }
              },
              child: Text(
                'Test Car Booked Notification',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test booking notifications
            ElevatedButton(
              onPressed: () async {
                try {
                  final authCubit = context.read<AuthCubit>();
                  final currentUser = authCubit.userModel;

                  if (currentUser == null) {
                    _showSnackBar(context, 'No user logged in', true);
                    return;
                  }

                  await NotificationService().sendBookingNotifications(
                    renterId: currentUser.id,
                    ownerId: 'owner123',
                    carName: 'Toyota Camry',
                  );
                  _showSnackBar(context, 'Booking notifications sent!', false);
                } catch (e) {
                  _showSnackBar(context, 'Error: $e', true);
                }
              },
              child: Text(
                'Test Booking Notifications',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Current User Info:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final user = context.read<AuthCubit>().userModel;
                if (user == null) {
                  return const Text('No user logged in');
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${user.firstName} ${user.lastName}'),
                    Text('Email: ${user.email}'),
                    Text('Role: ${user.role}'),
                    Text('ID: ${user.id}'),
                    Text('FCM Token: ${user.fcmToken ?? 'Not set'}'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
