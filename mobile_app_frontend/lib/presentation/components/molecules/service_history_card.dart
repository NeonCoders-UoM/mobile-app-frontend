import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class ServiceHistoryCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final bool isVerified;
  final VoidCallback? onEdit;

  const ServiceHistoryCard({
    Key? key,
    required this.title,
    required this.description,
    required this.date,
    this.isVerified = true,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.neutral450,
            AppColors.neutral450.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clock Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary200,
                  AppColors.primary300,
                ],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.watch_later_outlined,
              color: AppColors.neutral100,
              size: 24.0,
            ),
          ),
          const SizedBox(width: 16.0),
          // Text Content
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
                    if (onEdit != null) ...[
                      IconButton(
                        icon:
                            const Icon(Icons.edit, color: AppColors.neutral100),
                        tooltip: 'Edit Service Record',
                        onPressed: onEdit,
                      ),
                    ],
                    // Verification Badge
                    if (!isVerified) ...[
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.states['upcoming'],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Unverified',
                          style: AppTextStyles.textXsmRegular.copyWith(
                            color: AppColors.neutral600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    if (isVerified) ...[
                      const SizedBox(width: 8.0),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors
                              .states['ok'], // Use a green color for verified
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Verified',
                          style: AppTextStyles.textXsmRegular.copyWith(
                            color: AppColors.neutral100,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  description,
                  style: AppTextStyles.textSmRegular.copyWith(
                    color: AppColors.neutral200,
                  ),
                ),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neutral400.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.neutral300.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: AppColors.neutral100,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        date,
                        style: AppTextStyles.textXsmRegular.copyWith(
                          color: AppColors.neutral100,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
