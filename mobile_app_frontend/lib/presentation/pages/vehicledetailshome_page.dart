import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/vehicle_header.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/vehicle_detail_row.dart';

class VehicleDetailsPage extends StatelessWidget {
  const VehicleDetailsPage({Key? key}) : super(key: key);

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
                          VehicleDetailRow(label: "Brand", value: "Mustang"),
                          VehicleDetailRow(label: "Model", value: "Mustang 25"),
                          VehicleDetailRow(
                              label: "Chassis Number", value: "1455ADSF"),
                          VehicleDetailRow(label: "Fuel Type", value: "Petrol"),
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
                    _iconWithLabel("assets/icons/documents.svg", "Documents"),
                    _iconWithLabel(
                        "assets/icons/appointments.svg", "Appointments"),
                    _iconWithLabel(
                        "assets/icons/fuel_efficiency.svg", "Fuel Efficiency"),
                    _iconWithLabel(
                        "assets/icons/service_history.svg", "Service History"),
                    _iconWithLabel(
                        "assets/icons/set_reminders.svg", "Set Reminders"),
                    _iconWithLabel("assets/icons/emergency.svg", "Emergency"),
                    _iconWithLabel("assets/icons/edit.svg", "Edit"),
                    _iconWithLabel("assets/icons/delete.svg", "Delete"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _iconWithLabel(String assetPath, String label) {
    return Column(
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
    );
  }
}
