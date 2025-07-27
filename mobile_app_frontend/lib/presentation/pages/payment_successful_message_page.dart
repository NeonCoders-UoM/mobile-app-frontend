import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/successful-message.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';
import 'package:mobile_app_frontend/data/repositories/service_history_repository.dart';

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

  Future<void> _downloadPdf() async {
    setState(() => isDownloading = true);

    try {
      final pdfBytes =
          await ServiceHistoryRepository().downloadServiceHistoryPdf(
        widget.vehicleId,
        token: widget.token,
      );

      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'service_history_${widget.vehicleId}.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);

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
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VehicleDetailsHomePage(
                          customerId: widget.customerId, token: widget.token)));
            },
            customWidth: 360.0,
            customHeight: 56.0,
          ),
        ],
      ),
    );
  }
}
