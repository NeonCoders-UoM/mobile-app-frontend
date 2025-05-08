import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class ProfileOptionCard extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;

  const ProfileOptionCard({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  _ProfileOptionCardState createState() => _ProfileOptionCardState();
}

class _ProfileOptionCardState extends State<ProfileOptionCard> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        color: _isTapped ? AppColors.neutral450 : AppColors.neutral400,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              widget.onTap?.call();
              setState(() {
                _isTapped = !_isTapped;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.text,
                    style: AppTextStyles.textLgRegular.copyWith(
                      color: AppColors.neutral150,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.neutral150,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
