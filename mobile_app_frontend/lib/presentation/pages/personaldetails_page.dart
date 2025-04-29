import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';

class PersonaldetailsPage extends StatefulWidget {
  const PersonaldetailsPage({Key? key}) : super(key: key);

  @override
  State<PersonaldetailsPage> createState() => _PersonaldetailsPageState();
}

class _PersonaldetailsPageState extends State<PersonaldetailsPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  void _handleNext() {
    // Handle the next button press
    print('Proceeding to the next step');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Hi, Welcome',
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
                  label: 'Email Adress',
                  placeholder: 'Your Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  state: InputFieldState.defaultState,
                ),
                const SizedBox(height: 32),
                InputFieldAtom(
                  label: 'NIC',
                  placeholder: 'NIC',
                  controller: _nicController,
                  keyboardType: TextInputType.text,
                  state: InputFieldState.defaultState,
                ),
                const SizedBox(height: 32),
                InputFieldAtom(
                  label: 'First Name',
                  placeholder: 'First Name',
                  controller: _firstNameController,
                  keyboardType: TextInputType.text,
                  state: InputFieldState.defaultState,
                ),
                const SizedBox(height: 32),
                InputFieldAtom(
                  label: 'Last Name',
                  placeholder: 'Last Name',
                  controller: _lastNameController,
                  keyboardType: TextInputType.text,
                  state: InputFieldState.defaultState,
                ),
                const SizedBox(height: 32),
                InputFieldAtom(
                  label: 'Telephone Number',
                  placeholder: 'Telephone Number',
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  state: InputFieldState.defaultState,
                ),
                const SizedBox(height: 32),
                InputFieldAtom(
                  label: 'Adress',
                  placeholder: 'Address',
                  controller: _addressController,
                  keyboardType: TextInputType.streetAddress,
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
                          label: 'Next',
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
