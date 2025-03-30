import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

enum ServiceStatus {
  upcoming,
  overdue,
  completed,
  scheduled,
  inProgress,
  canceled,
}

class ServiceReminderCard extends StatelessWidget {
  final String title;
  final String description;
  final ServiceStatus status;
  final VoidCallback? onTap;

  const ServiceReminderCard({
    Key? key,
    required this.title,
    required this.description,
    required this.status,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22.0, horizontal: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clock icon
            Container(
              margin: const EdgeInsets.only(top: 4.0, right: 12.0),
              child: Icon(
                Icons.watch_later_outlined,
                color: AppColors.neutral200,
                size: 42.0,
              ),
            ),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.textMdSemibold.copyWith(
                            color: AppColors.neutral100,
                          ),
                        ),
                      ),
                      _buildStatusIndicator(),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    description,
                    style: AppTextStyles.textSmRegular.copyWith(
                      color: AppColors.neutral200,
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

  Widget _buildStatusIndicator() {
    final statusInfo = _getStatusInfo();

    return Row(
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
        Text(
          statusInfo.label,
          style: AppTextStyles.textXsmRegular.copyWith(
            color: statusInfo.color,
          ),
        ),
      ],
    );
  }

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
}

class _StatusInfo {
  final Color color;
  final String label;

  _StatusInfo({
    required this.color,
    required this.label,
  });
}
