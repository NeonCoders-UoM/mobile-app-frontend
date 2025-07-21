import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/payment_method_option.dart';
import 'package:mobile_app_frontend/presentation/pages/enter_payment_details_page.dart';

class SelectPaymentMethodPage extends StatelessWidget {
  final int customerId;
  final int vehicleId;
  final String token;

  const SelectPaymentMethodPage({
    Key? key,
    required this.customerId,
    required this.vehicleId,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral500, // Dark background using AppColors
      appBar: AppBar(
        backgroundColor: AppColors.neutral500, // Match the background
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "PAYMENT DETAILS",
          style: AppTextStyles.textMdSemibold.copyWith(
              color: AppColors.neutral100), // Use AppTextStyles and AppColors
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SELECT A PAYMENT METHOD",
              style: AppTextStyles.textMdSemibold.copyWith(
                  color:
                      AppColors.neutral100), // Use AppTextStyles and AppColors
            ),
            const SizedBox(height: 16.0),
            PaymentMethodOption(
              label: "Visa",
              iconPath: 'assets/icons/visa.png', // Add your asset path
              onTap: () {
                // Navigate to the Payment Details page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnterPaymentDetailsPage(
                      customerId: customerId,
                      vehicleId: vehicleId,
                      token: token,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            PaymentMethodOption(
              label: "MasterCard",
              iconPath: 'assets/icons/mastercard.png', // Add your asset path
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnterPaymentDetailsPage(
                      customerId: customerId,
                      vehicleId: vehicleId,
                      token: token,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            PaymentMethodOption(
              label: "American Express",
              iconPath: 'assets/icons/amex.png', // Add your asset path
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnterPaymentDetailsPage(
                      customerId: customerId,
                      vehicleId: vehicleId,
                      token: token,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            PaymentMethodOption(
              label: "Visa",
              iconPath: 'assets/icons/paypal.png', // Add your asset path
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EnterPaymentDetailsPage(
                      customerId: customerId,
                      vehicleId: vehicleId,
                      token: token,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
