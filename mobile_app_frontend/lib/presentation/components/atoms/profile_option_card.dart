import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class ProfileOptionCard extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;

  const ProfileOptionCard({super.key, required this.text, this.onTap});

  @override
  _ProfileOptionCardState createState() => _ProfileOptionCardState();
}

class _ProfileOptionCardState extends State<ProfileOptionCard> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isTapped = !_isTapped;
        });
        // Call the provided onTap callback if available
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isTapped
                ? [
                    AppColors.neutral300.withOpacity(0.4),
                    AppColors.neutral300.withOpacity(0.25),
                  ]
                : [
                    AppColors.neutral300.withOpacity(0.3),
                    AppColors.neutral300.withOpacity(0.15),
                  ],
          ),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.neutral200.withOpacity(0.25),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.text,
              style: AppTextStyles.textLgRegular.copyWith(
                color: AppColors.neutral100,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.neutral100,
            ),
          ],
        ),
      ),
    );
  }
}
