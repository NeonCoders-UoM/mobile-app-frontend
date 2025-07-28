import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/services/auth_service.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/custom_dropdown_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';
import 'package:mobile_app_frontend/state/providers/vehicle_provider.dart';

class EditVehicledetailsPage extends StatefulWidget {
  final int customerId;
  final int vehicleId;
  final String token;

  const EditVehicledetailsPage({
    Key? key,
    required this.customerId,
    required this.vehicleId,
    required this.token,
  }) : super(key: key);

  @override
  State<EditVehicledetailsPage> createState() => _EditVehicledetailsPageState();
}

class _EditVehicledetailsPageState extends State<EditVehicledetailsPage> {
  final _authService = AuthService();

  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _chassisNumberController =
      TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();

  bool _isLoading = true;

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
      final vehicle = vehicles.firstWhere(
        (v) => v['vehicleId'] == widget.vehicleId,
        orElse: () => null,
      );

      if (vehicle != null) {
        setState(() {
          _registrationNumberController.text =
              vehicle['registrationNumber'] ?? '';
          _chassisNumberController.text = vehicle['chassisNumber'] ?? '';
          _modelController.text = vehicle['model'] ?? '';
          _fuelTypeController.text = vehicle['fuel'] ?? '';
          _brandController.text = vehicle['brand'] ?? '';
          _isLoading = false;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vehicle not found')),
          );
          Navigator.of(context).pop();
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No vehicles found')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _handleUpdate() async {
    final success = await _authService.updateVehicle(
      customerId: widget.customerId,
      vehicleId: widget.vehicleId,
      token: widget.token,
      registrationNumber: _registrationNumberController.text,
      chassisNumber: _chassisNumberController.text,
      model: _modelController.text,
      brand: _brandController.text,
      fuel: _fuelTypeController.text,
      mileage: 0, // TODO: let user enter mileage if needed
      year: 2025, // TODO: let user enter year if needed
    );

    if (!mounted) return;

    if (success) {
      // Update the vehicle data in the provider
      final vehicleProvider = Provider.of<VehicleProvider>(context, listen: false);
      await vehicleProvider.updateVehicle(
        widget.customerId,
        widget.vehicleId,
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vehicle updated successfully')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VehicleDetailsHomePage(
            customerId: widget.customerId,
            token: widget.token,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Vehicle Details',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral400,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 36),
                      InputFieldAtom(
                        label: 'Registration Number/License Plate',
                        placeholder: 'Registration Number',
                        controller: _registrationNumberController,
                        keyboardType: TextInputType.text,
                        state: InputFieldState.defaultState,
                      ),
                      const SizedBox(height: 32),
                      InputFieldAtom(
                        label: 'Chassis Number',
                        placeholder: 'Chassis Number',
                        controller: _chassisNumberController,
                        keyboardType: TextInputType.text,
                        state: InputFieldState.defaultState,
                      ),
                      const SizedBox(height: 32),
                      InputFieldAtom(
                        label: 'Vehicle Brand',
                        placeholder: 'Vehicle Brand',
                        controller: _brandController,
                        keyboardType: TextInputType.text,
                        state: InputFieldState.defaultState,
                      ),
                      const SizedBox(height: 32),
                      InputFieldAtom(
                        label: 'Model',
                        placeholder: 'Model',
                        controller: _modelController,
                        keyboardType: TextInputType.text,
                        state: InputFieldState.defaultState,
                      ),
                      const SizedBox(height: 32),
                      InputFieldAtom(
                        label: 'Fuel Type',
                        placeholder: 'Fuel Type',
                        controller: _fuelTypeController,
                        keyboardType: TextInputType.text,
                        state: InputFieldState.defaultState,
                      ),
                      const SizedBox(height: 72),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: 220,
                          height: 48,
                          child: CustomButton(
                            label: 'Update',
                            type: ButtonType.primary,
                            size: ButtonSize.medium,
                            onTap: _handleUpdate,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
