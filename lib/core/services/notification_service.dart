import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../features/notifications/presentation/models/notification_model.dart';
import '../../main.dart'; // For navigatorKey

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Call this from main() or app init
  Future<void> init() async {
    await _requestPermissions();
    await _setupFCMToken();
    _setupFCMListeners();
  }

  // Request notification permissions for Android and iOS
  Future<void> _requestPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  // Get FCM token and send to backend
  Future<void> _setupFCMToken() async {
    final token = await _messaging.getToken();
    if (token != null) {
      await _sendTokenToBackend(token);
    }
    // Optionally listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      await _sendTokenToBackend(newToken);
    });
  }

  // Send token to backend
  Future<void> _sendTokenToBackend(String token) async {
    final url = Uri.parse('https://example.com/api/save-token/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );
      if (response.statusCode == 200) {
        debugPrint('FCM token sent to backend successfully');
      } else {
        debugPrint(
            'Failed to send FCM token to backend: \\${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending FCM token to backend: $e');
    }
  }

  // Set up FCM listeners for foreground, background, and terminated
  void _setupFCMListeners() {
    // Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM onMessage: \\${message.data}');
      // Optionally show a dialog/snackbar/local notification here
    });

    // Background (when app is opened from notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM onMessageOpenedApp: \\${message.data}');
      // Handle navigation or logic here
    });
  }

  // Call this in main() after init to handle notification tap when app is terminated
  Future<void> handleInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('FCM getInitialMessage: \\${initialMessage.data}');
      // Handle navigation or logic here
    }
  }

  late FlutterLocalNotificationsPlugin _localNotifications;

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    _localNotifications = FlutterLocalNotificationsPlugin();
    await _localNotifications.initialize(initSettings);
  }

  void _onMessage(RemoteMessage message) {
    if (message.notification != null) {
      _showLocalNotification(message.notification!, message.data);
    }
    // Optionally, save to Firestore here if not already done by backend
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    _handleNotificationNavigation(message.data);
  }

  //
  // void handleInitialMessage(RemoteMessage message) {
  //   _handleNotificationNavigation(message.data);
  // }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final notificationType = data['notification_type'];
    final bookingData = data['booking_data'];
    // TODO: Parse bookingData if needed, and get current userId from AuthCubit

    switch (notificationType) {
      case 'booking_accepted':
        navigatorKey.currentState
            ?.pushNamed('depositPaymentScreen', arguments: bookingData);
        break;
      case 'handover':
        navigatorKey.currentState
            ?.pushNamed('handoverScreen', arguments: bookingData);
        break;
      // Add more cases as needed
      default:
        navigatorKey.currentState?.pushNamed('homeScreen');
    }
  }

  Future<void> _showLocalNotification(
      RemoteNotification notification, Map<String, dynamic> data) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default',
      importance: Importance.max,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: data.toString(),
    );
  }

  Future<String?> getFcmToken() async {
    return await _messaging.getToken();
  }

  Future<void> saveFcmTokenToUser(String userId, String fcmToken) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fcm_token': fcmToken,
        'fcm_token_updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // Get FCM token for a specific user
  Future<String?> getUserFcmToken(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final token = doc.data()?['fcm_token'];
      if (token != null && token.isNotEmpty) {
        return token;
      } else {
        print('FCM token not found or empty for user: $userId');
        return null;
      }
    } catch (e) {
      print('Error getting FCM token for user $userId: $e');
      return null;
    }
  }

  // Get all renter FCM tokens
  Future<List<String>> getAllRenterFcmTokens() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'renter')
          .get();

      List<String> tokens = [];
      for (var doc in querySnapshot.docs) {
        final token = doc.data()['fcm_token'];
        if (token != null && token.isNotEmpty) {
          tokens.add(token);
        }
      }
      return tokens;
    } catch (e) {
      print('Error getting renter FCM tokens: $e');
      return [];
    }
  }

  // Send notification when a new car is added (to all renters)
  Future<void> sendNewCarNotification({
    required String carBrand,
    required String carModel,
    required String ownerName,
  }) async {
    try {
      // Get all renter FCM tokens
      final renterTokens = await getAllRenterFcmTokens();

      if (renterTokens.isEmpty) {
        print('No renter FCM tokens found');
        return;
      }

      // Create notification data for FCM
      final notificationData = {
        'title': '🚗 New Car Available!',
        'body': 'A new car has been added for rent!',
        'type': 'new_car',
        'car_brand': carBrand,
        'car_model': carModel,
        'owner_name': ownerName,
      };

      // Send to all renters (in a real app, this would be done via backend)
      for (String token in renterTokens) {
        await _sendFcmNotification(token, notificationData);
      }

      // Also save to Firestore for in-app notifications
      await _saveNewCarNotificationToFirestore(carBrand, carModel, ownerName);

      print('New car notification sent to ${renterTokens.length} renters');
    } catch (e) {
      print('Error sending new car notification: $e');
    }
  }

  // Send notification when a car is booked (to car owner)
  Future<void> sendCarBookedNotification({
    required String ownerId,
    required String renterName,
    required String carBrand,
    required String carModel,
  }) async {
    try {
      // Get owner's FCM token
      final ownerToken = await getUserFcmToken(ownerId);

      if (ownerToken == null) {
        print('Owner FCM token not found for user: $ownerId');
        return;
      }

      // Create notification data for FCM
      final notificationData = {
        'title': '✅ Car Booked!',
        'body': 'Your car has been booked by $renterName.',
        'type': 'car_booked',
        'renter_name': renterName,
        'car_brand': carBrand,
        'car_model': carModel,
      };

      // Send FCM notification
      await _sendFcmNotification(ownerToken, notificationData);

      // Also save to Firestore for in-app notifications
      await _saveCarBookedNotificationToFirestore(
          ownerId, renterName, carBrand, carModel);

      print('Car booked notification sent to owner: $ownerId');
    } catch (e) {
      print('Error sending car booked notification: $e');
    }
  }

  // Helper method to send FCM notification (simulated - in real app this would be via backend)
  Future<void> _sendFcmNotification(
      String token, Map<String, dynamic> data) async {
    try {
      // In a real implementation, this would be done via your backend server
      // For now, we'll simulate the notification by showing a local notification
      await _showLocalNotification(
          RemoteNotification(
            title: data['title'],
            body: data['body'],
          ),
          data);

      print('FCM notification would be sent to token: $token');
      print('Notification data: $data');
    } catch (e) {
      print('Error sending FCM notification: $e');
      // Don't throw the error to avoid crashing the app
    }
  }

  // Save new car notification to Firestore for all renters
  Future<void> _saveNewCarNotificationToFirestore(
      String carBrand, String carModel, String ownerName) async {
    try {
      // Get all renter user IDs
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'renter')
          .get();

      // Create notification for each renter
      for (var doc in querySnapshot.docs) {
        final renterId = doc.id;
        await FirebaseFirestore.instance.collection('notifications').add({
          'userId': renterId,
          'title': '🚗 New Car Available!',
          'body':
              'A new $carBrand $carModel has been added for rent by $ownerName.',
          'type': 'renter',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
          'notification_type': 'new_car',
          'car_brand': carBrand,
          'car_model': carModel,
        });
      }
    } catch (e) {
      print('Error saving new car notification to Firestore: $e');
    }
  }

  // Save car booked notification to Firestore for owner
  Future<void> _saveCarBookedNotificationToFirestore(String ownerId,
      String renterName, String carBrand, String carModel) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': ownerId,
        'title': '✅ Car Booked!',
        'body': 'Your $carBrand $carModel has been booked by $renterName.',
        'type': 'owner',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'notification_type': 'car_booked',
        'renter_name': renterName,
        'car_brand': carBrand,
        'car_model': carModel,
      });
    } catch (e) {
      print('Error saving car booked notification to Firestore: $e');
    }
  }

  // Send notification to a specific user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required String type, // 'owner', 'renter', 'general'
    String?
        notificationType, // 'car_booked', 'booking_accepted', 'deposit_paid', 'handover_ready', 'handover', 'renter_handover_completed'
    Map<String, dynamic>? bookingData,
  }) async {
    final notificationData = {
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    };

    // Add notification type if provided
    if (notificationType != null) {
      notificationData['notification_type'] = notificationType;
    }

    // Add booking data if provided
    if (bookingData != null) {
      notificationData['booking_data'] = bookingData;
    }

    await FirebaseFirestore.instance
        .collection('notifications')
        .add(notificationData);
  }

  // Send booking notifications for both renter and owner
  Future<void> sendBookingNotifications({
    required String renterId,
    required String ownerId,
    required String carName,
  }) async {
    try {
      // Get user names for better notification messages
      final renterDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(renterId)
          .get();
      final ownerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(ownerId)
          .get();

      final renterName = renterDoc.data()?['first_name'] ?? 'A renter';
      final ownerName = ownerDoc.data()?['first_name'] ?? 'The owner';

      // Notification for renter
      final renterNotification = NewNotificationModel();

      // Notification for owner
      final ownerNotification = NewNotificationModel();

      // Save to Firestore
      // await FirebaseFirestore.instance
      //     .collection('notifications')
      //     .add(renterNotification.toMap());
      // await FirebaseFirestore.instance
      //     .collection('notifications')
      //     .add(ownerNotification.toMap());

      // Send FCM notifications
      await sendCarBookedNotification(
        ownerId: ownerId,
        renterName: renterName,
        carBrand: carName.split(' ').first,
        carModel: carName.split(' ').skip(1).join(' '),
      );

      print('Booking notifications sent successfully');
      print('Renter notification: ${renterNotification.toString()}');
      print('Owner notification: ${ownerNotification.toString()}');
    } catch (e) {
      print('Error sending booking notifications: $e');
    }
  }

  // Get notifications for a specific user and type
  // Stream<List<NotificationModel>> getNotificationsForUser(
  //     String userId, String type) {
  //   return FirebaseFirestore.instance
  //       .collection('notifications')
  //       .where('userId', isEqualTo: userId)
  //       .where('type', isEqualTo: type)
  //       .orderBy('timestamp', descending: true)
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs
  //           .map((doc) => NotificationModel.fromFirestore(doc))
  //           .toList());
  // }

  // Get all notifications for a user (both types)
  // Stream<List<NotificationModel>> getAllNotificationsForUser(String userId) {
  //   return FirebaseFirestore.instance
  //       .collection('notifications')
  //       .where('userId', isEqualTo: userId)
  //       .orderBy('timestamp', descending: true)
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs
  //           .map((doc) => NotificationModel.fromFirestore(doc))
  //           .toList());
  // }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({'read': true});
  }

  // Send booking acceptance notification to renter
  Future<void> sendBookingAcceptanceNotification({
    required String renterId,
    required String ownerName,
    required String carBrand,
    required String carModel,
  }) async {
    try {
      // Get renter's FCM token
      final renterToken = await getUserFcmToken(renterId);

      if (renterToken == null) {
        print('Renter FCM token not found for user: $renterId');
        return;
      }

      // Create notification data for FCM
      final notificationData = {
        'title': '✅ Booking Accepted!',
        'body':
            '$ownerName has accepted your booking request for $carBrand $carModel.',
        'type': 'booking_accepted',
        'owner_name': ownerName,
        'car_brand': carBrand,
        'car_model': carModel,
      };

      // Send FCM notification
      await _sendFcmNotification(renterToken, notificationData);

      // Also save to Firestore for in-app notifications
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': renterId,
        'title': '✅ Booking Accepted!',
        'body':
            '$ownerName has accepted your booking request for $carBrand $carModel. Please proceed to pay the deposit.',
        'type': 'renter',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'notification_type': 'booking_accepted',
        'owner_name': ownerName,
        'car_brand': carBrand,
        'car_model': carModel,
      });

      print('Booking acceptance notification sent to renter: $renterId');
    } catch (e) {
      print('Error sending booking acceptance notification: $e');
    }
  }

  // Send notification to owner to proceed to handover after deposit is paid
  Future<void> sendHandoverNotificationToOwner({
    required String ownerId,
    required String renterName,
    required String carBrand,
    required String carModel,
  }) async {
    try {
      // Get owner's FCM token
      final ownerToken = await getUserFcmToken(ownerId);

      if (ownerToken == null) {
        print('Owner FCM token not found for user: $ownerId');
        return;
      }

      // Create notification data for FCM
      final notificationData = {
        'title': '🚗 Proceed to Handover',
        'body':
            'Deposit has been paid for $carBrand $carModel. Please proceed to handover.',
        'type': 'handover_ready',
        'renter_name': renterName,
        'car_brand': carBrand,
        'car_model': carModel,
      };

      // Send FCM notification
      await _sendFcmNotification(ownerToken, notificationData);

      // Also save to Firestore for in-app notifications
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': ownerId,
        'title': '🚗 Proceed to Handover',
        'body':
            'Deposit has been paid for $carBrand $carModel by $renterName. Please proceed to handover.',
        'type': 'owner',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'notification_type': 'handover_ready',
        'renter_name': renterName,
        'car_brand': carBrand,
        'car_model': carModel,
        'action': 'navigate_to_handover',
      });

      print('Handover notification sent to owner: $ownerId');
    } catch (e) {
      print('Error sending handover notification: $e');
    }
  }

  // Send notification to renter that owner has completed handover
  Future<void> sendOwnerHandoverCompletedNotification({
    required String renterId,
    required String ownerName,
    required String carBrand,
    required String carModel,
  }) async {
    try {
      // Get renter's FCM token
      final renterToken = await getUserFcmToken(renterId);

      if (renterToken == null) {
        print('Renter FCM token not found for user: $renterId');
        return;
      }

      // Create notification data for FCM
      final notificationData = {
        'title': '✅ Owner Handover Completed',
        'body':
            '$ownerName has completed the handover for your $carBrand $carModel. Please proceed with your handover.',
        'type': 'owner_handover_completed',
        'owner_name': ownerName,
        'car_brand': carBrand,
        'car_model': carModel,
      };

      // Send FCM notification
      await _sendFcmNotification(renterToken, notificationData);

      // Also save to Firestore for in-app notifications
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': renterId,
        'title': '✅ Owner Handover Completed',
        'body':
            '$ownerName has completed the handover for your $carBrand $carModel. Please proceed with your handover.',
        'type': 'renter',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'notification_type': 'owner_handover_completed',
        'owner_name': ownerName,
        'car_brand': carBrand,
        'car_model': carModel,
        'action': 'navigate_to_renter_handover',
      });

      print('Owner handover completed notification sent to renter: $renterId');
    } catch (e) {
      print('Error sending owner handover completed notification: $e');
    }
  }

  // Send notification to owner that renter has completed handover
  Future<void> sendRenterHandoverCompletedNotification({
    required String ownerId,
    required String renterName,
    required String carBrand,
    required String carModel,
  }) async {
    try {
      // Get owner's FCM token
      final ownerToken = await getUserFcmToken(ownerId);

      if (ownerToken == null) {
        print('Owner FCM token not found for user: $ownerId');
        return;
      }

      // Create notification data for FCM
      final notificationData = {
        'title': '✅ Renter Handover Completed',
        'body':
            '$renterName has completed the handover for your $carBrand $carModel. The trip can now begin.',
        'type': 'renter_handover_completed',
        'renter_name': renterName,
        'car_brand': carBrand,
        'car_model': carModel,
      };

      // Send FCM notification
      await _sendFcmNotification(ownerToken, notificationData);

      // Also save to Firestore for in-app notifications
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': ownerId,
        'title': '✅ Renter Handover Completed',
        'body':
            '$renterName has completed the handover for your $carBrand $carModel. The trip can now begin.',
        'type': 'owner',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'notification_type': 'renter_handover_completed',
        'renter_name': renterName,
        'car_brand': carBrand,
        'car_model': carModel,
        'action': 'trip_started',
      });

      print('Renter handover completed notification sent to owner: $ownerId');
    } catch (e) {
      print('Error sending renter handover completed notification: $e');
    }
  }

  // Save notification to Firestore (if needed for local simulation)
  Future<void> saveNotificationToFirestore(
      Map<String, dynamic> notification) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .add(notification);
  }
}
