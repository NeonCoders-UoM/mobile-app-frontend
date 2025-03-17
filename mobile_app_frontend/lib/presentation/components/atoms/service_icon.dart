import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';

class ServiceIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const ServiceIcon({
    super.key,
    required this.icon,
    this.color = AppColors.neutral200,
    this.size = 42.0,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: color,
      size: size,
    );
  }
}
