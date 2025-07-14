import 'package:mobile_app_frontend/core/services/notification_api_service.dart';
import 'package:mobile_app_frontend/data/models/notification_model.dart';

class NotificationRepository {
  // Get all notifications
  Future<List<NotificationModel>> getAllNotifications() async {
    try {
      return await NotificationApiService.getAllNotifications();
    } catch (e) {
      throw Exception('Failed to fetch all notifications: $e');
    }
  }

  // Get notifications for a specific customer
  Future<List<NotificationModel>> getCustomerNotifications(
      int customerId) async {
    try {
      return await NotificationApiService.getCustomerNotifications(customerId);
    } catch (e) {
      throw Exception('Failed to fetch customer notifications: $e');
    }
  }

  // Get unread notifications for a customer
  Future<List<NotificationModel>> getCustomerUnreadNotifications(
      int customerId) async {
    try {
      return await NotificationApiService.getCustomerUnreadNotifications(
          customerId);
    } catch (e) {
      throw Exception('Failed to fetch customer unread notifications: $e');
    }
  }

  // Get notification summary for a customer
  Future<NotificationSummaryModel> getNotificationSummary(
      int customerId) async {
    try {
      return await NotificationApiService.getNotificationSummary(customerId);
    } catch (e) {
      throw Exception('Failed to fetch notification summary: $e');
    }
  }

  // Get pending notifications
  Future<List<NotificationModel>> getPendingNotifications() async {
    try {
      return await NotificationApiService.getPendingNotifications();
    } catch (e) {
      throw Exception('Failed to fetch pending notifications: $e');
    }
  }

  // Get a specific notification by ID
  Future<NotificationModel> getNotification(int notificationId) async {
    try {
      return await NotificationApiService.getNotification(notificationId);
    } catch (e) {
      throw Exception('Failed to fetch notification: $e');
    }
  }

  // Create a new notification
  Future<NotificationModel> createNotification(
      NotificationModel notification) async {
    try {
      return await NotificationApiService.createNotification(notification);
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  // Mark a notification as read
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await NotificationApiService.markNotificationAsRead(notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Mark a notification as sent
  Future<void> markNotificationAsSent(int notificationId) async {
    try {
      await NotificationApiService.markNotificationAsSent(notificationId);
    } catch (e) {
      throw Exception('Failed to mark notification as sent: $e');
    }
  }

  // Mark all notifications as read for a customer
  Future<void> markAllNotificationsAsRead(int customerId) async {
    try {
      await NotificationApiService.markAllNotificationsAsRead(customerId);
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  // Delete a notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      await NotificationApiService.deleteNotification(notificationId);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  // Convenience method to get notifications with auto-refresh
  Future<List<NotificationModel>> getNotificationsWithRefresh(
      int customerId) async {
    try {
      // Fetch the latest notifications from the backend
      final notifications = await getCustomerNotifications(customerId);

      // Sort by created date (newest first)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return notifications;
    } catch (e) {
      print('Error fetching notifications with refresh: $e');
      // Return empty list on error to avoid breaking the UI
      return [];
    }
  }

  // Get unread notification count for badge display
  Future<int> getUnreadNotificationCount(int customerId) async {
    try {
      final summary = await getNotificationSummary(customerId);
      return summary.unreadNotifications;
    } catch (e) {
      print('Error fetching unread notification count: $e');
      return 0;
    }
  }

  // Batch operation to mark multiple notifications as read
  Future<void> markMultipleAsRead(List<int> notificationIds) async {
    try {
      // Process in parallel for better performance
      await Future.wait(
          notificationIds.map((id) => markNotificationAsRead(id)));
    } catch (e) {
      throw Exception('Failed to mark multiple notifications as read: $e');
    }
  }

  // Get notifications by priority
  Future<List<NotificationModel>> getNotificationsByPriority(
      int customerId, String priority) async {
    try {
      final allNotifications = await getCustomerNotifications(customerId);
      return allNotifications
          .where((notification) =>
              notification.priority.toLowerCase() == priority.toLowerCase())
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications by priority: $e');
    }
  }

  // Get notifications by type
  Future<List<NotificationModel>> getNotificationsByType(
      int customerId, String type) async {
    try {
      final allNotifications = await getCustomerNotifications(customerId);
      return allNotifications
          .where((notification) =>
              notification.type.toLowerCase() == type.toLowerCase())
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications by type: $e');
    }
  }
}
