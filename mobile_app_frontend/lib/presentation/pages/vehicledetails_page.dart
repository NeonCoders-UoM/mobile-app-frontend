import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/custom_dropdown_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/services/auth_service.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';
import 'package:mobile_app_frontend/presentation/pages/login_page.dart';

class VehicledetailsPage extends StatefulWidget {
  final int customerId; // ✅ Pass this in!

  const VehicledetailsPage({Key? key, required this.customerId})
      : super(key: key);

  @override
  State<VehicledetailsPage> createState() => _VehicledetailsPageState();
}

class _VehicledetailsPageState extends State<VehicledetailsPage> {
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _chassisNumberController =
      TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();
  final _authService = AuthService();

  String? _selectedBrand;

  void _handleNext() async {
    final regNo = _registrationNumberController.text.trim();
    final chassisNo = _chassisNumberController.text.trim();
    final category = _categoryController.text.trim();
    final model = _modelController.text.trim();
    final fuel = _fuelTypeController.text.trim();
    final brand = _selectedBrand ?? '';

    if (regNo.isEmpty || chassisNo.isEmpty || model.isEmpty || brand.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final success = await _authService.registerVehicle(
      customerId: widget.customerId,
      registrationNumber: regNo,
      chassisNumber: chassisNo,
      category: category,
      model: model,
      brand: brand,
      fuel: fuel,
    );

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehicle registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Vehicle Details',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral400,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Header Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary300.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.directions_car,
                          size: 48,
                          color: AppColors.primary200,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Register Your Vehicle',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral100,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please provide your vehicle information',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.neutral200,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Form Section with Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.neutral300.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.neutral300.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputFieldAtom(
                        label: 'Registration Number/License Plate',
                        placeholder: 'e.g., CAB-1234',
                        controller: _registrationNumberController,
                        keyboardType: TextInputType.text,
                        state: InputFieldState.defaultState,
                      ),
                      const SizedBox(height: 24),
                      InputFieldAtom(
                        label: 'Chassis Number',
                        placeholder: 'Enter chassis number',
                        controller: _chassisNumberController,
                        keyboardType: TextInputType.text,
                        state: InputFieldState.defaultState,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: InputFieldAtom(
                              label: 'Category',
                              placeholder: 'e.g., Sedan',
                              controller: _categoryController,
                              keyboardType: TextInputType.text,
                              state: InputFieldState.defaultState,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InputFieldAtom(
                              label: 'Fuel Type',
                              placeholder: 'e.g., Petrol',
                              controller: _fuelTypeController,
                              keyboardType: TextInputType.text,
                              state: InputFieldState.defaultState,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CustomDropdownField(
                        label: "Vehicle Brand",
                        items: ["Honda", "Benz", "BMW"],
                        hintText: 'Select your vehicle brand',
                        onChanged: (val) {
                          setState(() {
                            _selectedBrand = val;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      InputFieldAtom(
                        label: 'Model',
                        placeholder: 'e.g., Civic, C-Class',
                        controller: _modelController,
                        keyboardType: TextInputType.text,
                        state: InputFieldState.defaultState,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Action Button
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: CustomButton(
                      label: 'Confirm & Continue',
                      type: ButtonType.primary,
                      size: ButtonSize.medium,
                      onTap: _handleNext,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
