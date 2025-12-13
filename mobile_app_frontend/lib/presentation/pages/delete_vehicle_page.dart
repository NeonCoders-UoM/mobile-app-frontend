import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicle_deleted_page.dart';
import 'package:mobile_app_frontend/state/providers/vehicle_provider.dart';
import 'package:mobile_app_frontend/presentation/pages/login_page.dart'; // or next step

class DeleteVehiclePage extends StatefulWidget {
  final int customerId;
  final int vehicleId;
  final String token;

  const DeleteVehiclePage({
    super.key,
    required this.customerId,
    required this.vehicleId,
    required this.token,
  });

  @override
  State<DeleteVehiclePage> createState() => _DeleteVehiclePageState();
}

class _DeleteVehiclePageState extends State<DeleteVehiclePage> {
  bool _isDeleting = false;
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleDeleteVehicle() async {
    // Check if password is entered
    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password to confirm deletion'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final vehicleProvider =
          Provider.of<VehicleProvider>(context, listen: false);
      await vehicleProvider.deleteVehicle(
        widget.customerId,
        widget.vehicleId,
        widget.token,
        _passwordController.text.trim(),
      );

      if (mounted) {
        // Navigate to success page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VehicleDeletedPage(
              customerId: widget.customerId,
              token: widget.token,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });

        String errorMessage = 'Failed to delete vehicle. Please try again.';

        // Provide specific error messages based on the exception
        if (e.toString().contains('Invalid password')) {
          errorMessage =
              'Invalid password. Please check your password and try again.';
        } else if (e.toString().contains('Vehicle not found')) {
          errorMessage = 'Vehicle not found.';
        } else if (e.toString().contains('Invalid request')) {
          errorMessage =
              'Invalid request. Please check your input and try again.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: 'Delete Vehicle',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral400,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                "Are you sure you want to delete the vehicle?",
                style: AppTextStyles.textLgSemibold.copyWith(
                  color: AppColors.neutral100,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Once you delete your vehicle, it cannot be undone. All your data will be permanently erased from this app including your vehicle information, preferences, saved content, and any activity history!",
                style: AppTextStyles.textSmRegular.copyWith(
                  color: AppColors.neutral200,
                ),
              ),
              const SizedBox(height: 32),
              InputFieldAtom(
                label: 'Password Confirmation',
                placeholder: 'Enter your password to confirm',
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                state: InputFieldState.defaultState,
                obscureText: true,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isDeleting ? null : _handleDeleteVehicle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  disabledBackgroundColor: Colors.red.shade300,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  _isDeleting ? 'Deleting...' : 'Delete Vehicle',
                  style: AppTextStyles.textMdSemibold.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.textMdSemibold.copyWith(
                      color: AppColors.neutral200,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
