import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class NotificationCard extends StatefulWidget {
  final String title;
  final String description;
  final String time;
  final bool isRead;
  final String? priority;
  final String? vehicleInfo;

  const NotificationCard({
    Key? key,
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
    this.priority,
    this.vehicleInfo,
  }) : super(key: key);

  @override
  _NotificationCardState createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _isHovered = false;

  Color get _priorityColor {
    switch (widget.priority?.toLowerCase()) {
      case 'critical':
        return const Color(0xFFFF4757); // Bright red
      case 'high':
        return const Color(0xFFFF6B35); // Vibrant orange
      case 'medium':
        return const Color(0xFFFFA502); // Golden yellow
      case 'low':
        return const Color(0xFF2ED573); // Fresh green
      default:
        return const Color(0xFF747D8C); // Modern grey
    }
  }

  IconData _getNotificationIcon() {
    switch (widget.priority?.toLowerCase()) {
      case 'critical':
        return Icons.error;
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info;
      case 'low':
        return Icons.check_circle;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: widget.isRead 
              ? [
                  AppColors.neutral400.withOpacity(0.7),
                  AppColors.neutral450.withOpacity(0.7),
                ]
              : _isHovered
                ? [
                    const Color(0xFF4A5568),
                    const Color(0xFF2D3748),
                  ]
                : [
                    const Color(0xFF2D3748),
                    const Color(0xFF4A5568),
                  ],
          ),
          borderRadius: BorderRadius.circular(12.0),
          border: Border(
            left: BorderSide(
              width: 4.0,
              color: _priorityColor,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isRead 
                ? Colors.black.withOpacity(0.1)
                : _priorityColor.withOpacity(0.3),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
            if (!widget.isRead)
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 4.0,
                offset: const Offset(0, -1),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority indicator and notification icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    _priorityColor.withOpacity(0.3),
                    _priorityColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: _priorityColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Icon(
                _getNotificationIcon(),
                color: _priorityColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12.0),
            // Notification Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: AppTextStyles.textMdSemibold.copyWith(
                            color: widget.isRead
                                ? AppColors.neutral300
                                : AppColors.neutral150,
                            fontWeight: widget.isRead
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.time,
                            style: AppTextStyles.textSmRegular.copyWith(
                              color: AppColors.neutral300,
                              fontSize: 12,
                            ),
                          ),
                          if (!widget.isRead)
                            Container(
                              width: 10,
                              height: 10,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFF00D4FF),
                                    const Color(0xFF007BFF),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF007BFF).withOpacity(0.5),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    style: AppTextStyles.textSmRegular.copyWith(
                      color: widget.isRead
                          ? AppColors.neutral300
                          : AppColors.neutral200,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.priority != null || widget.vehicleInfo != null)
                    const SizedBox(height: 8),
                  if (widget.priority != null || widget.vehicleInfo != null)
                    Row(
                      children: [
                        if (widget.priority != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _priorityColor.withOpacity(0.8),
                                  _priorityColor,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: _priorityColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.priority!,
                              style: AppTextStyles.textSmRegular.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        if (widget.priority != null &&
                            widget.vehicleInfo != null)
                          const SizedBox(width: 8),
                        if (widget.vehicleInfo != null)
                          Expanded(
                            child: Text(
                              widget.vehicleInfo!,
                              style: AppTextStyles.textSmRegular.copyWith(
                                color: AppColors.neutral300,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
