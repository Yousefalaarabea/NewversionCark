/// Configuration file for notification system
/// This file contains all configurable parameters for the notification system
class NotificationConfig {
  // Polling intervals
  static const Duration defaultPollingInterval = Duration(minutes: 2);
  static const Duration providerPollingInterval = Duration(minutes: 1);
  
  // API endpoints
  static const String baseNotificationsEndpoint = "notifications/notifications/";
  static const String unreadNotificationsEndpoint = "notifications/notifications/unread/";
  static const String notificationsCountEndpoint = "notifications/notifications/count/";
  static const String markAsReadEndpoint = "notifications/notifications/";
  static const String markAllAsReadEndpoint = "notifications/notifications/mark_all_as_read/";
  
  // Debug settings
  static const bool enableDebugLogging = true;
  static const bool enableNotificationAnalysis = true;
  
  // UI settings
  static const int maxNotificationsToShow = 50;
  static const bool enableAutoRefresh = true;
  
  // Performance settings
  static const bool enableCaching = true;
  static const Duration cacheExpiry = Duration(minutes: 5);
} 