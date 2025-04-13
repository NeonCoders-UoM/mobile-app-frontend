import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import '../atoms/status_dot.dart';
import '../atoms/service_icon.dart';
import '../atoms/service_text.dart';

class ServiceCard extends StatelessWidget {
  final String title; // e.g., "Oil Change"
  final String status; // e.g., "Upcoming", "5 minutes ago", "Completed"
  final String? subtitle; // e.g., "Next: 15,000 km or in 8 months"
  final String? description; // e.g., "Replacing engine oil..."
  final String? date; // e.g., "14, Feb, 2025"
  final IconData icon; // Icon to display (e.g., clock, gear)
  final Color? statusDotColor; // Color of the status dot (null if no dot)

  const ServiceCard({
    super.key,
    required this.title,
    required this.status,
    required this.icon,
    this.subtitle,
    this.description,
    this.date,
    this.statusDotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.neutral400, // Dark background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            ServiceIcon(
              icon: icon,
              color: AppColors.neutral200, // Light gray icon
            ),
            const SizedBox(width: 12.0),
            // Main Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ServiceText(
                        text: title,
                        style: AppTextStyles.body2Semibold.copyWith(
                          color: AppColors.neutral100, // White title
                        ),
                      ),
                      if (statusDotColor != null)
                        StatusDot(
                          status: status,
                          dotColor: statusDotColor!,
                        )
                      else
                        ServiceText(
                          text: status,
                          style: AppTextStyles.body3Regular.copyWith(
                            color: AppColors.neutral200, // Light gray status
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  // Subtitle (e.g., "Next: 15,000 km or in 8 months")
                  if (subtitle != null)
                    ServiceText(
                      text: subtitle!,
                      style: AppTextStyles.body3Regular.copyWith(
                        color: AppColors.neutral200, // Light gray
                      ),
                    ),
                  // Description (e.g., "Replacing engine oil...")
                  if (description != null) ...[
                    const SizedBox(height: 4.0),
                    ServiceText(
                      text: description!,
                      style: AppTextStyles.body3Regular.copyWith(
                        color: AppColors.neutral200,
                      ),
                    ),
                  ],
                  // Date (e.g., "14, Feb, 2025")
                  if (date != null) ...[
                    const SizedBox(height: 4.0),
                    ServiceText(
                      text: date!,
                      style: AppTextStyles.body3Regular.copyWith(
                        color: AppColors.neutral200,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
