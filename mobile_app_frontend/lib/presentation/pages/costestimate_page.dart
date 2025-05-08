import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/cost_estimate_table.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/cost_estimate_description.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';

class CostEstimatePage extends StatelessWidget {
  const CostEstimatePage({super.key});

  void _handleBookAppointment() {
    print('Proceeding to the BookAppointment');
  }

  @override
  Widget build(BuildContext context) {
    final List<String> services = [
      "Oil Changing",
      "Tire Changing",
      "Engine Check",
      "Brake Check",
      "Body Check"
    ];
    final List<int> costs = [40000, 30000, 20000, 50000, 25000];
    final int total = 170000;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Cost Estimation',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral400,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CostEstimateDescription(
                servicecenterName: "Janaka Motors",
                vehicleRegNo: "AB3424",
                appointmentDate: "12/03/2025",
                loyaltyPoints: "4524",
                serviceCenterId: "3421",
                address: "No: 109, Galle Road, Moratuwa",
                distance: "25 km away",
              ),
              const SizedBox(height: 48),
              CostEstimateTable(
                services: services,
                costs: costs,
                total: total,
              ),
              const SizedBox(height: 80),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Book an Appointment',
                  type: ButtonType.primary,
                  size: ButtonSize.medium,
                  onTap: _handleBookAppointment,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
