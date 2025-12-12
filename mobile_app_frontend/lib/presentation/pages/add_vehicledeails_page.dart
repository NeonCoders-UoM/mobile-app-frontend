import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/services/auth_service.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';
import 'package:mobile_app_frontend/state/providers/vehicle_provider.dart';

class AddVehicledetailsPage extends StatefulWidget {
  final int customerId;
  final String token;

  const AddVehicledetailsPage({
    Key? key,
    required this.customerId,
    required this.token,
  }) : super(key: key);

  @override
  State<AddVehicledetailsPage> createState() => _AddVehicledetailsPageState();
}

class _AddVehicledetailsPageState extends State<AddVehicledetailsPage> {
  final _authService = AuthService();

  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _chassisNumberController =
      TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();

  bool _isLoading = false;

  Future<void> _handleAdd() async {
    if (_registrationNumberController.text.isEmpty ||
        _chassisNumberController.text.isEmpty ||
        _modelController.text.isEmpty ||
        _fuelTypeController.text.isEmpty ||
        _brandController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Add vehicle using the provider
      final vehicleProvider =
          Provider.of<VehicleProvider>(context, listen: false);
      await vehicleProvider.addVehicle(
        widget.customerId,
        {
          'registrationNumber': _registrationNumberController.text,
          'chassisNumber': _chassisNumberController.text,
          'model': _modelController.text,
          'brand': _brandController.text,
          'fuel': _fuelTypeController.text,
          'mileage': 0,
          'year': 2025,
        },
        widget.token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle added successfully')),
      );

      // Navigate back to vehicle details home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VehicleDetailsHomePage(
            customerId: widget.customerId,
            token: widget.token,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add vehicle: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add Vehicle',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral500,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary200,
                        AppColors.primary300,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary200.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.directions_car,
                          size: 48,
                          color: AppColors.neutral100,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Add New Vehicle',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral100,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fill in the details below',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.neutral100.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.neutral450,
                        AppColors.neutral450.withOpacity(0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputFieldAtom(
                        label: 'Registration Number/License Plate',
                        placeholder: 'Registration Number',
                        controller: _registrationNumberController,
                        keyboardType: TextInputType.text,
                        state: InputFieldState.defaultState,
                      ),
                      const SizedBox(height: 20),
                      InputFieldAtom(
                        label: 'Chassis Number',
                        placeholder: 'Chassis Number',
                        controller: _chassisNumberController,
                        keyboardType: TextInputType.text,
                        state: InputFieldState.defaultState,
                      ),
                      const SizedBox(height: 20),
                      InputFieldAtom(
                        label: 'Vehicle Brand',
                        placeholder: 'Vehicle Brand',
                        controller: _brandController,
                        keyboardType: TextInputType.text,
                        state: InputFieldState.defaultState,
                      ),
                      const SizedBox(height: 20),
                      InputFieldAtom(
                        label: 'Model',
                        placeholder: 'Model',
                        controller: _modelController,
                        keyboardType: TextInputType.text,
                        state: InputFieldState.defaultState,
                      ),
                      const SizedBox(height: 20),
                      InputFieldAtom(
                        label: 'Fuel Type',
                        placeholder: 'Fuel Type',
                        controller: _fuelTypeController,
                        keyboardType: TextInputType.text,
                        state: InputFieldState.defaultState,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary200.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: CustomButton(
                      label: _isLoading ? 'Adding...' : 'Add Vehicle',
                      type: ButtonType.primary,
                      size: ButtonSize.medium,
                      onTap: _isLoading ? null : _handleAdd,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
