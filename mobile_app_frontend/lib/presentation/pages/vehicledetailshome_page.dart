import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
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
import 'package:mobile_app_frontend/presentation/components/vehicle_switcher.dart';
import 'package:mobile_app_frontend/state/providers/vehicle_provider.dart';

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

  @override
  void initState() {
    super.initState();
    // Load vehicles using provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VehicleProvider>(context, listen: false)
          .loadVehicles(widget.customerId, widget.token);
    });
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
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProvider, child) {
        final selectedVehicle = vehicleProvider.selectedVehicle;
        if (vehicleProvider.vehicles.isEmpty) {
          return const Scaffold(
            backgroundColor: AppColors.neutral400,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (selectedVehicle == null) {
          return const Scaffold(
            backgroundColor: AppColors.neutral400,
            body: Center(
              child: Text('No vehicles found. Please add a vehicle.'),
            ),
          );
        }
        return Scaffold(
          backgroundColor: AppColors.neutral400,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // --- Modern AppBar Section ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logout icon
                        GestureDetector(
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
                        // Vehicle Switcher
                        VehicleSwitcher(
                          customerId: widget.customerId,
                          token: widget.token,
                        ),
                        Row(
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
                                      vehicleId: selectedVehicle.vehicleId,
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // --- Main Content ---
                  VehicleHeader(
                    vehicleName: selectedVehicle.registrationNumber,
                    vehicleId: selectedVehicle.vehicleId.toString(),
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
                                  value: selectedVehicle.brand),
                              VehicleDetailRow(
                                  label: "Model",
                                  value: selectedVehicle.model),
                              VehicleDetailRow(
                                  label: "Chassis Number",
                                  value: selectedVehicle.chassisNumber),
                              VehicleDetailRow(
                                  label: "Fuel Type",
                                  value: selectedVehicle.fuel),
                              VehicleDetailRow(
                                  label: "Year",
                                  value: selectedVehicle.year.toString()),
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
                              customerId: widget.customerId,
                              vehicleId: selectedVehicle.vehicleId,
                            )),
                        _iconWithLabel(
                            context,
                            "assets/icons/appointments.svg",
                            "Appointments",
                            AppointmentPage(
                              customerId: widget.customerId,
                              vehicleId: selectedVehicle.vehicleId,
                              token: widget.token,
                            )),
                        _iconWithLabel(
                            context,
                            "assets/icons/fuel_efficiency.svg",
                            "Fuel Efficiency",
                            FuelSummaryPage(
                              vehicleId: selectedVehicle.vehicleId,
                              token: widget.token,
                            )),
                        _iconWithLabel(
                            context,
                            "assets/icons/service_history.svg",
                            "Service History",
                            ServiceHistoryPage(
                              vehicleId: selectedVehicle.vehicleId,
                              vehicleName: selectedVehicle.model,
                              vehicleRegistration:
                                  selectedVehicle.registrationNumber,
                              token: widget.token,
                            )),
                        _iconWithLabel(
                            context,
                            "assets/icons/set_reminders.svg",
                            "Set Reminders",
                            RemindersPage(
                              vehicleId: selectedVehicle.vehicleId,
                              token: widget.token,
                              customerId: widget.customerId,
                            )),
                        _iconWithLabel(
                            context,
                            "assets/icons/emergency.svg",
                            "Emergency",
                            EmergencyservicePage(token: widget.token)),
                        _iconWithLabel(
                          context,
                          "assets/icons/edit.svg",
                          "Edit",
                          EditVehicledetailsPage(
                            customerId: widget.customerId,
                            vehicleId: selectedVehicle.vehicleId,
                            token: widget.token,
                          ),
                        ),
                        _iconWithLabel(context, "assets/icons/delete.svg",
                            "Delete", DeleteVehiclePage(
                              customerId: widget.customerId,
                              vehicleId: selectedVehicle.vehicleId,
                              token: widget.token,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
