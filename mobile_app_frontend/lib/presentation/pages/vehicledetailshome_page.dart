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
import 'package:mobile_app_frontend/presentation/pages/set_reminder_page.dart';
import 'package:mobile_app_frontend/presentation/pages/edit_vehicledetails_page.dart';
import 'package:mobile_app_frontend/presentation/pages/login_page.dart';

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
        child: SingleChildScrollView(
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
                              label: "Brand", value: _vehicle!['brand'] ?? ''),
                          VehicleDetailRow(
                              label: "Model", value: _vehicle!['model'] ?? ''),
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
                    _iconWithLabel(context, "assets/icons/documents.svg",
                        "Documents", const AppointmentPage()),
                    _iconWithLabel(context, "assets/icons/appointments.svg",
                        "Appointments", const AppointmentPage()),
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
                    _iconWithLabel(context, "assets/icons/emergency.svg",
                        "Emergency", EmergencyservicePage(token: widget.token)),
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
                    _iconWithLabel(context, "assets/icons/delete.svg", "Delete",
                        const DeleteVehiclePage()),
                  ],
                ),
              ),
            ],
          ),
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
