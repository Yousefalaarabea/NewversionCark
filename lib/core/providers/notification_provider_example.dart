// مثال على كيفية استخدام NotificationProvider
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notification_provider.dart';

class NotificationProviderExample extends StatefulWidget {
  @override
  _NotificationProviderExampleState createState() => _NotificationProviderExampleState();
}

class _NotificationProviderExampleState extends State<NotificationProviderExample> {
  @override
  void initState() {
    super.initState();
    
    // بدء الـ polling عند دخول الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().startPolling();
    });
  }

  @override
  void dispose() {
    // إيقاف الـ polling عند الخروج من الشاشة
    context.read<NotificationProvider>().stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الإشعارات'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {
                      // Navigate to notifications screen
                    },
                  ),
                  // عرض badge للإشعارات غير المقروءة
                  if (notificationProvider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
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
                          '${notificationProvider.unreadCount}',
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
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading && notificationProvider.notifications.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // إحصائيات الإشعارات
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('الإجمالي', notificationProvider.totalCount),
                    _buildStatCard('غير مقروءة', notificationProvider.unreadCount),
                    _buildStatCard('مقروءة', notificationProvider.readCount),
                  ],
                ),
              ),
              
              // أزرار الإجراءات
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        notificationProvider.markAllAsRead();
                      },
                      child: Text('تمييز الكل كمقروء'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        notificationProvider.fetchNotifications();
                      },
                      child: Text('تحديث'),
                    ),
                  ],
                ),
              ),
              
              // قائمة الإشعارات
              Expanded(
                child: ListView.builder(
                  itemCount: notificationProvider.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notificationProvider.notifications[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: Icon(
                          notification.isRead ? Icons.mark_email_read : Icons.mark_email_unread,
                          color: notification.isRead ? Colors.grey : Colors.blue,
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
                              notification.timeAgo,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: !notification.isRead
                            ? IconButton(
                                icon: Icon(Icons.done, color: Colors.green),
                                onPressed: () {
                                  notificationProvider.markAsRead(notification.id);
                                },
                              )
                            : null,
                        onTap: () {
                          // إذا لم يكن مقروءاً، قم بتمييزه كمقروء
                          if (!notification.isRead) {
                            notificationProvider.markAsRead(notification.id);
                          }
                          
                          // Navigate to notification details or related screen
                          _handleNotificationTap(notification);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _handleNotificationTap(notification) {
    // يمكنك هنا إضافة التنقل حسب نوع الإشعار
    switch (notification.notificationType) {
      case 'booking_request':
        // Navigate to booking screen
        break;
      case 'payment':
        // Navigate to payment screen
        break;
      case 'handover':
        // Navigate to handover screen
        break;
      default:
        // Default action
        break;
    }
  }
} 