import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/pages/emergencyservice_page.dart';
import 'package:mobile_app_frontend/services/auth_service.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/vehicle_header.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/vehicle_detail_row.dart';
import 'package:mobile_app_frontend/presentation/pages/appointment_page.dart';
import 'package:mobile_app_frontend/presentation/pages/delete_vehicle_page.dart';
import 'package:mobile_app_frontend/presentation/pages/fuel_summary_page.dart';
import 'package:mobile_app_frontend/presentation/pages/scheduled_reminders.dart';
import 'package:mobile_app_frontend/presentation/pages/service_history_page.dart';
import 'package:mobile_app_frontend/presentation/pages/edit_vehicledetails_page.dart';
import 'package:mobile_app_frontend/presentation/pages/documents_page.dart';
import 'package:mobile_app_frontend/presentation/pages/login_page.dart';
import 'package:mobile_app_frontend/presentation/pages/personal_details_page.dart';
import 'package:mobile_app_frontend/presentation/pages/notifications_page.dart';


class VehicleDetailsHomePage extends StatefulWidget {
  final int customerId;
  final String token;

  const VehicleDetailsHomePage({
    Key? key,
    required this.customerId,
    required this.token,
  }) : super(key: key);

  @override
  State<VehicleDetailsHomePage> createState() => _VehicleDetailsHomePageState();
}

class _VehicleDetailsHomePageState extends State<VehicleDetailsHomePage> {
  final _authService = AuthService();
  Map<String, dynamic>? _vehicle;

  @override
  void initState() {
    super.initState();
    _loadVehicleDetails();
  }

  Future<void> _loadVehicleDetails() async {
    final vehicles = await _authService.getCustomerVehicles(
      customerId: widget.customerId,
      token: widget.token,
    );

    if (vehicles != null && vehicles.isNotEmpty) {
      setState(() {
        _vehicle = vehicles[0];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No vehicles found')),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.neutral300,
          title: Text(
            'Logout',
            style: AppTextStyles.textSmSemibold.copyWith(
              color: AppColors.neutral100,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.neutral200,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: AppTextStyles.textSmMedium.copyWith(
                  color: AppColors.neutral200,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout();
              },
              child: Text(
                'Logout',
                style: AppTextStyles.textSmMedium.copyWith(
                  color: AppColors.primary300,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _performLogout() {
    // Clear any stored tokens or session data
    // TODO: Implement actual logout logic (clear SharedPreferences, etc.)

    // Navigate to login page and clear navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_vehicle == null) {
      return const Scaffold(
        backgroundColor: AppColors.neutral400,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutral400,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 72),
                  VehicleHeader(
                    vehicleName:
                        _vehicle!['registrationNumber'] ?? '', // ✅ lower case
                    vehicleId: _vehicle!['vehicleId'].toString(),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 350,
                          width: 180,
                          child: Image.asset(
                            'assets/images/mustang_top.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 36),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              VehicleDetailRow(
                                  label: "Brand",
                                  value: _vehicle!['brand'] ?? ''),
                              VehicleDetailRow(
                                  label: "Model",
                                  value: _vehicle!['model'] ?? ''),
                              VehicleDetailRow(
                                  label: "Chassis Number",
                                  value: _vehicle!['chassisNumber'] ?? ''),
                              VehicleDetailRow(
                                  label: "Fuel Type",
                                  value: _vehicle!['fuel'] ?? ''),
                              VehicleDetailRow(
                                  label: "Year",
                                  value: _vehicle!['year'].toString()),
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
                        _iconWithLabel(
                            context,
                        "assets/icons/documents.svg",
                        "Documents",
                        DocumentsPage(
                            customerId: 1, vehicleId: 1)),
                        _iconWithLabel(
                            context,
                            "assets/icons/appointments.svg",
                            "Appointments",
                            AppointmentPage(
                              customerId: widget.customerId,
                              vehicleId: _vehicle?['vehicleId'] ?? 1,
                              token: widget.token,
                            )),
                        _iconWithLabel(
                            context,
                            "assets/icons/fuel_efficiency.svg",
                            "Fuel Efficiency",
                            FuelSummaryPage(
                              vehicleId: _vehicle?['vehicleId'] ?? 1,
                              token: widget.token,
                            )),
                        _iconWithLabel(
                            context,
                            "assets/icons/service_history.svg",
                            "Service History",
                            ServiceHistoryPage(
                              vehicleId: _vehicle?['vehicleId'] ?? 1,
                              vehicleName: _vehicle?['model'] ?? 'Vehicle',
                              vehicleRegistration:
                                  _vehicle?['registrationNumber'] ?? 'Unknown',
                              token: widget.token,
                            )),
                        _iconWithLabel(
                            context,
                            "assets/icons/set_reminders.svg",
                            "Set Reminders",
                            RemindersPage(
                              vehicleId: _vehicle?['vehicleId'] ?? 1,
                              token: widget.token,
                            )),
                        _iconWithLabel(
                            context,
                            "assets/icons/emergency.svg",
                            "Emergency",
                            EmergencyservicePage(token: widget.token)),
                        if (_vehicle != null)
                          _iconWithLabel(
                            context,
                            "assets/icons/edit.svg",
                            "Edit",
                            EditVehicledetailsPage(
                              customerId: widget.customerId,
                              vehicleId: _vehicle!['vehicleId'],
                              token: widget.token,
                            ),
                          ),
                        _iconWithLabel(context, "assets/icons/delete.svg",
                            "Delete", const DeleteVehiclePage()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Logout icon positioned in top left corner
            Positioned(
              top: 16,
              left: 16,
              child: GestureDetector(
                onTap: _showLogoutDialog,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neutral300.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: AppColors.neutral100,
                    size: 24,
                  ),
                ),
              ),
            ),
            // Notification and Profile icons positioned in top right corner
            Positioned(
              top: 16,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Notification bell icon
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NotificationsPage(
                            customerId: widget.customerId,
                            token: widget.token,
                            vehicleId: _vehicle?['vehicleId'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.neutral300.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications,
                        color: AppColors.neutral100,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Profile icon
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PersonalDetailsPage(
                            customerId: widget.customerId,
                            token: widget.token,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.neutral300.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),                    
                      child: const Icon(
                        Icons.person,
                        color: AppColors.neutral100,
                        size: 24,
                              ),
                    ),
                  ),
                ],
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
