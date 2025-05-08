import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicle_deleted_page.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';

class DeleteVehiclePage extends StatefulWidget {
  const DeleteVehiclePage({super.key});

  @override
  _DeleteVehiclePageState createState() => _DeleteVehiclePageState();
}

class _DeleteVehiclePageState extends State<DeleteVehiclePage> {
  String _responseMessage = '';
  final int vehicleId = 11; // Hardcoded VehicleID

  // Function to delete vehicle by ID = 18
  Future<void> deleteVehicle() async {
    final url = Uri.parse(
        'http://localhost:5285/api/vehicles/$vehicleId'); // Adjust endpoint if needed

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _responseMessage = 'Vehicle with ID $vehicleId deleted successfully!';
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VehicleDeletedPage()),
        );
      } else {
        setState(() {
          _responseMessage =
              'Failed to delete vehicle. Status code: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Delete Vehicle',
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
              Text(
                "Are you sure you want to delete the vehicle with ID: $vehicleId?",
                style: AppTextStyles.textLgSemibold.copyWith(
                  color: AppColors.neutral100,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                "Once you delete your vehicle, it cannot be undone. All your data will be permanently erased from this app including your vehicle information, preferences, saved content, and any activity history.! 🚗✅",
                style: AppTextStyles.textSmRegular.copyWith(
                  color: AppColors.neutral100,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _responseMessage,
                style: TextStyle(
                  color: _responseMessage.contains('success')
                      ? Colors.green
                      : Colors.red,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Delete Vehicle',
                  type: ButtonType.danger,
                  size: ButtonSize.medium,
                  onTap: deleteVehicle,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Go Back',
                  type: ButtonType.primary,
                  size: ButtonSize.medium,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const VehicleDetailsPage(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
