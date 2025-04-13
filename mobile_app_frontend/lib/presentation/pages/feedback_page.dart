import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/star_rating.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int rating = 0;
  final TextEditingController feedbackController = TextEditingController();

  void _handleSubmit() {
    String feedback = feedbackController.text;
    debugPrint("Rating: $rating");
    debugPrint("Feedback: $feedback");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Thank you for your feedback!")),
    );

    // Reset form
    setState(() {
      rating = 0;
      feedbackController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: AppBar(title: const Text("Your Service is Complete! 🚗✅")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "Your vehicle service at Ranjan Motors is now complete. Thank you for choosing us!",
                  style: AppTextStyles.displayMdRegular
                      .copyWith(color: AppColors.neutral150)),
              const SizedBox(height: 16),
              _buildInfoRow("Service Center:", "Janaka Motors"),
              _buildInfoRow("Date:", "2025-02-26"),
              _buildInfoRow("Total Amount Paid:", "Rs. 15,000"),
              _buildInfoRow(
                  "List of Services Performed:", "Oil Change, Body Check"),
              const SizedBox(height: 16),
              Text(
                  "We hope you had a great experience! Your feedback helps us improve our service.",
                  style: AppTextStyles.displayMdRegular
                      .copyWith(color: AppColors.neutral150)),
              const SizedBox(height: 24),
              Text("Rate Your Experience",
                  style: AppTextStyles.displayMdRegular
                      .copyWith(color: AppColors.neutral100)),
              const SizedBox(height: 8),
              StarRating(
                onRatingChanged: (value) {
                  setState(() {
                    rating = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              Text("Tell us more about your experience...",
                  style: AppTextStyles.displayMdRegular
                      .copyWith(color: AppColors.neutral150)),
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
                    contentPadding: EdgeInsets.all(12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Submit Your Feedback",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.displayMdRegular
              .copyWith(color: AppColors.neutral150),
          children: [
            TextSpan(
              text: "$title ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
