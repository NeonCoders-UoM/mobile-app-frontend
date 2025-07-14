import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/vehicle_header.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/vehicle_detail_row.dart';
import 'package:mobile_app_frontend/presentation/pages/appointment_page.dart';
import 'package:mobile_app_frontend/presentation/pages/delete_vehicle_page.dart';
import 'package:mobile_app_frontend/presentation/pages/fuel_summary_page.dart';
import 'package:mobile_app_frontend/presentation/pages/scheduled_reminders.dart';
import 'package:mobile_app_frontend/presentation/pages/service_history_page.dart';
import 'package:mobile_app_frontend/presentation/pages/edit_vehicledetails_page.dart';
import 'package:mobile_app_frontend/presentation/pages/notifications_page.dart';
import 'package:mobile_app_frontend/data/repositories/notification_repository.dart';

class VehicleDetailsPage extends StatefulWidget {
  const VehicleDetailsPage({Key? key}) : super(key: key);

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  final NotificationRepository _notificationRepository =
      NotificationRepository();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final notifications = await _notificationRepository.getAllNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;
      if (mounted) {
        setState(() {
          _unreadCount = unreadCount;
        });
      }
    } catch (e) {
      // Handle error silently for better UX
      if (mounted) {
        setState(() {
          _unreadCount = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 72),
                  const VehicleHeader(
                    vehicleName: "Mustang 1977",
                    vehicleId: "AB899395",
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Car Image
                        SizedBox(
                          height: 350,
                          width: 180,
                          child: Image.asset(
                            'assets/images/mustang_top.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 36),
                        // Vehicle Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              VehicleDetailRow(
                                  label: "Brand", value: "Mustang"),
                              VehicleDetailRow(
                                  label: "Model", value: "Mustang 25"),
                              VehicleDetailRow(
                                  label: "Chassis Number", value: "1455ADSF"),
                              VehicleDetailRow(
                                  label: "Fuel Type", value: "Petrol"),
                              VehicleDetailRow(label: "Type", value: "Car"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 4,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: [
                        _iconWithLabel(context, "assets/icons/documents.svg",
                            "Documents", AppointmentPage()), //Change the page
                        _iconWithLabel(context, "assets/icons/appointments.svg",
                            "Appointments", AppointmentPage()),
                        _iconWithLabel(
                            context,
                            "assets/icons/fuel_efficiency.svg",
                            "Fuel Efficiency",
                            FuelSummaryPage()),
                        _iconWithLabel(
                            context,
                            "assets/icons/service_history.svg",
                            "Service History",
                            ServiceHistoryPage()),
                        _iconWithLabel(
                            context,
                            "assets/icons/set_reminders.svg",
                            "Set Reminders",
                            RemindersPage()),
                        _iconWithLabel(context, "assets/icons/emergency.svg",
                            "Emergency", AppointmentPage()),
                        _iconWithLabel(context, "assets/icons/edit.svg", "Edit",
                            EditVehicledetailsPage()),
                        _iconWithLabel(context, "assets/icons/delete.svg",
                            "Delete", DeleteVehiclePage()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Notification bell icon positioned at top-right
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () async {
                  // Navigate to notifications page
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsPage()),
                  );
                  // Refresh unread count when returning from notifications page
                  if (result == true) {
                    _loadUnreadCount();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        color: AppColors.neutral400,
                        size: 24,
                      ),
                      // Badge for unread count
                      if (_unreadCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              _unreadCount > 99
                                  ? '99+'
                                  : _unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _iconWithLabel(BuildContext context, String assetPath,
      String label, Widget destinationScreen) {
    return GestureDetector(
      onTap: () {
        // Navigate to the new screen when tapped
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationScreen),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            assetPath,
            height: 48,
            color: AppColors.neutral100,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.textXsmRegular.copyWith(
              color: AppColors.neutral100,
            ),
          ),
        ],
      ),
    );
  }
}
