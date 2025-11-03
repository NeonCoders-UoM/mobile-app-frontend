import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/services/auth_service.dart';

class EditPersonaldetailsPage extends StatefulWidget {
  final int customerId;
  final String token;

  const EditPersonaldetailsPage({
    Key? key,
    required this.customerId,
    required this.token,
  }) : super(key: key);

  @override
  State<EditPersonaldetailsPage> createState() =>
      _EditPersonaldetailsPageState();
}

class _EditPersonaldetailsPageState extends State<EditPersonaldetailsPage> {
  final _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    try {
      final customerData = await _authService.getCustomerDetails(
        customerId: widget.customerId,
        token: widget.token,
      );

      if (customerData != null) {
        setState(() {
          _emailController.text = customerData['email'] ?? '';
          _nicController.text = customerData['nic'] ?? '';
          _firstNameController.text = customerData['firstName'] ?? '';
          _lastNameController.text = customerData['lastName'] ?? '';
          _telephoneController.text = customerData['phoneNumber'] ?? '';
          _addressController.text = customerData['address'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        // Show info message instead of error since this is expected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Please enter your personal details. Pre-loading is not available yet.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your personal details manually.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nicController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _telephoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handleUpdate() async {
    // Validate that all required fields are filled
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _telephoneController.text.trim().isEmpty ||
        _nicController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final success = await _authService.updateCustomerProfile(
        customerId: widget.customerId,
        token: widget.token,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _telephoneController.text.trim(),
        nic: _nicController.text.trim(),
        address: _addressController.text.trim(),
      );

      // Hide loading indicator
      Navigator.of(context).pop();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personal details updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to the previous screen with success result
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Failed to update personal details. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Hide loading indicator
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Edit Personal Details',
          showTitle: true,
          onBackPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: AppColors.neutral400,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Personal Details',
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
                          label: 'Update',
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
