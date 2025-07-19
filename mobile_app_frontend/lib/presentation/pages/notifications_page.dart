import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/pages/notification_detail_page.dart';

class NotificationsPage extends StatefulWidget {
  final int customerId;
  final String token;
  final int? vehicleId;

  const NotificationsPage({
    Key? key,
    required this.customerId,
    required this.token,
    this.vehicleId,
  }) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Replace with actual API call to fetch service reminders
    // For now, using enhanced mock data with service reminders
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _notifications = [
        {
          'id': 1,
          'title': 'Oil Change Due',
          'description':
              'Your vehicle has reached 5,000 km since last oil change. Schedule service to maintain engine performance.',
          'time': '2 hours ago',
          'type': 'service_reminder',
          'priority': 'high',
          'isRead': false,
          'actionable': true,
        },
        {
          'id': 2,
          'title': 'Brake Inspection Reminder',
          'description':
              'Brake inspection is recommended after 40,000 km for safety.',
          'time': '1 day ago',
          'type': 'safety_reminder',
          'priority': 'high',
          'isRead': false,
          'actionable': true,
        },
        {
          'id': 3,
          'title': 'Air Filter Replacement',
          'description':
              'Ensures clean air enters the engine for better performance.',
          'time': '2 days ago',
          'type': 'maintenance_reminder',
          'priority': 'medium',
          'isRead': true,
          'actionable': true,
        },
        {
          'id': 4,
          'title': 'Coolant Level Check',
          'description':
              'Regular coolant check helps prevent engine overheating.',
          'time': '3 days ago',
          'type': 'maintenance_reminder',
          'priority': 'medium',
          'isRead': true,
          'actionable': false,
        },
        {
          'id': 5,
          'title': 'Tire Pressure Check',
          'description':
              'Monthly tire pressure check ensures optimal fuel efficiency and safety.',
          'time': '1 week ago',
          'type': 'maintenance_reminder',
          'priority': 'low',
          'isRead': true,
          'actionable': false,
        },
        {
          'id': 6,
          'title': 'Engine Oil Filter Replacement',
          'description':
              'Removes dirt and debris from the oil to keep engine clean.',
          'time': '2 weeks ago',
          'type': 'service_reminder',
          'priority': 'medium',
          'isRead': true,
          'actionable': true,
        },
      ];
      _isLoading = false;
    });
  }

  Future<void> _refreshNotifications() async {
    await _loadNotifications();
  }

  void _markAsRead(int notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });
    // TODO: Update read status on backend
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: Colors.green,
      ),
    );
    // TODO: Update all read status on backend
  }

  void _deleteNotification(int notificationId) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == notificationId);
    });
    // TODO: Delete notification on backend
  }

  int get _unreadCount => _notifications.where((n) => !n['isRead']).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: AppBar(
        backgroundColor: AppColors.neutral400,
        elevation: 0,
        title: Text(
          'Service Reminders',
          style: AppTextStyles.textLgSemibold.copyWith(
            color: AppColors.neutral100,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: AppColors.neutral100,
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark All Read',
                style: AppTextStyles.textSmMedium.copyWith(
                  color: AppColors.neutral100,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _notifications.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _refreshNotifications,
                    child: Column(
                      children: [
                        if (_unreadCount > 0)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16.0),
                            margin: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: Colors.blue),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  'You have $_unreadCount unread service reminders',
                                  style: AppTextStyles.textSmMedium.copyWith(
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            itemCount: _notifications.length,
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              return _buildEnhancedNotificationCard(
                                  notification);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: AppColors.neutral200,
          ),
          const SizedBox(height: 16),
          Text(
            'No Service Reminders',
            style: AppTextStyles.textLgMedium.copyWith(
              color: AppColors.neutral100,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your vehicle is up to date with all services!',
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.neutral200,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;
    final priority = notification['priority'] as String;
    final actionable = notification['actionable'] as bool;

    return GestureDetector(
      onTap: () async {
        // Navigate to notification detail page
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NotificationDetailPage(
              notification: notification,
              customerId: widget.customerId,
              token: widget.token,
              vehicleId: widget.vehicleId,
              onMarkAsRead: _markAsRead,
              onDelete: _deleteNotification,
            ),
          ),
        );

        // If notification was deleted, result will be true
        if (result == true) {
          // Refresh the list to reflect changes
          setState(() {});
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isRead ? AppColors.neutral450 : AppColors.neutral300,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isRead ? AppColors.neutral300 : _getPriorityColor(priority),
            width: isRead ? 1 : 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(priority).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification['type']),
                    color: _getPriorityColor(priority),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'],
                              style: AppTextStyles.textMdMedium.copyWith(
                                color: AppColors.neutral100,
                                fontWeight: isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getPriorityColor(priority),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['time'],
                        style: AppTextStyles.textXsmRegular.copyWith(
                          color: AppColors.neutral200,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              notification['description'],
              style: AppTextStyles.textSmRegular.copyWith(
                color: AppColors.neutral150,
              ),
            ),
            const SizedBox(height: 12),
            // View Details Row
            Row(
              children: [
                Icon(
                  Icons.visibility,
                  size: 16,
                  color: AppColors.neutral200,
                ),
                const SizedBox(width: 4),
                Text(
                  'Tap to view details',
                  style: AppTextStyles.textXsmRegular.copyWith(
                    color: AppColors.neutral200,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.neutral200,
                ),
              ],
            ),
            if (actionable)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to appointment booking
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Booking appointment feature coming soon!'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getPriorityColor(priority),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Book Service'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Snooze reminder functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Reminder snoozed for 1 week'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.neutral100,
                          side: BorderSide(color: AppColors.neutral200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Snooze'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return AppColors.neutral200;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'service_reminder':
        return Icons.build;
      case 'maintenance_reminder':
        return Icons.settings;
      case 'safety_reminder':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }
}
