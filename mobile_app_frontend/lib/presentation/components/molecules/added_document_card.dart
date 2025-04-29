import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class AddedDocumentCard extends StatelessWidget {
  final String documentName;
  final String documentSize;
  final VoidCallback onRemove;

  const AddedDocumentCard({
    Key? key,
    required this.documentName,
    required this.documentSize,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: AppColors.neutral450,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: AppColors.neutral200,
                size: 24.0,
              ),
              const SizedBox(width: 12.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    documentName,
                    style: AppTextStyles.textSmSemibold.copyWith(
                      color: AppColors.neutral200,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    documentSize,
                    style: AppTextStyles.textXsmRegular.copyWith(
                      color: AppColors.neutral200,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              color: AppColors.neutral200,
              size: 20.0,
            ),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
