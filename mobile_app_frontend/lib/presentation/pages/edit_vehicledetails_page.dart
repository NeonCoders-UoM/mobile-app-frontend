import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/custom_dropdown_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetails_page.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';

class EditVehicledetailsPage extends StatefulWidget {
  const EditVehicledetailsPage({Key? key}) : super(key: key);

  @override
  State<EditVehicledetailsPage> createState() => _EditVehicledetailsPageState();
}

class _EditVehicledetailsPageState extends State<EditVehicledetailsPage> {
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _chassisNumberController =
      TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();

  String _responseMessage = '';
  final int _vehicleId = 32; // You want to fetch data for VehicleID = 32

  @override
  void initState() {
    super.initState();
    _fetchVehicleDetails();
  }

  Future<void> _fetchVehicleDetails() async {
    final url = Uri.parse('http://localhost:5285/api/vehicles/$_vehicleId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _registrationNumberController.text = data['registrationNumber'] ?? '';
          _chassisNumberController.text = data['chassiNumber'] ?? '';
          _mileageController.text = data['mileage']?.toString() ?? '';
          _brandController.text = data['brand'] ?? '';
          _modelController.text = data['model'] ?? '';
          _fuelTypeController.text = data['fuelType'] ?? '';
        });
      } else {
        setState(() {
          _responseMessage =
              'Failed to load vehicle details. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Error fetching vehicle details: $e';
      });
    }
  }

  Future<void> _handleUpdate() async {
    final url = Uri.parse('http://localhost:5285/api/vehicles/$_vehicleId');

    final Map<String, dynamic> updatedVehicleData = {
      'registrationNumber': _registrationNumberController.text,
      'chassiNumber': _chassisNumberController.text,
      'mileage': _mileageController.text,
      'brand': _brandController.text,
      'model': _modelController.text,
      'fuelType': _fuelTypeController.text,
    };

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedVehicleData),
      );

      if (response.statusCode == 200) {
        setState(() {
          _responseMessage = 'Vehicle updated successfully!';
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_responseMessage)),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VehicleDetailsPage()),
        );
      } else {
        setState(() {
          _responseMessage =
              'Failed to update. Status code: ${response.statusCode}';
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
        title: 'Edit Vehicle Details',
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
                  label: 'Mileage',
                  placeholder: 'Mileage',
                  controller: _mileageController,
                  keyboardType: TextInputType.number,
                  state: InputFieldState.defaultState,
                ),
                const SizedBox(height: 32),
                InputFieldAtom(
                  label: 'Brand',
                  placeholder: 'Brand',
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 220,
                        height: 48,
                        child: CustomButton(
                          label: 'Update',
                          type: ButtonType.primary,
                          size: ButtonSize.medium,
                          onTap: _handleUpdate,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_responseMessage.isNotEmpty)
                        Text(
                          _responseMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
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
