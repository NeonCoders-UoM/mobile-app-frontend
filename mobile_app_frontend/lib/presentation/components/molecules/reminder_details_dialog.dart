import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/service_reminder_card.dart';
import 'package:mobile_app_frontend/presentation/pages/edit_reminder_page.dart';

class ReminderDetailsDialog extends StatelessWidget {
  final String title;
  final String nextDue;
  final ServiceStatus status;
  final String mileageInterval;
  final String timeInterval;
  final String lastServiceDate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Map<String, dynamic> reminder; // Add the full reminder data
  final int index;

  const ReminderDetailsDialog({
    Key? key,
    required this.title,
    required this.nextDue,
    required this.status,
    required this.mileageInterval,
    required this.timeInterval,
    required this.lastServiceDate,
    required this.onEdit,
    required this.onDelete,
    required this.reminder,
    required this.index,
  }) : super(key: key);

  // Helper method to get status text and color
  _StatusInfo _getStatusInfo() {
    switch (status) {
      case ServiceStatus.upcoming:
        return _StatusInfo(
          color: AppColors.states['upcoming']!,
          label: 'Upcoming',
        );
      case ServiceStatus.overdue:
        return _StatusInfo(
          color: AppColors.states['overdue']!,
          label: 'Overdue',
        );
      case ServiceStatus.completed:
        return _StatusInfo(
          color: AppColors.states['ok']!,
          label: 'Completed',
        );
      case ServiceStatus.scheduled:
        return _StatusInfo(
          color: AppColors.states['scheduled']!,
          label: 'Scheduled',
        );
      case ServiceStatus.inProgress:
        return _StatusInfo(
          color: AppColors.states['inProgress']!,
          label: 'In Progress',
        );
      case ServiceStatus.canceled:
        return _StatusInfo(
          color: AppColors.states['canceled']!,
          label: 'Canceled',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusInfo = _getStatusInfo();

    return AlertDialog(
      backgroundColor: AppColors.neutral400, // Dark background as in the image
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      contentPadding: const EdgeInsets.all(30.0),
      content: Column(
        mainAxisSize: MainAxisSize.min, // Fit content size
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Status Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  title,
                  style: AppTextStyles.textLgSemibold.copyWith(
                    color: AppColors.neutral100,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 8.0),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 11.0,
                      height: 11.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusInfo.color,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Flexible(
                      child: Text(
                        statusInfo.label,
                        style: AppTextStyles.textXsmRegular.copyWith(
                          color: statusInfo.color,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          // Details
          _buildDetailRow('NEXT DUE:', nextDue),
          _buildDetailRow('STATUS:', statusInfo.label),
          _buildDetailRow('MILEAGE INTERVAL:', mileageInterval),
          _buildDetailRow('TIME INTERVAL:', timeInterval),
          _buildDetailRow('LAST SERVICE DATE:', lastServiceDate),
          const SizedBox(height: 24.0),
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomButton(
                label: 'EDIT',
                type: ButtonType.primary,
                size: ButtonSize.small,
                onTap: () async {
                  // Navigate to EditReminderPage and wait for the result
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditReminderPage(
                        reminder: reminder,
                        index: index,
                      ),
                    ),
                  );

                  // If a result is returned, pass it back to the RemindersPage
                  if (result != null) {
                    Navigator.pop(context, result);
                  } else {
                    Navigator.pop(
                        context); // Close the dialog if no changes were made
                  }
                },
              ),
              CustomButton(
                label: 'DELETE',
                type: ButtonType.danger, // Red button using the new danger type
                size: ButtonSize.small,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to build each detail row
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.textSmSemibold.copyWith(
              color: AppColors.neutral100,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.textSmRegular.copyWith(
                color: AppColors.neutral200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusInfo {
  final Color color;
  final String label;

  _StatusInfo({
    required this.color,
    required this.label,
  });
}
