import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/data/models/vehicle.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/vehicle_header.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/vehicle_detail_row.dart';
import 'package:mobile_app_frontend/presentation/pages/appointment_page.dart';
import 'package:mobile_app_frontend/presentation/pages/delete_vehicle_page.dart';
import 'package:mobile_app_frontend/presentation/pages/fuel_summary_page.dart';
import 'package:mobile_app_frontend/presentation/pages/notifications_page.dart';
import 'package:mobile_app_frontend/presentation/pages/profile_options_page.dart';
import 'package:mobile_app_frontend/presentation/pages/service_history_page.dart';
import 'package:mobile_app_frontend/presentation/pages/set_reminder_page.dart';
import 'package:mobile_app_frontend/presentation/pages/edit_vehicledetails_page.dart';

class VehicleDetailsPage extends StatefulWidget {
  const VehicleDetailsPage({Key? key}) : super(key: key);

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  late Future<Vehicle> _vehicleFuture;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _vehicleFuture = fetchVehicle();
  }

  Future<Vehicle> fetchVehicle() async {
    try {
      final url = Uri.parse('http://localhost:5285/api/vehicles/38');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('API Response: $jsonData'); // Debug log

        return Vehicle(
          registrationNumber:
              jsonData['registrationNumber']?.toString() ?? 'N/A',
          chassisNumber: jsonData['chassiNumber']?.toString() ?? 'N/A',
          mileage: jsonData['mileage']?.toString() ?? '0',
          brand: jsonData['brand']?.toString() ?? 'Unknown',
          model: jsonData['model']?.toString() ?? 'N/A',
          fuelType: jsonData['fuelType']?.toString() ?? 'N/A',
        );
      } else {
        throw Exception('Failed to load vehicle: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching vehicle: $e');
      setState(() {
        errorMessage = 'Error fetching vehicle: $e';
      });
      return Vehicle(
        registrationNumber: 'N/A',
        chassisNumber: 'N/A',
        mileage: '0',
        brand: 'Unknown',
        model: 'N/A',
        fuelType: 'N/A',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotificationsPage()),
                        );
                      },
                      child: Image.asset(
                        'assets/icons/bell.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileOptionPage()),
                        );
                      },
                      child: Image.asset(
                        'assets/icons/profile.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              FutureBuilder<Vehicle>(
                future: _vehicleFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final vehicle = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VehicleHeader(
                          vehicleName: '${vehicle.brand} - ${vehicle.model}',
                          vehicleId: '38', //Hardcoded Value
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
                                      label: "Registration Number",
                                      value: vehicle.registrationNumber,
                                    ),
                                    VehicleDetailRow(
                                      label: "Brand",
                                      value: vehicle.brand,
                                    ),
                                    VehicleDetailRow(
                                      label: "Model",
                                      value: vehicle.model,
                                    ),
                                    VehicleDetailRow(
                                      label: "Chassis Number",
                                      value: vehicle.chassisNumber,
                                    ),
                                    VehicleDetailRow(
                                      label: "Mileage",
                                      value: "${vehicle.mileage} km",
                                    ),
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
                                AppointmentPage(),
                              ),
                              _iconWithLabel(
                                context,
                                "assets/icons/appointments.svg",
                                "Appointments",
                                AppointmentPage(),
                              ),
                              _iconWithLabel(
                                context,
                                "assets/icons/fuel_efficiency.svg",
                                "Fuel Efficiency",
                                FuelSummaryPage(),
                              ),
                              _iconWithLabel(
                                context,
                                "assets/icons/service_history.svg",
                                "Service History",
                                ServiceHistoryPage(),
                              ),
                              _iconWithLabel(
                                context,
                                "assets/icons/set_reminders.svg",
                                "Set Reminders",
                                SetReminderPage(),
                              ),
                              _iconWithLabel(
                                context,
                                "assets/icons/emergency.svg",
                                "Emergency",
                                AppointmentPage(),
                              ),
                              _iconWithLabel(
                                context,
                                "assets/icons/edit.svg",
                                "Edit",
                                EditVehicledetailsPage(),
                              ),
                              _iconWithLabel(
                                context,
                                "assets/icons/delete.svg",
                                "Delete",
                                DeleteVehiclePage(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
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
            style: AppTextStyles.textXsmRegular
                .copyWith(color: AppColors.neutral100),
          ),
        ],
      ),
    );
  }
}
