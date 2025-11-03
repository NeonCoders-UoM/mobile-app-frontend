import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/services/auth_service.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetails_page.dart';

class PersonaldetailsPage extends StatefulWidget {
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  const PersonaldetailsPage({
    Key? key,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<PersonaldetailsPage> createState() => _PersonaldetailsPageState();
}

class _PersonaldetailsPageState extends State<PersonaldetailsPage> {
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final _authService = AuthService();

  bool _isSaving = false;

  void _handleNext() async {
    try {
      setState(() => _isSaving = true);

      final customerId = await _authService.updateCustomer(
        email: widget.email,
        firstName: widget.firstName,
        lastName: widget.lastName,
        phoneNumber: widget.phoneNumber,
        nic: _nicController.text.trim(),
        address: _addressController.text.trim(),
      );

      // ✅ After successful update, navigate to RegisterVehicle page:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VehicledetailsPage(customerId: customerId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: $e")),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Complete Your Details',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral400,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: SingleChildScrollView(
            child: Column(
              children: [
                InputFieldAtom(
                  label: 'First Name',
                  placeholder: 'First Name',
                  controller: TextEditingController(text: widget.firstName),
                  state: InputFieldState.defaultState,
                  enabled: false,
                ),
                const SizedBox(height: 20),
                InputFieldAtom(
                  label: 'Last Name',
                  placeholder: 'Last Name',
                  controller: TextEditingController(text: widget.lastName),
                  state: InputFieldState.defaultState,
                  enabled: false,
                ),
                const SizedBox(height: 20),
                InputFieldAtom(
                  label: 'Email',
                  placeholder: 'Email',
                  controller: TextEditingController(text: widget.email),
                  state: InputFieldState.defaultState,
                  enabled: false,
                ),
                const SizedBox(height: 20),
                InputFieldAtom(
                  label: 'Phone Number',
                  placeholder: 'Phone Number',
                  controller: TextEditingController(text: widget.phoneNumber),
                  state: InputFieldState.defaultState,
                  enabled: false,
                ),
                const SizedBox(height: 32),
                InputFieldAtom(
                  label: 'NIC',
                  placeholder: 'NIC',
                  controller: _nicController,
                  state: InputFieldState.defaultState,
                ),
                const SizedBox(height: 32),
                InputFieldAtom(
                  label: 'Address',
                  placeholder: 'Address',
                  controller: _addressController,
                  state: InputFieldState.defaultState,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: _isSaving ? 'Saving...' : 'Next',
                    type: ButtonType.primary,
                    size: ButtonSize.medium,
                    onTap: _handleNext,
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
