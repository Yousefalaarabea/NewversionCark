# تكامل نظام الإشعارات مع الـ API

## نظرة عامة
تم تحديث نظام الإشعارات ليعمل مع الـ API الحقيقي بدلاً من البيانات التجريبية. النظام الآن يجلب الإشعارات من الخادم ويعرضها في التطبيق.

## الـ Endpoints المستخدمة

### 1. جلب جميع الإشعارات
```
GET {{base_url}}/api/notifications/notifications/
Headers: Authorization: Bearer {{token}}
```

### 2. جلب الإشعارات غير المقروءة
```
GET {{base_url}}/api/notifications/notifications/unread/
Headers: Authorization: Bearer {{token}}
```

### 3. جلب إحصائيات الإشعارات
```
GET {{base_url}}/api/notifications/notifications/count/
Headers: Authorization: Bearer {{token}}
```

### 4. تمييز إشعار كمقروء
```
POST {{base_url}}/api/notifications/notifications/{id}/mark_as_read/
Headers: Authorization: Bearer {{token}}
```

### 5. تمييز جميع الإشعارات كمقروءة
```
POST {{base_url}}/api/notifications/notifications/mark_all_as_read/
Headers: Authorization: Bearer {{token}}
```

## التغييرات الرئيسية

### 1. تحديث AppNotification Model
- إضافة حقول جديدة من الـ API:
  - `notificationType`
  - `priority`
  - `priorityDisplay`
  - `typeDisplay`
  - `timeAgo`
  - `sender`, `senderEmail`
  - `receiver`, `receiverEmail`
  - `readAt`
- إضافة factory method `fromJson` لتحويل البيانات من الـ API

### 2. تحديث NotificationCubit
- `getAllNotifications()`: يجلب الإشعارات من الـ API
- `getUnreadNotifications()`: يجلب الإشعارات غير المقروءة فقط
- `getNotificationsCount()`: يجلب إحصائيات الإشعارات
- `markAsRead()`: يحدث حالة الإشعار عبر الـ API
- `markAllAsRead()`: يحدث جميع الإشعارات عبر الـ API

### 3. تحديث NewNotificationsScreen
- استخدام `BlocBuilder` بدلاً من `Consumer`
- إضافة أزرار جديدة:
  - "غير المقروءة فقط": لعرض الإشعارات غير المقروءة
  - "الإحصائيات": لعرض إحصائيات الإشعارات
- إضافة dialog لعرض تفاصيل الإشعار
- إضافة dialog لعرض الإحصائيات

## كيفية الاستخدام

### 1. عرض الإشعارات
```dart
// في الشاشة
context.read<NotificationCubit>().getAllNotifications();
```

### 2. عرض الإشعارات غير المقروءة
```dart
context.read<NotificationCubit>().getUnreadNotifications();
```

### 3. تمييز إشعار كمقروء
```dart
context.read<NotificationCubit>().markAsRead(notificationId);
```

### 4. تمييز جميع الإشعارات كمقروءة
```dart
context.read<NotificationCubit>().markAllAsRead();
```

### 5. جلب الإحصائيات
```dart
final counts = await context.read<NotificationCubit>().getNotificationsCount();
```

## معالجة الأخطاء
- إذا فشل الـ API، يتم عرض الإشعارات المحلية
- يتم طباعة رسائل خطأ مفصلة في console
- يتم عرض رسائل خطأ للمستخدم في حالة فشل الاتصال

## الميزات الجديدة
1. **عرض تفاصيل الإشعار**: عند الضغط على إشعار، يتم عرض تفاصيله الكاملة
2. **إحصائيات الإشعارات**: عرض عدد الإشعارات الإجمالي والمقروءة وغير المقروءة
3. **فلترة الإشعارات**: إمكانية عرض الإشعارات غير المقروءة فقط
4. **تحديث فوري**: تحديث حالة الإشعارات عبر الـ API

## ملاحظات مهمة
- يجب أن يكون المستخدم مسجل دخول للحصول على الإشعارات
- يتم استخدام `access_token` من `SharedPreferences`
- في حالة فشل الـ API، يتم الاحتفاظ بالإشعارات المحلية
- جميع العمليات تتم بشكل غير متزامن (async)

## اختبار النظام
1. تأكد من تسجيل الدخول
2. انتقل إلى شاشة الإشعارات
3. جرب الأزرار المختلفة:
   - تحديث
   - غير المقروءة فقط
   - الإحصائيات
   - تمييز الكل كمقروء
4. اضغط على إشعار لعرض تفاصيله 