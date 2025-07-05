# NotificationProvider Usage Guide

## Overview
`NotificationProvider` هو نظام إدارة الإشعارات باستخدام Provider pattern مع الـ polling للتحديث المستمر من الـ API.

## Files Structure
```
lib/core/
├── notification_service.dart           # خدمة الـ API للإشعارات
├── providers/
│   ├── notification_provider.dart      # Provider للإشعارات
│   ├── notification_provider_example.dart  # مثال على الاستخدام
│   └── README.md                      # هذا الملف
```

## Setup

### 1. Dependencies
تأكد من إضافة هذه الـ packages في `pubspec.yaml`:
```yaml
dependencies:
  provider: ^6.1.2
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

### 2. App Level Configuration
تم تكوين `NotificationProvider` في `lib/cark.dart`:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (context) => NotificationProvider(),
    ),
  ],
  child: MultiBlocProvider(
    // ... BLoC providers
  ),
)
```

## Usage Examples

### 1. Basic Usage in Widget

```dart
import 'package:provider/provider.dart';
import 'package:test_cark/core/providers/notification_provider.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
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
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return Column(
          children: [
            Text('عدد الإشعارات: ${notificationProvider.totalCount}'),
            Text('غير مقروءة: ${notificationProvider.unreadCount}'),
            // باقي الـ UI
          ],
        );
      },
    );
  }
}
```

### 2. Notification Badge

```dart
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
              child: Text(
                '${notificationProvider.unreadCount}',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  },
)
```

### 3. Notifications List

```dart
Consumer<NotificationProvider>(
  builder: (context, notificationProvider, child) {
    if (notificationProvider.isLoading) {
      return CircularProgressIndicator();
    }

    return ListView.builder(
      itemCount: notificationProvider.notifications.length,
      itemBuilder: (context, index) {
        final notification = notificationProvider.notifications[index];
        return ListTile(
          title: Text(notification.title),
          subtitle: Text(notification.message),
          trailing: !notification.isRead
              ? IconButton(
                  icon: Icon(Icons.done),
                  onPressed: () {
                    notificationProvider.markAsRead(notification.id);
                  },
                )
              : null,
          onTap: () {
            // Handle notification tap
            if (!notification.isRead) {
              notificationProvider.markAsRead(notification.id);
            }
          },
        );
      },
    );
  },
)
```

## Available Methods

### NotificationProvider Methods:

1. **startPolling()** - بدء الـ polling كل ثانية
2. **stopPolling()** - إيقاف الـ polling
3. **fetchNotifications()** - جلب الإشعارات يدوياً
4. **markAsRead(String id)** - تمييز إشعار كمقروء
5. **markAllAsRead()** - تمييز جميع الإشعارات كمقروءة

### Available Getters:

1. **notifications** - قائمة الإشعارات
2. **totalCount** - العدد الإجمالي
3. **unreadCount** - عدد الإشعارات غير المقروءة
4. **readCount** - عدد الإشعارات المقروءة
5. **stats** - إحصائيات الإشعارات
6. **isLoading** - حالة التحميل

## Best Practices

### 1. Polling Management
```dart
// بدء الـ polling في الشاشات المهمة فقط
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<NotificationProvider>().startPolling();
  });
}

// إيقاف الـ polling عند الخروج
@override
void dispose() {
  context.read<NotificationProvider>().stopPolling();
  super.dispose();
}
```

### 2. Selective Listening
```dart
// استخدم Consumer للـ widgets التي تحتاج للتحديث فقط
Consumer<NotificationProvider>(
  builder: (context, provider, child) {
    return Text('${provider.unreadCount}');
  },
)

// استخدم context.read للعمليات بدون rebuild
ElevatedButton(
  onPressed: () {
    context.read<NotificationProvider>().markAllAsRead();
  },
  child: Text('تمييز الكل كمقروء'),
)
```

### 3. Error Handling
```dart
Consumer<NotificationProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (provider.notifications.isEmpty) {
      return Text('لا توجد إشعارات');
    }
    
    return ListView.builder(
      // ... list implementation
    );
  },
)
```

## Configuration

### NotificationService Configuration
في `lib/core/notification_service.dart`:
```dart
class NotificationService {
  static const String baseUrl = 'http://127.0.0.1:8000/api'; // غير للـ URL بتاعك
  
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // تأكد من اسم الـ token key
  }
}
```

### Polling Interval
في `lib/core/providers/notification_provider.dart`:
```dart
// يمكنك تغيير المدة الزمنية للـ polling
_timer = Timer.periodic(Duration(seconds: 1), (timer) {
  fetchNotifications();
});
```

## Integration with Existing System

يمكنك استخدام `NotificationProvider` مع `NotificationCubit` الموجود:
```dart
// في الـ widget
Consumer<NotificationProvider>(
  builder: (context, notificationProvider, child) {
    // استخدم البيانات من NotificationProvider
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        // استخدم NotificationCubit للإشعارات المحلية
        return CombinedNotificationView(
          apiNotifications: notificationProvider.notifications,
          localNotifications: state.notifications,
        );
      },
    );
  },
)
```

## Troubleshooting

### 1. Polling Not Working
- تأكد من استدعاء `startPolling()` في `initState`
- تأكد من استدعاء `stopPolling()` في `dispose`

### 2. No Notifications Received
- تأكد من صحة الـ `baseUrl` في `NotificationService`
- تأكد من وجود `auth_token` في `SharedPreferences`
- تحقق من الـ API endpoints

### 3. Memory Leaks
- تأكد من إيقاف الـ polling في `dispose`
- استخدم `Consumer` بدلاً من `context.watch` عند الإمكان 