import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../config/routes/screens_name.dart';
import '../../../home/presentation/model/trip_details_model.dart';
import '../../../home/presentation/screens/booking_screens/trip_details_confirmation_screen.dart';
import '../cubits/notification_cubit.dart';
import 'package:test_cark/config/themes/app_colors.dart';
import 'dart:async';
import 'package:test_cark/features/handover/handover/presentation/screens/renter_handover_screen.dart';

class NewNotificationsScreen extends StatefulWidget {
  @override
  _NewNotificationsScreenState createState() => _NewNotificationsScreenState();
}

class _NewNotificationsScreenState extends State<NewNotificationsScreen> {
  Timer? _autoRefreshTimer;

  // دالة مساعدة لاستخراج rentalId من بيانات الإشعار
  int? _extractRentalId(Map<String, dynamic>? notificationData) {
    if (notificationData == null) return null;
    
    final dynamic rawRentalId = notificationData['rentalId'] ??
                                notificationData['rental_id'] ??
                                notificationData['id'] ??
                                notificationData['rental'];
    
    print(
        '🔍 [_extractRentalId] Raw rentalId: $rawRentalId (type: ${rawRentalId.runtimeType})');
    
    if (rawRentalId is int) {
      print('✅ [_extractRentalId] rentalId is int: $rawRentalId');
      return rawRentalId;
    } else if (rawRentalId is String) {
      final parsed = int.tryParse(rawRentalId);
      print('✅ [_extractRentalId] rentalId parsed from string: $parsed');
      return parsed;
    } else if (rawRentalId != null) {
      final parsed = int.tryParse(rawRentalId.toString());
      print(
          '✅ [_extractRentalId] rentalId converted from ${rawRentalId.runtimeType}: $parsed');
      return parsed;
    } else {
      print('❌ [_extractRentalId] No rentalId found in notification data');
      return null;
    }
  }

  // دالة مساعدة لعرض رسائل الخطأ
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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

  // دالة مساعدة لطباعة تفاصيل الإشعار للتشخيص
  void _printNotificationDetails(AppNotification notification, String context) {
    print('🔍 [$context] Notification Details:');
    print('  - ID: ${notification.id}');
    print('  - Type: ${notification.type}');
    print('  - NotificationType: ${notification.notificationType}');
    print('  - Title: ${notification.title}');
    print('  - Message: ${notification.message}');
    print('  - Data: ${notification.data}');
    print('  - NavigationId: ${notification.navigationId}');
    print('  - Sender: ${notification.sender}');
    print('  - Receiver: ${notification.receiver}');
    print('  - Date: ${notification.date}');
    print('  - IsRead: ${notification.isRead}');
  }

  // دالة مساعدة لتحليل جميع إشعارات DEP_OWNER
  void _analyzeDepOwnerNotifications() {
    print('🔍 [DEBUG] Analyzing all DEP_OWNER notifications...');
    context.read<NotificationCubit>().analyzeNotificationsByType('DEP_OWNER');
  }

