import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/star_rating.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/cost_estimate_description.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int rating = 0;
  final TextEditingController feedbackController = TextEditingController();

  void _handleSubmitFeedback() {
    final feedback = feedbackController.text;
    debugPrint("Rating: $rating");
    debugPrint("Feedback: $feedback");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Thank you for your feedback!")),
    );

    setState(() {
      rating = 0;
      feedbackController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Cost Estimation',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral400,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Service is Complete! 🚗✅",
              style: AppTextStyles.textLgSemibold.copyWith(
                color: AppColors.neutral100,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your vehicle service at Janaka Motors is now complete. Thank you for choosing us!",
              style: AppTextStyles.textMdRegular.copyWith(
                color: AppColors.neutral150,
              ),
            ),
            const SizedBox(height: 12),
            const CostEstimateDescription(
              servicecenterName: "Janaka Motors",
              vehicleRegNo: "CAX-4589",
              appointmentDate: "2025-02-26",
              loyaltyPoints: "120",
              serviceCenterId: "SC123456",
              address: "123 Main St, Colombo",
              distance: "5.2 km",
              services: ["Oil Change", "Body Check"],
            ),
            const SizedBox(height: 20),
            Text(
              "We hope you had a great experience! Your feedback helps us improve our service.",
              style: AppTextStyles.textMdRegular.copyWith(
                color: AppColors.neutral150,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Rate Your Experience",
              style: AppTextStyles.textLgMedium.copyWith(
                color: AppColors.neutral100,
              ),
            ),
            const SizedBox(height: 8),
            StarRating(
              onRatingChanged: (value) {
                setState(() {
                  rating = value;
                });
              },
            ),
            const SizedBox(height: 32),
            Text(
              "Tell us more about your experience...",
              style: AppTextStyles.textMdRegular.copyWith(
                color: AppColors.neutral150,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.neutral200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: feedbackController,
                maxLines: 5,
                style: TextStyle(color: AppColors.neutral100),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(8),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: 'Submit Your Feedback',
                type: ButtonType.primary,
                size: ButtonSize.medium,
                onTap: _handleSubmitFeedback,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
