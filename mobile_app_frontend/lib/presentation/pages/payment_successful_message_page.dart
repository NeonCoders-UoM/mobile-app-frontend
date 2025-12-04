import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/successful-message.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';
import 'package:mobile_app_frontend/data/repositories/service_history_repository.dart';
import 'package:mobile_app_frontend/presentation/pages/login_page.dart';
import 'package:mobile_app_frontend/utils/platform/web_utils.dart';
import 'package:mobile_app_frontend/core/services/local_storage.dart';

class PaymentSuccessfulMessagePage extends StatefulWidget {
  final int customerId;
  final int vehicleId;
  final String token;
  final int? appointmentId;
  final double? advancePaymentAmount;

  const PaymentSuccessfulMessagePage({
    Key? key,
    required this.customerId,
    required this.vehicleId,
    required this.token,
    this.appointmentId,
    this.advancePaymentAmount,
  }) : super(key: key);

  @override
  State<PaymentSuccessfulMessagePage> createState() =>
      _PaymentSuccessfulMessagePageState();
}

class _PaymentSuccessfulMessagePageState
    extends State<PaymentSuccessfulMessagePage> {
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    print('🎉 PaymentSuccessfulMessagePage initialized');
    print('🔑 Token: ${widget.token}');
    print('👤 Customer ID: ${widget.customerId}');
    print('🚗 Vehicle ID: ${widget.vehicleId}');

    // Clear payment context since we're now in the success page
    _clearPaymentContext();
  }

  Future<void> _clearPaymentContext() async {
    await LocalStorageService.clearPaymentContext();
    print('🗑️ Payment context cleared in PaymentSuccessfulMessagePage');
  }

  Future<void> _downloadPdf() async {
    setState(() => isDownloading = true);

    try {
      final pdfBytes =
          await ServiceHistoryRepository().downloadServiceHistoryPdf(
        widget.vehicleId,
        token: widget.token,
      );

      if (kIsWeb) {
        WebUtils.downloadFile(
          pdfBytes,
          'service_history_${widget.vehicleId}.pdf',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download not supported on mobile yet')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF downloaded successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      body: Column(
        children: [
          const SizedBox(height: 116),
          const SuccessfulMessage(
              para1: 'Thank you', para2: 'Payment done successfully'),
          const SizedBox(height: 80),
          // Download PDF Button
          CustomButton(
            label: isDownloading
                ? 'Downloading...'
                : 'Download Service History PDF',
            type: ButtonType.secondary,
            size: ButtonSize.large,
            onTap: isDownloading ? null : _downloadPdf,
            customWidth: 360.0,
            customHeight: 56.0,
          ),
          const SizedBox(height: 24),
          // Home Button
          CustomButton(
            label: 'Home',
            type: ButtonType.primary,
            size: ButtonSize.large,
            onTap: () async {
              print('🏠 Home button pressed');
              print('🔑 Token: ${widget.token}');
              print('👤 Customer ID: ${widget.customerId}');

              // Ensure we have valid authentication data
              if (widget.customerId != null &&
                  widget.token != null &&
                  widget.token!.isNotEmpty) {
                print(
                    '✅ Authentication data valid, navigating to VehicleDetailsHomePage');
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VehicleDetailsHomePage(
                          customerId: widget.customerId!,
                          token: widget.token!)),
                  (route) => false, // Remove all previous routes
                );
              } else {
                print('❌ Authentication data missing or invalid');
                // Fallback: navigate to login if authentication data is missing
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Authentication error. Please log in again.'),
                    backgroundColor: Colors.red,
                  ),
                );
                // Navigate to login page
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            customWidth: 360.0,
            customHeight: 56.0,
          ),
        ],
      ),
    );
  }
}
