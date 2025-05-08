import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/custom_dropdown_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/pages/profile_options_page.dart';

class AddVehicledetailsPage extends StatefulWidget {
  const AddVehicledetailsPage({Key? key}) : super(key: key);

  @override
  State<AddVehicledetailsPage> createState() => _AddVehicledetailsPageState();
}

class _AddVehicledetailsPageState extends State<AddVehicledetailsPage> {
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _chassisNumberController =
      TextEditingController();
      final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();

  void _handleAdd() {
    print('Proceeding to the next step');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add Vehicle ',
        showTitle: true,
        onBackPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileOptionPage())),
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
                  keyboardType: TextInputType.text,
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
                          label: 'Add Vehicle',
                          type: ButtonType.primary,
                          size: ButtonSize.medium,
                          onTap: _handleAdd,
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
