import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/services/vehicle_transfer_service.dart';

class InitiateTransferPage extends StatefulWidget {
  final int vehicleId;
  final int customerId;
  final String vehicleName;
  final String registrationNumber;

  const InitiateTransferPage({
    super.key,
    required this.vehicleId,
    required this.customerId,
    required this.vehicleName,
    required this.registrationNumber,
  });

  @override
  State<InitiateTransferPage> createState() => _InitiateTransferPageState();
}

class _InitiateTransferPageState extends State<InitiateTransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _mileageController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  final _transferService = VehicleTransferService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _mileageController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _initiateTransfer() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter buyer\'s email'),
          backgroundColor: AppColors.states['error'],
        ),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: AppColors.states['error'],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _transferService.initiateTransfer(
      vehicleId: widget.vehicleId,
      buyerEmail: _emailController.text.trim(),
      sellerId: widget.customerId,
      mileageAtTransfer: _mileageController.text.isNotEmpty ? int.tryParse(_mileageController.text) : null,
      salePrice: _priceController.text.isNotEmpty ? double.tryParse(_priceController.text) : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.states['ok'],
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.states['error'],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Transfer Vehicle',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral400,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.neutral300.withOpacity(0.6),
                        AppColors.neutral300.withOpacity(0.35),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.neutral200.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicle Details',
                        style: AppTextStyles.textLgSemibold.copyWith(
                          color: AppColors.neutral100,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Vehicle', widget.vehicleName),
                      const SizedBox(height: 8),
                      _buildInfoRow('Registration', widget.registrationNumber),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Transfer Form
                Text(
                  'Transfer Details',
                  style: AppTextStyles.textLgSemibold.copyWith(
                    color: AppColors.neutral100,
                  ),
                ),
                const SizedBox(height: 20),

                // Buyer Email
                InputFieldAtom(
                  label: 'Buyer Email',
                  placeholder: 'Enter buyer\'s registered email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  state: InputFieldState.defaultState,
                  leadingIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 24),

                // Current Mileage
                InputFieldAtom(
                  label: 'Current Mileage (Optional)',
                  placeholder: 'Enter current mileage in km',
                  controller: _mileageController,
                  keyboardType: TextInputType.number,
                  state: InputFieldState.defaultState,
                  leadingIcon: Icons.speed_outlined,
                ),
                const SizedBox(height: 24),

                // Sale Price
                InputFieldAtom(
                  label: 'Sale Price (Optional)',
                  placeholder: 'Enter sale price in LKR',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  state: InputFieldState.defaultState,
                  leadingIcon: Icons.attach_money_outlined,
                ),
                const SizedBox(height: 24),

                // Notes
                Text(
                  'Additional Notes (Optional)',
                  style: AppTextStyles.textSmRegular.copyWith(
                    color: AppColors.neutral100,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  maxLength: 500,
                  style: AppTextStyles.textSmRegular.copyWith(
                    color: AppColors.neutral100,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    hintText: 'Add any additional notes about the transfer',
                    hintStyle: AppTextStyles.textSmSemibold.copyWith(
                      color: AppColors.neutral200,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.neutral200),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.neutral200),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary200),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary300.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary200.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary100,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'The buyer will have 7 days to accept the transfer. You can cancel the transfer anytime before acceptance.',
                          style: AppTextStyles.textSmRegular.copyWith(
                            color: AppColors.neutral100,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: _isLoading ? 'Initiating...' : 'Initiate Transfer',
                    onTap: _isLoading ? null : _initiateTransfer,
                    type: ButtonType.primary,
                    size: ButtonSize.large,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: AppTextStyles.textSmRegular.copyWith(
            color: AppColors.neutral200,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.textSmSemibold.copyWith(
              color: AppColors.neutral100,
            ),
          ),
        ),
      ],
    );
  }
}
