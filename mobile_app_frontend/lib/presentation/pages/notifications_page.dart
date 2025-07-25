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
      List<ServiceReminderModel> reminders;
      if (widget.vehicleId != null) {
        reminders = await _reminderRepository
            .getVehicleReminders(widget.vehicleId!, token: widget.token);
      } else {
        reminders =
            await _reminderRepository.getAllReminders(token: widget.token);
      }
      // Map reminders to notification format, only include those within notify period
      _notifications = reminders.where((reminder) {
        final now = DateTime.now();
        final daysUntilDue = reminder.reminderDate.difference(now).inDays;
        return daysUntilDue <= reminder.notifyBeforeDays;
      }).map((reminder) {
        final now = DateTime.now();
        final daysUntilDue = reminder.reminderDate.difference(now).inDays;
        final dueDateStr =
            '${reminder.reminderDate.day.toString().padLeft(2, '0')}/${reminder.reminderDate.month.toString().padLeft(2, '0')}/${reminder.reminderDate.year}';
        String time;
        if (daysUntilDue < 0) {
          time = 'Overdue by  [1m${-daysUntilDue}\u001b[0m days';
        } else if (daysUntilDue == 0) {
          time = 'Due today';
        } else {
          time = 'Due in $daysUntilDue days';
        }
        String priority;
        if (daysUntilDue < 0) {
          priority = 'high';
        } else if (daysUntilDue <= reminder.notifyBeforeDays) {
          priority = 'medium';
        } else {
          priority = 'low';
        }
        final vehicleInfo = [
          if (reminder.vehicleBrand != null && reminder.vehicleModel != null)
            '${reminder.vehicleBrand} ${reminder.vehicleModel}',
          if (reminder.vehicleRegistrationNumber != null)
            '(${reminder.vehicleRegistrationNumber})',
        ].join(' ');
        final serviceName = reminder.serviceName ?? 'Service Reminder';
        final notes = (reminder.notes != null && reminder.notes!.isNotEmpty)
            ? '\nNotes: ${reminder.notes}'
            : '';
        // Dynamic, user-friendly title and description
        final title = '$serviceName for $vehicleInfo';
        final description = [
          'Your $vehicleInfo is scheduled for $serviceName on $dueDateStr.',
          time + '.',
          if (notes.isNotEmpty) notes
        ].join('\n');
        return {
          'id': reminder.serviceReminderId ?? reminder.hashCode,
          'title': title,
          'description': description,
          'time': time,
          'type': 'service_reminder',
          'priority': priority,
          'isRead': reminder.isActive ? false : true,
          'actionable': reminder.isActive,
          'vehicleId': reminder.vehicleId,
          // Add reminderDate for sorting
          'reminderDate': reminder.reminderDate,
        };
      }).toList();
      // Sort notifications by newest reminderDate first
      _notifications.sort((a, b) => (b['reminderDate'] as DateTime)
          .compareTo(a['reminderDate'] as DateTime));
      // Remove reminderDate from notification maps (optional, for UI cleanliness)
      for (var n in _notifications) {
        n.remove('reminderDate');
      }
    } catch (e) {
      // On error, show empty or fallback
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
