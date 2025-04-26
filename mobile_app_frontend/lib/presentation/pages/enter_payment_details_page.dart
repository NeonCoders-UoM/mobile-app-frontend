import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/payment_details_form.dart';

class EnterPaymentDetailsPage extends StatelessWidget {
  const EnterPaymentDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardHolderController = TextEditingController();
    final cardNumberController = TextEditingController();
    final labelController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.neutral500, // Dark background
      appBar: AppBar(
        backgroundColor: AppColors.neutral500,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Payment Details",
          style: AppTextStyles.textMdSemibold
              .copyWith(color: AppColors.neutral100),
        ),
        centerTitle: true, // Center the title to match the design
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Added to handle overflow on smaller screens
          child: PaymentDetailsForm(
            cardHolderController: cardHolderController,
            cardNumberController: cardNumberController,
            labelController: labelController,
            onExpMonthChanged: (value) {
              print("Selected Exp Month: $value");
            },
            onExpYearChanged: (value) {
              print("Selected Exp Year: $value");
            },
            onPayNowTap: () {
              print("Pay Now tapped with details: ");
              print("Card Holder: ${cardHolderController.text}");
              print("Card Number: ${cardNumberController.text}");
              print("Label: ${labelController.text}");
              // Add payment processing logic here
            },
          ),
        ),
      ),
    );
  }
}
