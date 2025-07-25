import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/pages/appointment_page.dart';
import 'package:mobile_app_frontend/presentation/pages/feedback_page.dart';

class NotificationDetailPage extends StatefulWidget {
  final Map<String, dynamic> notification;
  final int customerId;
  final String token;
  final int? vehicleId;
  final Function(int)? onMarkAsRead;
  final Function(int)? onDelete;

  const NotificationDetailPage({
    Key? key,
    required this.notification,
    required this.customerId,
    required this.token,
    this.vehicleId,
    this.onMarkAsRead,
    this.onDelete,
  }) : super(key: key);

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  late Map<String, dynamic> _notification;

  @override
  void initState() {
    super.initState();
    _notification = Map<String, dynamic>.from(widget.notification);

    // Mark as read when viewing - use post frame callback to avoid setState during build
    if (!_notification['isRead']) {
      _notification['isRead'] = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onMarkAsRead?.call(_notification['id']);
      });
    }
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

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'high':
        return 'High Priority';
      case 'medium':
        return 'Medium Priority';
      case 'low':
        return 'Low Priority';
      default:
        return 'Normal';
    }
  }

  String _getTypeText(String type) {
    switch (type) {
      case 'service_reminder':
        return 'Service Reminder';
      case 'maintenance_reminder':
        return 'Maintenance Reminder';
      case 'safety_reminder':
        return 'Safety Reminder';
      default:
        return 'Notification';
    }
  }

  void _deleteNotification() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.neutral400,
          title: Text(
            'Delete Notification',
            style: AppTextStyles.textLgMedium.copyWith(
              color: AppColors.neutral100,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this notification? This action cannot be undone.',
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.neutral150,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.textSmMedium.copyWith(
                  color: AppColors.neutral200,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete?.call(_notification['id']);
                Navigator.of(context).pop(true); // Return to notifications list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Text(
                'Delete',
                style: AppTextStyles.textSmMedium.copyWith(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Map<String, String> _getDetailedInfo() {
    final type = _notification['type'] as String;
    final priority = _notification['priority'] as String;

    switch (type) {
      case 'service_reminder':
        return {
          'nextAction': 'Schedule a service appointment',
          'estimatedCost': '\$150 - \$300',
          'timeRequired': '2-4 hours',
          'urgency': priority == 'high'
              ? 'Service needed within 1-2 weeks'
              : 'Schedule within the next month',
          'consequences':
              'Delayed service may lead to engine damage and reduced performance',
        };
      case 'maintenance_reminder':
        return {
          'nextAction': 'Perform routine maintenance check',
          'estimatedCost': '\$50 - \$150',
          'timeRequired': '30 minutes - 2 hours',
          'urgency': priority == 'high'
              ? 'Address immediately'
              : 'Schedule within 2-4 weeks',
          'consequences':
              'Neglecting maintenance may affect vehicle reliability and safety',
        };
      case 'safety_reminder':
        return {
          'nextAction': 'Safety inspection required',
          'estimatedCost': '\$80 - \$200',
          'timeRequired': '1-3 hours',
          'urgency': 'Immediate attention required for safety',
          'consequences':
              'Safety issues pose immediate risk to driver and passengers',
        };
      default:
        return {
          'nextAction': 'Review notification details',
          'estimatedCost': 'Varies',
          'timeRequired': 'Varies',
          'urgency': 'As needed',
          'consequences': 'Follow recommended actions',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final priority = _notification['priority'] as String;
    final type = _notification['type'] as String;
    final actionable = _notification['actionable'] as bool;
    final detailedInfo = _getDetailedInfo();

    // Build a more meaningful description
    final dueDateStr = _notification['description']?.contains('on') == true
        ? '' // Already included in description
        : (_notification['dueDate'] ?? '');
    final vehicleInfo = [
      if (_notification['vehicleBrand'] != null &&
          _notification['vehicleModel'] != null)
        '${_notification['vehicleBrand']} ${_notification['vehicleModel']}',
      if (_notification['vehicleRegistrationNumber'] != null)
        '(${_notification['vehicleRegistrationNumber']})',
    ].join(' ');
    final notes = (_notification['notes'] != null &&
            _notification['notes'].toString().isNotEmpty)
        ? '\nNotes: ${_notification['notes']}'
        : '';
    final description = [
      _notification['description'] ?? '',
      if (vehicleInfo.trim().isNotEmpty) 'Vehicle: $vehicleInfo',
      if (dueDateStr.isNotEmpty) 'Due Date: $dueDateStr',
      notes
    ].where((s) => s.trim().isNotEmpty).join('\n');

    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: AppBar(
        backgroundColor: AppColors.neutral400,
        elevation: 0,
        title: Text(
          'Notification Details',
          style: AppTextStyles.textLgSemibold.copyWith(
            color: AppColors.neutral100,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: AppColors.neutral100,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.neutral100,
            ),
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _deleteNotification();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: _getPriorityColor(priority),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(priority).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getNotificationIcon(type),
                          color: _getPriorityColor(priority),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _notification['title'],
                              style: AppTextStyles.textLgMedium.copyWith(
                                color: AppColors.neutral100,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(priority),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getPriorityText(priority),
                                    style: AppTextStyles.textXsmMedium.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _getTypeText(type),
                                    style: AppTextStyles.textSmRegular.copyWith(
                                      color: AppColors.neutral150,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _notification['time'],
                    style: AppTextStyles.textSmRegular.copyWith(
                      color: AppColors.neutral200,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Description Section
            _buildSection(
              'Description',
              Icons.description,
              Text(
                description,
                style: AppTextStyles.textMdRegular.copyWith(
                  color: AppColors.neutral100,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Detailed Information Section
            _buildSection(
              'Details',
              Icons.info_outline,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Service', _notification['title'] ?? '-'),
                  if (vehicleInfo.trim().isNotEmpty)
                    _buildDetailRow('Vehicle', vehicleInfo),
                  _buildDetailRow(
                      'Due Date',
                      dueDateStr.isNotEmpty
                          ? dueDateStr
                          : (_notification['time'] ?? '-')),
                  _buildDetailRow('Status', _notification['time'] ?? '-'),
                  if (notes.trim().isNotEmpty)
                    _buildDetailRow(
                        'Notes', notes.replaceFirst('\nNotes: ', '')),
                ],
              ),
            ),

            if (actionable) ...[
              const SizedBox(height: 24),
              // Action Buttons
              if (type == 'service_history_verified')
                _buildSection(
                  'Available Actions',
                  Icons.play_arrow,
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FeedbackPage(
                                  vehicleId: _notification['vehicleId'] ??
                                      widget.vehicleId ??
                                      1,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary200,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: const Icon(Icons.feedback),
                          label: const Text(
                            'Add Feedback',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                _buildSection(
                  'Available Actions',
                  Icons.play_arrow,
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Navigate to AppointmentPage
                            final vehicleId = int.tryParse(
                                    _notification['vehicleId']?.toString() ??
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: const Icon(Icons.calendar_today),
                          label: const Text(
                            'Book Service Appointment',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Reminder snoozed for 1 week'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.neutral100,
                                side: BorderSide(color: AppColors.neutral200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.snooze),
                              label: const Text('Snooze'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.neutral450,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppColors.neutral300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.neutral100,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.textMdMedium.copyWith(
                    color: AppColors.neutral100,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: AppTextStyles.textSmMedium.copyWith(
                  color: AppColors.neutral150,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.textSmRegular.copyWith(
                  color: AppColors.neutral100,
                ),
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 12),
          Divider(
            color: AppColors.neutral300,
            height: 1,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
