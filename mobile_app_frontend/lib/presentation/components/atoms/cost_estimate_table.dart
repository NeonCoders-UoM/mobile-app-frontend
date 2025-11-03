import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class CostEstimateTable extends StatelessWidget {
  final List<String> services;
  final List<int> costs;
  final int total;
  final List<Map<String, dynamic>>?
      detailedServices; // Optional: full service objects

  const CostEstimateTable({
    super.key,
    required this.services,
    required this.costs,
    required this.total,
    this.detailedServices,
  });

  @override
  Widget build(BuildContext context) {
    final hasDetails = detailedServices != null && detailedServices!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Service",
              style: AppTextStyles.textMdBold.copyWith(
                color: AppColors.neutral100,
              ),
            ),
            if (hasDetails &&
                detailedServices!.any((s) => s['customPrice'] != null))
              Text(
                "Custom Price",
                style: AppTextStyles.textMdBold.copyWith(
                  color: AppColors.neutral100,
                ),
              ),
            if (hasDetails &&
                detailedServices!.any((s) => s['packageName'] != null))
              Text(
                "Package",
                style: AppTextStyles.textMdBold.copyWith(
                  color: AppColors.neutral100,
                ),
              ),
            Text(
              "Estimated Cost",
              style: AppTextStyles.textMdBold.copyWith(
                color: AppColors.neutral100,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(services.length, (index) {
          final detail = hasDetails ? detailedServices![index] : null;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  services[index],
                  style: AppTextStyles.textMdRegular.copyWith(
                    color: AppColors.neutral200,
                  ),
                ),
                if (hasDetails &&
                    detailedServices!.any((s) => s['customPrice'] != null))
                  Text(
                    detail?['customPrice'] != null
                        ? 'Rs. ${detail!['customPrice']}'
                        : '-',
                    style: AppTextStyles.textMdRegular.copyWith(
                      color: AppColors.neutral200,
                    ),
                  ),
                if (hasDetails &&
                    detailedServices!.any((s) => s['packageName'] != null))
                  Text(
                    detail?['packageName'] ?? '-',
                    style: AppTextStyles.textMdRegular.copyWith(
                      color: AppColors.neutral200,
                    ),
                  ),
                Text(
                  "Rs. ${costs[index].toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}",
                  style: AppTextStyles.textMdRegular.copyWith(
                    color: AppColors.neutral200,
                  ),
                ),
              ],
            ),
          );
        }),
        const Divider(color: AppColors.neutral300, height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total",
              style: AppTextStyles.textMdBold.copyWith(
                color: AppColors.neutral100,
              ),
            ),
            Text(
              "Rs. ${total.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}",
              style: AppTextStyles.textMdBold.copyWith(
                color: AppColors.neutral100,
              ),
            ),
          ],
        )
      ],
    );
  }
}
