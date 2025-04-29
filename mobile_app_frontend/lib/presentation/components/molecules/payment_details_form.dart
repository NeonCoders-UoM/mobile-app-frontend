import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/custom_dropdown_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';

class PaymentDetailsForm extends StatelessWidget {
  final TextEditingController cardHolderController;
  final TextEditingController cardNumberController;
  final TextEditingController labelController;
  final ValueChanged<String> onExpMonthChanged;
  final ValueChanged<String> onExpYearChanged;
  final VoidCallback onPayNowTap;

  const PaymentDetailsForm({
    Key? key,
    required this.cardHolderController,
    required this.cardNumberController,
    required this.labelController,
    required this.onExpMonthChanged,
    required this.onExpYearChanged,
    required this.onPayNowTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section (Centered)
        Center(
          child: Column(
            children: [
              // "ENTER YOUR PAYMENT DETAILS" (TERMS removed)
              Text(
                "ENTER YOUR PAYMENT DETAILS",
                style: AppTextStyles.textMdSemibold
                    .copyWith(color: AppColors.neutral100),
              ),
              const SizedBox(height: 4.0),
              // "By continuing you agree to our TERMS" text
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "By continuing you agree to our ",
                      style: AppTextStyles.textXsmRegular
                          .copyWith(color: AppColors.neutral300),
                    ),
                    TextSpan(
                      text: "TERMS",
                      style: AppTextStyles.textXsmRegular.copyWith(
                        color: AppColors.primary200,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),
        // Payment Method Icons with Checkmark (Centered)
        Center(
          child: Stack(
            clipBehavior: Clip.none, // Allow overflow for the checkmark
            children: [
              Row(
                mainAxisSize:
                    MainAxisSize.min, // Shrink the row to fit its content
                children: [
                  Image.asset(
                    'assets/icons/visa.png', // Add your asset path
                    width: 48.0,
                    height: 48.0,
                    fit: BoxFit.contain, // Ensure consistent scaling
                  ),
                  const SizedBox(width: 16.0),
                  Image.asset(
                    'assets/icons/mastercard.png', // Add your asset path
                    width: 48.0,
                    height: 48.0,
                    fit: BoxFit.contain, // Ensure consistent scaling
                  ),
                  const SizedBox(width: 16.0),
                  Image.asset(
                    'assets/icons/amex.png', // Add your asset path
                    width: 48.0,
                    height: 48.0,
                    fit: BoxFit.contain, // Ensure consistent scaling
                  ),
                  const SizedBox(width: 16.0),
                  Image.asset(
                    'assets/icons/paypal.png', // Add your asset path
                    width: 48.0,
                    height: 48.0,
                    fit: BoxFit.contain, // Ensure consistent scaling
                  ),
                ],
              ),
              // Green Checkmark at the bottom-right of the last icon (PayPal)
              Positioned(
                right:
                    -12.0, // Adjust to overlap the right edge of the PayPal icon
                bottom:
                    -12.0, // Adjust to overlap the bottom edge of the PayPal icon
                child: Container(
                  width: 24.0,
                  height: 24.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.states['ok'] ?? Colors.green,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24.0),
        // Card Holder Name
        InputFieldAtom(
          state: InputFieldState.defaultState,
          label: "CARD HOLDER NAME",
          placeholder: "Card Holder Name",
          controller: cardHolderController,
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: 16.0),
        // Card Number
        InputFieldAtom(
          state: InputFieldState.defaultState,
          label: "CARD NUMBER",
          placeholder: "Card Number",
          controller: cardNumberController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16.0),
        // Exp Month and Exp Year (Side by Side)
        Row(
          children: [
            Expanded(
              child: CustomDropdownField(
                label: "EXP MONTH",
                hintText: "Exp Month",
                items: List.generate(
                    12, (index) => (index + 1).toString().padLeft(2, '0')),
                onChanged: onExpMonthChanged,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: CustomDropdownField(
                label: "EXP YEAR",
                hintText: "Exp Year",
                items: List.generate(10, (index) => (2025 + index).toString()),
                onChanged: onExpYearChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        // Label
        Row(
          children: [
            Expanded(
              child: InputFieldAtom(
                state: InputFieldState.defaultState,
                label: "LABEL",
                placeholder: "Placeholder",
                controller: labelController,
                keyboardType: TextInputType.text,
              ),
            ),
            const SizedBox(width: 16.0),
            Text(
              "3 or 4 digits usually found on the signature strip",
              style: AppTextStyles.textXsmRegular
                  .copyWith(color: AppColors.neutral300),
            ),
          ],
        ),
        const SizedBox(height: 24.0),
        // Pay Now Button
        CustomButton(
          label: "PAY NOW",
          type: ButtonType.primary,
          size: ButtonSize.large,
          onTap: onPayNowTap,
          customWidth: double.infinity, // Full width
        ),
      ],
    );
  }
}
