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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
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
                  label: 'Category',
                  placeholder: 'Category',
                  controller: _categoryController,
                  keyboardType: TextInputType.text,
                  state: InputFieldState.defaultState,
                ),
                const SizedBox(height: 32),
                CustomDropdownField(
                  label: "Vehicle Brand",
                  items: ["Honda", "Benz", "BMW"],
                  hintText: 'Choose a Brand',
                  onChanged: (val) {
                    setState(() {
                      _selectedBrand = val;
                    });
                  },
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
                      label: 'Confirm',
                      type: ButtonType.primary,
                      size: ButtonSize.medium,
                      onTap: _handleNext,
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
