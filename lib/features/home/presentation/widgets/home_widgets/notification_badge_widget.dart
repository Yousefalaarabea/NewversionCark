import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Commented out Firebase
import '../../../../auth/presentation/cubits/auth_cubit.dart';
import '../../../../notifications/presentation/cubits/notification_cubit.dart';

class NotificationBadgeWidget extends StatelessWidget {
  final VoidCallback onTap;
  final double size;

  const NotificationBadgeWidget({
    super.key,
    required this.onTap,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final currentUser = authCubit.userModel;

    if (currentUser == null) {
      return IconButton(
        icon: Icon(Icons.notifications, size: size),
        onPressed: onTap,
      );
    }

    // Use in-app notification system instead of Firebase
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        int unreadCount = 0;
        
        if (state is NotificationLoaded) {
          unreadCount = state.notifications.where((notification) => !notification.isRead).length;
        }

        return Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications, size: size),
              onPressed: onTap,
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
} 