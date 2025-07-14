import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/data/models/notification_model.dart';
import 'package:mobile_app_frontend/data/repositories/notification_repository.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/notification_card.dart';
import 'package:mobile_app_frontend/presentation/pages/notification_detail_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationRepository _notificationRepository =
      NotificationRepository();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Default customer ID - In a real app, this would come from user session
  final int _customerId = 1; // Assuming customer ID 1 for demo

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    print('=== Loading notifications for customer $_customerId ===');

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifications = await _notificationRepository
          .getNotificationsWithRefresh(_customerId);

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });

      print('✅ Loaded ${notifications.length} notifications');

      // Mark all as read when user opens the notifications page
      if (notifications.isNotEmpty) {
        _markAllAsReadInBackground();
      }
    } catch (e) {
      print('❌ Error loading notifications: $e');

      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load notifications. Using sample data.';
        // Fallback to sample data
        _notifications = _getSampleNotifications();
      });
    }
  }

  Future<void> _markAllAsReadInBackground() async {
    try {
      await _notificationRepository.markAllNotificationsAsRead(_customerId);
      print('✅ All notifications marked as read');
    } catch (e) {
      print('⚠️ Failed to mark all as read: $e');
    }
  }

  Future<void> _handleRefresh() async {
    print('Pull-to-refresh triggered');
    await _loadNotifications();
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead || notification.notificationId == null) return;

    try {
      await _notificationRepository
          .markNotificationAsRead(notification.notificationId!);

      // Update local state
      setState(() {
        final index = _notifications
            .indexWhere((n) => n.notificationId == notification.notificationId);
        if (index != -1) {
          _notifications[index] = notification.copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        }
      });

      print('✅ Notification ${notification.notificationId} marked as read');
    } catch (e) {
      print('❌ Failed to mark notification as read: $e');
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    if (notification.notificationId == null) return;

    try {
      await _notificationRepository
          .deleteNotification(notification.notificationId!);

      // Update local state
      setState(() {
        _notifications.removeWhere(
            (n) => n.notificationId == notification.notificationId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      print('✅ Notification ${notification.notificationId} deleted');
    } catch (e) {
      print('❌ Failed to delete notification: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<NotificationModel> _getSampleNotifications() {
    return [
      NotificationModel(
        customerId: _customerId,
        title: 'Oil Change Due',
        message:
            'Your vehicle is due for an oil change service. Please schedule an appointment.',
        type: 'service_reminder',
        priority: 'High',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      NotificationModel(
        customerId: _customerId,
        title: 'Brake Service Reminder',
        message:
            'Brake system inspection is recommended. Ensures your safety on the road.',
        type: 'service_reminder',
        priority: 'Critical',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      NotificationModel(
        customerId: _customerId,
        title: 'Tire Rotation',
        message:
            'Regular tire rotation extends tire life and improves vehicle performance.',
        type: 'service_reminder',
        priority: 'Medium',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A202C), // Darker, more modern background
      appBar: CustomAppBar(
        title: 'Notifications',
        showTitle: true,
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.mark_email_read, color: Colors.white),
              onPressed: () async {
                await _markAllAsReadInBackground();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications marked as read'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Column(
        children: [
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              margin: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return GestureDetector(
                  onTap: () async {
                    // Navigate to notification detail page
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            NotificationDetailPage(notification: notification),
                      ),
                    );

                    // If notification was deleted or modified, refresh the list
                    if (result == true) {
                      _loadNotifications();
                    }
                  },
                  onLongPress: () => _showNotificationOptions(notification),
                  child: NotificationCard(
                    title: notification.title,
                    description: notification.message,
                    time: notification.displayTime,
                    isRead: notification.isRead,
                    priority: notification.priority,
                    vehicleInfo: notification.shortVehicleInfo,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.notifications_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You\'ll see service reminders and updates here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleRefresh,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationOptions(NotificationModel notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D3748), // Updated to match new theme
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Notification Options',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.visibility, color: Colors.white),
              title: const Text('View Details',
                  style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        NotificationDetailPage(notification: notification),
                  ),
                );

                // If notification was deleted or modified, refresh the list
                if (result == true) {
                  _loadNotifications();
                }
              },
            ),
            if (!notification.isRead)
              ListTile(
                leading: const Icon(Icons.mark_email_read, color: Colors.white),
                title: const Text('Mark as Read',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _markAsRead(notification);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(notification);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D3748), // Updated to match new theme
        title: const Text('Delete Notification',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this notification?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNotification(notification);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
