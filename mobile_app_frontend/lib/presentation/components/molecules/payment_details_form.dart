import 'package:flutter/material.dart';
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
        // Header with Terms Link
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "ENTER YOUR PAYMENT DETAILS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Handle terms link tap (e.g., open terms page)
              },
              child: const Text(
                "TERMS",
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 12.0,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
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
            const Text(
              "3 or 4 digits usually found on the signature strip",
              style: TextStyle(color: Colors.grey, fontSize: 12.0),
            ),
          ],
        ),
        const SizedBox(height: 24.0),
        // Pay Now Button
        Center(
          child: CustomButton(
            label: "PAY NOW",
            type: ButtonType.primary,
            size: ButtonSize.large,
            onTap: onPayNowTap,
            customWidth: double.infinity, // Full width
          ),
        ),
      ],
    );
  }
}
