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
    
    print('🔍 [_extractRentalId] Raw rentalId: $rawRentalId (type: ${rawRentalId.runtimeType})');
    
    if (rawRentalId is int) {
      print('✅ [_extractRentalId] rentalId is int: $rawRentalId');
      return rawRentalId;
    } else if (rawRentalId is String) {
      final parsed = int.tryParse(rawRentalId);
      print('✅ [_extractRentalId] rentalId parsed from string: $parsed');
      return parsed;
    } else if (rawRentalId != null) {
      final parsed = int.tryParse(rawRentalId.toString());
      print('✅ [_extractRentalId] rentalId converted from ${rawRentalId.runtimeType}: $parsed');
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
          label: 'إغلاق',
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
    print('[NotificationScreen] Starting auto-refresh timer with interval: ${NotificationCubit.defaultPollingInterval}');
    _autoRefreshTimer = Timer.periodic(NotificationCubit.defaultPollingInterval, (_) {
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
        title: Text('الإشعارات'),
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
                final unreadCount = state.notifications.where((n) => !n.isRead).length;
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
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحميل الإشعارات...'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('العودة'),
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
                    Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('لا توجد إشعارات', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.read<NotificationCubit>().getAllNotifications();
                          },
                          child: Text('تحديث'),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('العودة'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // شريط الإحصائيات
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('الإجمالي', notifications.length, Colors.blue),
                      _buildStatCard('غير مقروءة', unreadCount, Colors.red),
                      _buildStatCard('مقروءة', readCount, Colors.green),
                    ],
                  ),
                ),

                // أزرار التحكم
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: unreadCount > 0 ? () {
                                context.read<NotificationCubit>().markAllAsRead();
                              } : null,
                              child: Text('تمييز الكل كمقروء'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<NotificationCubit>().getAllNotifications();
                              },
                              child: Text('تحديث'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<NotificationCubit>().getUnreadNotifications();
                              },
                              child: Text('غير المقروءة فقط'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final counts = await context.read<NotificationCubit>().getNotificationsCount();
                                _showCountsDialog(context, counts);
                              },
                              child: Text('الإحصائيات'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // OLD: Test buttons for adding dummy notifications
                      // Row(
                      //   children: [
                      //     Expanded(
                      //       child: ElevatedButton(
                      //         onPressed: () {
                      //           // إضافة إشعار تجريبي جديد
                      //           context.read<NotificationCubit>().addNotification(
                      //             title: 'إشعار تجريبي جديد',
                      //             message: 'هذا إشعار تجريبي تم إضافته للاختبار',
                      //             type: 'SYSTEM',
                      //             data: {'test': true},
                      //           );
                      //         },
                      //         child: Text('إضافة إشعار تجريبي'),
                      //         style: ElevatedButton.styleFrom(
                      //           backgroundColor: Colors.orange,
                      //           foregroundColor: Colors.white,
                      //         ),
                      //       ),
                      //     ),
                      //     SizedBox(width: 16),
                      //     Expanded(
                      //       child: ElevatedButton(
                      //         onPressed: () {
                      //           // حذف جميع الإشعارات
                      //           context.read<NotificationCubit>().clearAllNotifications();
                      //         },
                      //         child: Text('حذف الكل'),
                      //         style: ElevatedButton.styleFrom(
                      //           backgroundColor: Colors.red,
                      //           foregroundColor: Colors.white,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),

                // قائمة الإشعارات
                Expanded(
                  child: ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return NotificationCard(
                        notification: notification,
                        onTap: () => _handleNotificationTap(context, notification),
                      );
                    },
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
                  Text('خطأ في تحميل الإشعارات', style: TextStyle(fontSize: 18, color: Colors.red)),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          context.read<NotificationCubit>().getAllNotifications();
                        },
                        child: Text('إعادة المحاولة'),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('العودة'),
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
                Text('جاري التحميل...'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('العودة'),
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

  void _showNotificationDetails(BuildContext context, AppNotification notification) {
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
                Text('النوع: ${notification.notificationType ?? notification.type}'),
                if (notification.priority != null) ...[
                  SizedBox(height: 8),
                  Text('الأولوية: ${notification.priorityDisplay ?? notification.priority}'),
                ],
                if (notification.timeAgo != null) ...[
                  SizedBox(height: 8),
                  Text('الوقت: ${notification.timeAgo}'),
                ],
                if (notification.data != null && notification.data!.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text('البيانات الإضافية:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  ...notification.data!.entries.map((entry) => 
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text('${entry.key}: ${entry.value}'),
                    )
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إغلاق'),
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
          title: Text('إحصائيات الإشعارات'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCountRow('الإجمالي', counts['total'] ?? 0, Colors.blue),
              SizedBox(height: 8),
              _buildCountRow('غير مقروءة', counts['unread'] ?? 0, Colors.red),
              SizedBox(height: 8),
              _buildCountRow('مقروءة', counts['read'] ?? 0, Colors.green),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  void _handleNotificationTap(BuildContext context, AppNotification notification) {
    // Mark as read
    if (!notification.isRead) {
      context.read<NotificationCubit>().markAsRead(notification.id);
    }

    // Navigation logic based on navigationId (string)
    switch (notification.navigationId) {
      case 'REQ_OWNER':
        // Debug logs
        print('Navigating to ownerTripRequestScreen');
        print('Notification ID: ${notification.id}');
        print('Notification Data: ${notification.data}');
        
        // Pass both bookingRequestId and bookingData
        Navigator.pushNamed(
          context, 
          ScreensName.ownerTripRequestScreen, 
          arguments: {
            'bookingRequestId': notification.id ?? 'unknown',
            'bookingData': notification.data ?? {},
          }
        );
        break;
      case 'ACC_RENTER':
        // TODO: Replace with accept deposit/payment screen if exists
      // Debug logs
        print('Navigating to ownerTripRequestScreen');
        print('Notification ID: ${notification.id}');
        print('Notification Data: ${notification.data}');

        // Pass both bookingRequestId and bookingData
        Navigator.pushNamed(
            context,
            ScreensName.paymentMethodsScreen,
            arguments: {
              'bookingRequestId': notification.id ?? 'unknown',
              'bookingData': notification.data ?? {},
            }
        );
        break;
      case 'REJ_RENTER':
        // TODO: Replace with confirmation/cancellation screen if exists
        Navigator.pushNamed(context, ScreensName.bookingHistoryScreen, arguments: notification.data);
        break;
      case 'DEP_OWNER':
          final tripDetails = TripDetailsModel.fromNotificationData(notification.data ?? {});
          
          // التحقق من وجود rentalId قبل الانتقال
          if (tripDetails.rentalId == null) {
            print('❌ rentalId is null! aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
            _showErrorSnackBar('خطأ: رقم الرحلة غير متوفر في الإشعار');
            // عرض تفاصيل الإشعار كبديل
            _showNotificationDetails(context, notification);
            return;
          }
          
                     print('✅ [DEP_OWNER] Successfully created TripDetailsModel with rentalId: ${tripDetails.rentalId}');
           print('✅ [DEP_OWNER] About to navigate with rentalId: ${tripDetails.rentalId}');

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
          
          // استخدام الدالة المساعدة لاستخراج rentalId
          final rentalId = _extractRentalId(notification.data);
          
          if (rentalId != null) {
            print('✅ [RENTER_PICKUP] Successfully extracted rentalId: $rentalId');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RenterHandoverScreen(rentalId: rentalId, notification: notification,),
              ),
            );
          } else {
            print('❌ [RENTER_PICKUP] rentalId is null! Cannot proceed.');
            _showErrorSnackBar('خطأ: رقم الرحلة غير متوفر في الإشعار');
            _showNotificationDetails(context, notification);
          }
        } catch (e) {
          print('❌ [RENTER_PICKUP] Error navigating to RenterHandoverScreen: $e');
          print('❌ [RENTER_PICKUP] Stack trace: ${StackTrace.current}');
          _showErrorSnackBar('خطأ في معالجة بيانات الإشعار');
          _showNotificationDetails(context, notification);
        }
        break;
      // case 'OWN_PICKUP_COMPLETE':
      //   Navigator.pushNamed(context, ScreensName.renterHandoverScreen, arguments: notification.data);
      //   break;
      case 'REN_ONGOING':
        Navigator.pushNamed(context, ScreensName.renterOngoingTripScreen, arguments: notification.data);
        break;
      case 'OWN_ONGOING':
        Navigator.pushNamed(context, ScreensName.ownerOngoingTripScreen, arguments: notification.data);
        break;
      // case 'GET_LOC_SCR':
      //   // TODO: Replace with get location screen if exists
      //   Navigator.pushNamed(context, ScreensName.liveLocationMapScreen, arguments: notification.data);
      //   break;
      case 'REN_DRP_HND':
        Navigator.pushNamed(context, ScreensName.renterDropOffScreen, arguments: notification.data);
        break;
      case 'OWN_DRP_HND':
        Navigator.pushNamed(context, ScreensName.ownerDropOffScreen, arguments: notification.data);
        break;
      case 'SUM_VIEW':
        // TODO: Replace with summary screen if exists
        Navigator.pushNamed(context, ScreensName.bookingHistoryScreen, arguments: notification.data);
        break;
      case 'NAV_HOME':
        Navigator.pushNamedAndRemoveUntil(context, ScreensName.homeScreen, (route) => false);
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
          backgroundColor: _getColorByType(notification.notificationType ?? notification.type),
          child: Icon(
            _getIconByType(notification.notificationType ?? notification.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
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