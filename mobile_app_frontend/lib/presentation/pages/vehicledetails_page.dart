import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/pages/profile_options_page.dart';

class VehicledetailsPage extends StatefulWidget {
  const VehicledetailsPage({Key? key}) : super(key: key);

  @override
  State<VehicledetailsPage> createState() => _VehicledetailsPageState();
}

class _VehicledetailsPageState extends State<VehicledetailsPage> {
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _chassisNumberController =
      TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();

  String _responseMessage = '';

  Future<void> _handleNext() async {
    final url = Uri.parse('http://localhost:5285/api/vehicles');

    final vehicleData = {
      'registrationNumber': _registrationNumberController.text,
      'chassiNumber': _chassisNumberController.text,
      'brand': _brandController.text,
      'mileage': _mileageController.text,
      'model': _modelController.text,
      'fuelType': _fuelTypeController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(vehicleData),
      );

      if (response.statusCode == 201) {
        setState(() {
          _responseMessage = 'Vehicle submitted successfully!';
        });
      } else {
        setState(() {
          _responseMessage = 'Failed: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Error occurred: $e';
      });
    }

    // Show feedback as a Snackbar
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_responseMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Vehicle Details',
        showTitle: true,
        onBackPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileOptionPage())),
      ),
      backgroundColor: AppColors.neutral400,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
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
                  label: 'brand',
                  placeholder: 'brand',
                  controller: _brandController,
                  keyboardType: TextInputType.text,
                  state: InputFieldState.defaultState,
                ),
                const SizedBox(height: 32),
                InputFieldAtom(
                  label: 'Mileage',
                  placeholder: 'Milieage',
                  controller: _mileageController,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 220,
                        height: 48,
                        child: CustomButton(
                          label: 'Add New Vehicle',
                          type: ButtonType.primary,
                          size: ButtonSize.medium,
                          onTap: _handleNext,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
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
