import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/data/models/notification_model.dart';
import 'package:mobile_app_frontend/data/repositories/notification_repository.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';

class NotificationDetailPage extends StatefulWidget {
  final NotificationModel notification;

  const NotificationDetailPage({
    Key? key,
    required this.notification,
  }) : super(key: key);

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  final NotificationRepository _notificationRepository =
      NotificationRepository();
  late NotificationModel _notification;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _notification = widget.notification;
    _markAsReadIfNeeded();
  }

  Future<void> _markAsReadIfNeeded() async {
    if (!_notification.isRead && _notification.notificationId != null) {
      try {
        await _notificationRepository
            .markNotificationAsRead(_notification.notificationId!);
        setState(() {
          _notification = _notification.copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
        });
        print('✅ Notification marked as read');
      } catch (e) {
        print('❌ Failed to mark notification as read: $e');
        // In test environment or when backend is unavailable, silently handle the error
        // Don't update the UI state if the request fails
      }
    }
  }

  Future<void> _deleteNotification() async {
    if (_notification.notificationId == null) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await _notificationRepository
          .deleteNotification(_notification.notificationId!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Return to previous page with deletion flag
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.neutral400,
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
              _deleteNotification();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: CustomAppBar(
        title: 'Notification Details',
        showTitle: true,
        actions: [
          if (_notification.notificationId != null)
            IconButton(
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.delete, color: Colors.white),
              onPressed: _isDeleting ? null : _showDeleteConfirmation,
              tooltip: 'Delete notification',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification status indicator
            _buildStatusIndicator(),
            const SizedBox(height: 20),

            // Title section
            _buildTitleSection(),
            const SizedBox(height: 20),

            // Message section
            _buildMessageSection(),
            const SizedBox(height: 20),

            // Details section
            _buildDetailsSection(),
            const SizedBox(height: 20),

            // Metadata section
            _buildMetadataSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    final priorityColorHex = _notification.priorityColor;
    final priorityColor =
        Color(int.parse(priorityColorHex.replaceFirst('#', '0xFF')));
    final statusText = _notification.isRead ? 'Read' : 'Unread';

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: priorityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: priorityColor),
      ),
      child: Row(
        children: [
          Icon(
            _notification.isRead
                ? Icons.mark_email_read
                : Icons.mark_email_unread,
            color: priorityColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: priorityColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _notification.priority,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.neutral100.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Title',
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.neutral100.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _notification.title,
            style: AppTextStyles.displaySmBold.copyWith(
              color: AppColors.neutral100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.neutral100.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Message',
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.neutral100.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _notification.message,
            style: AppTextStyles.textMdRegular.copyWith(
              color: AppColors.neutral100,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.neutral100.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.neutral100.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
              'Type', _notification.type.replaceAll('_', ' ').toUpperCase()),
          _buildDetailRow('Priority', _notification.priority),
          if (_notification.serviceReminderId != null)
            _buildDetailRow('Service Reminder ID',
                _notification.serviceReminderId.toString()),
          if (_notification.vehicleRegistrationNumber != null &&
              _notification.vehicleRegistrationNumber!.isNotEmpty)
            _buildDetailRow(
                'Vehicle', _notification.vehicleRegistrationNumber!),
          if (_notification.vehicleBrand != null &&
              _notification.vehicleModel != null)
            _buildDetailRow('Vehicle Info',
                '${_notification.vehicleBrand} ${_notification.vehicleModel}'),
          if (_notification.serviceName != null &&
              _notification.serviceName!.isNotEmpty)
            _buildDetailRow('Service', _notification.serviceName!),
          if (_notification.customerName != null &&
              _notification.customerName!.isNotEmpty)
            _buildDetailRow('Customer', _notification.customerName!),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.textSmRegular.copyWith(
                color: AppColors.neutral100.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.textSmRegular.copyWith(
                color: AppColors.neutral100,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.neutral100.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timestamps',
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.neutral100.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Created', _notification.displayTime),
          if (_notification.readAt != null)
            _buildDetailRow('Read At', _formatDateTime(_notification.readAt!)),
          if (_notification.sentAt != null)
            _buildDetailRow('Sent At', _formatDateTime(_notification.sentAt!)),
          if (_notification.scheduledFor != null)
            _buildDetailRow(
                'Scheduled For', _formatDateTime(_notification.scheduledFor!)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
