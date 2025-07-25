import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/pages/notification_detail_page.dart';
import 'package:mobile_app_frontend/data/repositories/reminder_repository.dart';
import 'package:mobile_app_frontend/data/models/reminder_model.dart';
import 'package:mobile_app_frontend/presentation/pages/appointment_page.dart';
import 'package:mobile_app_frontend/core/services/notification_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  final ReminderRepository _reminderRepository = ReminderRepository();
  final Set<int> _notifiedReminders =
      {}; // Track which reminders have been notified this session
  Set<int> _backendNotifiedReminders =
      {}; // Track reminders already notified in backend

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    await NotificationService.generateNotificationsFromServiceReminders(
        token: widget.token);
    await _fetchBackendNotifications();
    await _loadNotifications();
  }

  Future<void> _fetchBackendNotifications() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:5039/api/Notifications/Customer/${widget.customerId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> notifications = json.decode(response.body);
        _backendNotifiedReminders = notifications
            .map((n) => n['serviceReminderId'])
            .where((id) => id != null)
            .cast<int>()
            .toSet();
      }
    } catch (e) {
      print('Failed to fetch backend notifications: $e');
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:5039/api/Notifications/Customer/${widget.customerId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> notifications = json.decode(response.body);
        _notifications = notifications.map<Map<String, dynamic>>((n) {
          // Determine priority: use backend if valid, else compute from due date
          String priority = (n['priority'] ?? '').toString().toLowerCase();
          if (priority != 'high' && priority != 'medium' && priority != 'low') {
            // Try to compute from due date if available
            DateTime? dueDate;
            if (n['reminderDate'] != null) {
              dueDate = DateTime.tryParse(n['reminderDate']);
            } else if (n['sentAt'] != null) {
              dueDate = DateTime.tryParse(n['sentAt']);
            } else if (n['createdAt'] != null) {
              dueDate = DateTime.tryParse(n['createdAt']);
            }
            if (dueDate != null) {
              final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
              if (daysUntilDue <= 0) {
                priority = 'high';
              } else if (daysUntilDue <= 3) {
                priority = 'medium';
              } else {
                priority = 'low';
              }
            } else {
              priority = 'low'; // fallback
            }
          }
          return {
            'id': n['notificationId'],
            'title': n['title'] ?? '',
            'description': n['message'] ?? '',
            'time': n['sentAt'] ?? n['createdAt'] ?? '',
            'type': n['type'] ?? '',
            'priority': priority,
            'isRead': n['isRead'] ?? false,
            'actionable': true, // or use your own logic
            'vehicleId': n['vehicleId'],
            'reminderDate': n['sentAt'] ?? n['createdAt'],
            // Add other fields as needed
          };
        }).toList();
        // Sort notifications by newest sentAt/createdAt first
        _notifications.sort((a, b) {
          final aDate =
              DateTime.tryParse(a['reminderDate'] ?? '') ?? DateTime(1970);
          final bDate =
              DateTime.tryParse(b['reminderDate'] ?? '') ?? DateTime(1970);
          return bDate.compareTo(aDate);
        });
        // Remove reminderDate from notification maps (optional, for UI cleanliness)
        for (var n in _notifications) {
          n.remove('reminderDate');
        }
      } else {
        _notifications = [];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to load notifications: ${response.body}')),
        );
      }
    } catch (e) {
      _notifications = [];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load notifications: $e')),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshNotifications() async {
    await _loadNotifications();
  }

  Future<void> _markAsRead(int notificationId) async {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });
    try {
      await NotificationService.markNotificationAsRead(
        notificationId: notificationId,
        token: widget.token,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark notification as read: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    try {
      await NotificationService.markAllNotificationsAsRead(
        customerId: widget.customerId,
        token: widget.token,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark all as read: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteNotification(int notificationId) async {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == notificationId);
    });
    try {
      await NotificationService.deleteNotificationFromBackend(
        notificationId: notificationId,
        token: widget.token,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadNotifications(); // Refresh the list from backend
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

    // Trigger backend notification if not already sent for this reminder (deduped with backend)
    final reminderId = notification['id'];
    if (reminderId != null &&
        !_notifiedReminders.contains(reminderId) &&
        !_backendNotifiedReminders.contains(reminderId)) {
      _notifiedReminders.add(reminderId);
      // Build notification data for backend
      final notificationData = {
        'customerId': widget.customerId,
        'title': notification['title'],
        'message': notification['description'],
        'type': notification['type'],
        'priority': priority,
        'serviceReminderId': notification['id'],
        'vehicleId': notification['vehicleId'],
        // Add more fields as needed
      };
      NotificationService.sendNotificationToBackend(
        customerId: widget.customerId,
        notificationData: notificationData,
        token: widget.token,
      );
    }

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
                          // Navigate to AppointmentPage
                          final vehicleId = int.tryParse(
                                  notification['vehicleId']?.toString() ??
                                      '') ??
                              widget.vehicleId ??
                              1;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppointmentPage(
                                customerId: widget.customerId,
                                vehicleId: vehicleId,
                                token: widget.token,
                              ),
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