  @override
  void initState() {
    super.initState();
    // جلب الإشعارات من الـ API عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationCubit>().getAllNotifications();
    });
    // تحديث تلقائي كل دقيقتين
    print(
        '[NotificationScreen] Starting auto-refresh timer with interval: ${NotificationCubit.defaultPollingInterval}');
    _autoRefreshTimer =
        Timer.periodic(NotificationCubit.defaultPollingInterval, (_) {
      print('[NotificationScreen] Auto-refresh triggered at ${DateTime.now()}');
      context.read<NotificationCubit>().fetchNewNotifications();
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  // OLD: dispose method for polling
  // @override
  // void dispose() {
  //   // إيقاف الـ polling عند إغلاق الشاشة
  //   Provider.of<NotificationProvider>(context, listen: false).stopPolling();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded) {
                final unreadCount =
                    state.notifications.where((n) => !n.isRead).length;
                if (unreadCount > 0) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications),
                        onPressed: () {
                          context.read<NotificationCubit>().markAllAsRead();
                        },
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }
              return IconButton(
                icon: Icon(Icons.notifications_none),
                onPressed: () {},
              );
            },
          ),
        ],
      ),
      backgroundColor: AppColors.primary,
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications, color: Colors.white, size: 35),
                      SizedBox(width: 10),
                      Text(
                        'Loading notifications...',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Back'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationLoaded) {
            final notifications = state.notifications;
            final unreadCount = notifications.where((n) => !n.isRead).length;
            final readCount = notifications.where((n) => n.isRead).length;

            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_none,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No notifications',
                        style: TextStyle(fontSize: 18, color: Colors.grey)),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<NotificationCubit>()
                                .getAllNotifications();
                          },
                          child: Text('Refresh'),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Back'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // قائمة الإشعارات
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await context.read<NotificationCubit>().getAllNotifications();
                    },
                    child: ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return NotificationCard(
                          notification: notification,
                          onTap: () =>
                              _handleNotificationTap(context, notification),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error loading notifications',
                      style: TextStyle(fontSize: 18, color: Colors.red)),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<NotificationCubit>()
                              .getAllNotifications();
                        },
                        child: Text('Retry'),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Back'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading...'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Back'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showNotificationDetails(
      BuildContext context, AppNotification notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(notification.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(notification.message),
                SizedBox(height: 16),
                Text(
                    'Type: ${notification.notificationType ?? notification.type}'),
                if (notification.priority != null) ...[
                  SizedBox(height: 8),
                  Text(
                      'Priority: ${notification.priorityDisplay ?? notification.priority}'),
                ],
                if (notification.timeAgo != null) ...[
                  SizedBox(height: 8),
                  Text('Time: ${notification.timeAgo}'),
                ],
                if (notification.data != null &&
                    notification.data!.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text('Additional Data:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  ...notification.data!.entries.map((entry) => Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text('${entry.key}: ${entry.value}'),
                      )),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showCountsDialog(BuildContext context, Map<String, int> counts) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notification statistics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCountRow('Total', counts['total'] ?? 0, Colors.blue),
              SizedBox(height: 8),
              _buildCountRow('Unread', counts['unread'] ?? 0, Colors.red),
              SizedBox(height: 8),
              _buildCountRow('Read', counts['read'] ?? 0, Colors.green),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _handleNotificationTap(
      BuildContext context, AppNotification notification) {
    // Mark as read
    if (!notification.isRead) {
      context.read<NotificationCubit>().markAsRead(notification.id);
    }
    switch (notification.navigationId) {
      case 'REQ_OWNER':
        // Debug logs
        print('Navigating to ownerTripRequestScreen');
        print('Notification ID: ${notification.id}');
        print('Notification Data: ${notification.data}');
        
        Navigator.pushNamed(context, ScreensName.ownerTripRequestScreen,
          arguments: {
            'bookingRequestId': notification.id ?? 'unknown',
            'bookingData': notification.data ?? {},
            });
        break;
      case 'ACC_RENTER':
        print('Navigating to ownerTripRequestScreen');
        print('Notification ID: ${notification.id}');
        print('Notification Data: ${notification.data}');

        Navigator.pushNamed(context, ScreensName.paymentMethodsScreen,
            arguments: {
              'bookingRequestId': notification.id ?? 'unknown',
              'bookingData': notification.data ?? {},
            });
        break;
      case 'REJ_RENTER':
        Navigator.pushNamed(context, ScreensName.bookingHistoryScreen,
            arguments: notification.data);
        break;
      case 'DEP_OWNER':
        final tripDetails =
            TripDetailsModel.fromNotificationData1(notification.data ?? {});
          
          if (tripDetails.rentalId == null) {
            print('❌ rentalId is null! ');
            _showErrorSnackBar('Error: rentalId is missing in notification');
            _showNotificationDetails(context, notification);
            return;
          }
          
        print(
            '✅ [DEP_OWNER] Successfully created TripDetailsModel with rentalId: ${tripDetails.rentalId}');
        print(
            '✅ [DEP_OWNER] About to navigate with rentalId: ${tripDetails.rentalId}');

                     Navigator.push(
             context,
             MaterialPageRoute(
               builder: (_) => TripDetailsConfirmationScreen(
                 tripDetails: tripDetails,
                 rentalId: tripDetails.rentalId,
               ),
             ),
           );

        break;
      case 'REN_PICKUP_HND':
        try {
          _printNotificationDetails(notification, 'RENTER_PICKUP');
          
          final rentalId = _extractRentalId(notification.data);
          
          if (rentalId != null) {
            print(
                '✅ [RENTER_PICKUP] Successfully extracted rentalId: $rentalId');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RenterHandoverScreen(
                  rentalId: rentalId,
                  notification: notification,
                ),
              ),
            );
          } else {
            print('❌ [RENTER_PICKUP] rentalId is null! Cannot proceed.');
            _showErrorSnackBar('Error: rentalId is missing in notification');
            _showNotificationDetails(context, notification);
          }
        } catch (e) {
          print(
              '❌ [RENTER_PICKUP] Error navigating to RenterHandoverScreen: $e');
          print('❌ [RENTER_PICKUP] Stack trace: ${StackTrace.current}');
          _showErrorSnackBar('Error processing notification data');
          _showNotificationDetails(context, notification);
        }
        break;
      // case 'OWN_PICKUP_COMPLETE':
      //   Navigator.pushNamed(context, ScreensName.renterHandoverScreen, arguments: notification.data);
      //   break;
      case 'REN_ONGOING':
        Navigator.pushNamed(context, ScreensName.renterOngoingTripScreen,
            arguments: notification);
        break;
      case 'OWN_ONGOING':
        Navigator.pushNamed(context, ScreensName.ownerOngoingTripScreen,
            arguments: notification);
        break;
      // case 'GET_LOC_SCR':
      //   // TODO: Replace with get location screen if exists
      //   Navigator.pushNamed(context, ScreensName.liveLocationMapScreen, arguments: notification.data);
      //   break;
      case 'REN_DRP_HND':
        Navigator.pushNamed(context, ScreensName.renterDropOffScreen,
            arguments: notification.data);
        break;
      case 'OWNER_DROPOFF_REQUIR':
        // Try to extract the raw notification map
        dynamic notifMap;
        if (notification is Map<String, dynamic>) {
          notifMap = notification;
        } else if (notification is AppNotification && notification.data != null) {
          notifMap = notification.data;
        } else {
          notifMap = notification;
        }
        if (notifMap is Map<String, dynamic> && notifMap['notification'] is Map<String, dynamic>) {
          Navigator.pushNamed(context, ScreensName.ownerDropOffScreen,
              arguments: notifMap['notification'] as Map<String, dynamic>);
        } else {
          Navigator.pushNamed(context, ScreensName.ownerDropOffScreen,
              arguments: notifMap as Map<String, dynamic>);
        }
        break;
      case 'SUM_VIEW':
        // TODO: Replace with summary screen if exists
        Navigator.pushNamed(context, ScreensName.bookingHistoryScreen,
            arguments: notification.data);
        break;
      case 'NAV_HOME':
        Navigator.pushNamedAndRemoveUntil(
            context, ScreensName.homeScreen, (route) => false);
        break;
      default:
        // Default: just show details dialog or do nothing
        _showNotificationDetails(context, notification);
        break;
    }
  }

  Widget _buildCountRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Widget للإشعار الواحد
class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationCard({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: notification.isRead ? 1 : 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getColorByType(
              notification.notificationType ?? notification.type),
          child: Icon(
            _getIconByType(notification.notificationType ?? notification.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            SizedBox(height: 4),
            Text(
              notification.timeAgo ?? _getTimeAgo(notification.date),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: notification.isRead
            ? Icon(Icons.check_circle, color: Colors.green)
            : Icon(Icons.circle, color: Colors.red),
        onTap: onTap,
        tileColor: notification.isRead ? null : Colors.blue.withOpacity(0.05),
      ),
    );
  }

  Color _getColorByType(String type) {
    switch (type) {
      case 'RENTAL':
        return Colors.blue;
      case 'PAYMENT':
        return Colors.green;
      case 'SYSTEM':
        return Colors.orange;
      case 'PROMOTION':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconByType(String type) {
    switch (type) {
      case 'RENTAL':
        return Icons.directions_car;
      case 'PAYMENT':
        return Icons.payment;
      case 'SYSTEM':
        return Icons.settings;
      case 'PROMOTION':
        return Icons.local_offer;
      default:
        return Icons.notifications;
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
