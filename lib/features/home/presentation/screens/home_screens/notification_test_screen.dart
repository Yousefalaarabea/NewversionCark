import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../../notifications/presentation/cubits/notification_cubit.dart';

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
              'Test In-App Notification System',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Test new car notification
            ElevatedButton(
              onPressed: () {
                try {
                  context.read<NotificationCubit>().addNotification(
                    title: 'New Car Added',
                    message: 'John Doe has added a new Tesla Model S to the platform',
                    type: 'car_added',
                    data: {
                      'carBrand': 'Tesla',
                      'carModel': 'Model S',
                      'ownerName': 'John Doe',
                    },
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
              onPressed: () {
                try {
                  final authCubit = context.read<AuthCubit>();
                  final currentUser = authCubit.userModel;

                  if (currentUser == null) {
                    _showSnackBar(context, 'No user logged in', true);
                    return;
                  }

                  context.read<NotificationCubit>().sendBookingNotification(
                    renterName: 'Test Renter',
                    carBrand: 'BMW',
                    carModel: 'X5',
                    ownerId: currentUser.id.toString(),
                    renterId: 'renter123',
                    type: 'booking_request',
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

            // Test payment notification
            ElevatedButton(
              onPressed: () {
                try {
                  context.read<NotificationCubit>().sendPaymentNotification(
                    amount: '500.00',
                    carBrand: 'Toyota',
                    carModel: 'Camry',
                    type: 'deposit_paid',
                  );
                  _showSnackBar(context, 'Payment notification sent!', false);
                } catch (e) {
                  _showSnackBar(context, 'Error: $e', true);
                }
              },
              child: Text(
                'Test Payment Notification',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test handover notification
            ElevatedButton(
              onPressed: () {
                try {
                  context.read<NotificationCubit>().sendHandoverNotification(
                    carBrand: 'Mercedes',
                    carModel: 'C-Class',
                    type: 'handover_started',
                    userName: 'Jane Smith',
                  );
                  _showSnackBar(context, 'Handover notification sent!', false);
                } catch (e) {
                  _showSnackBar(context, 'Error: $e', true);
                }
              },
              child: Text(
                'Test Handover Notification',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test trip notification
            ElevatedButton(
              onPressed: () {
                try {
                  context.read<NotificationCubit>().sendTripNotification(
                    carBrand: 'Audi',
                    carModel: 'A4',
                    type: 'trip_started',
                  );
                  _showSnackBar(context, 'Trip notification sent!', false);
                } catch (e) {
                  _showSnackBar(context, 'Error: $e', true);
                }
              },
              child: Text(
                'Test Trip Notification',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test multiple notifications
            ElevatedButton(
              onPressed: () {
                try {
                  final cubit = context.read<NotificationCubit>();
                  
                  // Send multiple test notifications
                  cubit.sendBookingNotification(
                    renterName: 'John Doe',
                    carBrand: 'BMW',
                    carModel: 'X5',
                    ownerId: 'owner123',
                    renterId: 'renter456',
                    type: 'booking_request',
                  );
                  
                  cubit.sendPaymentNotification(
                    amount: '750.00',
                    carBrand: 'BMW',
                    carModel: 'X5',
                    type: 'payment_completed',
                  );
                  
                  cubit.sendHandoverNotification(
                    carBrand: 'BMW',
                    carModel: 'X5',
                    type: 'handover_completed',
                    userName: 'John Doe',
                  );
                  
                  cubit.sendTripNotification(
                    carBrand: 'BMW',
                    carModel: 'X5',
                    type: 'trip_completed',
                  );
                  
                  _showSnackBar(context, 'Multiple notifications sent!', false);
                } catch (e) {
                  _showSnackBar(context, 'Error: $e', true);
                }
              },
              child: Text(
                'Test Multiple Notifications',
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
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Notification Stats:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                if (state is NotificationLoaded) {
                  final unreadCount = context.read<NotificationCubit>().unreadCount;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Notifications: ${state.notifications.length}'),
                      Text('Unread Notifications: $unreadCount'),
                      Text('Read Notifications: ${state.notifications.length - unreadCount}'),
                    ],
                  );
                }
                return const Text('Loading notification stats...');
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
