import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicle_deleted_page.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';


class DeleteVehiclePage extends StatelessWidget {
  const DeleteVehiclePage({super.key});

  void _handledeletevehicle() {
    print('Successfully deleted');
  }

  void _handleback() {
    print('fefef');
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
                "Are you sure you want to delete the vehicle?",
                style: AppTextStyles.textLgSemibold.copyWith(
                  color: AppColors.neutral100,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                "Once you delete your vehicle, it cannot be undone. All your data will be permanentlyerase from this app includes your vehicle information, preferences, saved content,andany activity history.! 🚗✅",
                style: AppTextStyles.textSmRegular.copyWith(
                  color: AppColors.neutral100,
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Delete Vehicle',
                  type: ButtonType.danger,
                  size: ButtonSize.medium,

                  onTap: () => {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const VehicleDeletedPage()))
                  },

                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Go Back',
                  type: ButtonType.primary,
                  size: ButtonSize.medium,
                  onTap: _handleback,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
