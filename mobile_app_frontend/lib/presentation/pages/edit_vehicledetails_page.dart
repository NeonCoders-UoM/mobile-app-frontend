import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/custom_dropdown_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';

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
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();

  void _handleUpdate() {
    print('succesfully Updated');
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
                  label: "Vehicle Type",
                  items: ["Honda", "Benz", "BMW"],
                  hintText: 'Choose a Type',
                  onChanged: (val) {
                    print("Selected: $val");
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 220,
                        height: 48,
                        child: CustomButton(
                          label: 'update',
                          type: ButtonType.primary,
                          size: ButtonSize.medium,
                          onTap: _handleUpdate,
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
