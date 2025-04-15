import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class ServiceHistoryCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;

  const ServiceHistoryCard({
    Key? key,
    required this.title,
    required this.description,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22.0, horizontal: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clock Icon
          Container(
            margin: const EdgeInsets.only(top: 4.0, right: 12.0),
            child: const Icon(
              Icons.watch_later_outlined,
              color: AppColors.neutral200,
              size: 42.0,
            ),
          ),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.textMdSemibold.copyWith(
                    color: AppColors.neutral100,
                  ),
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
          const SizedBox(width: 10),
          Text(
            date,
            style: AppTextStyles.textXsmRegular.copyWith(
              color: AppColors.neutral200,
            ),
          ),
        ],
      ),
    );
  }
}
