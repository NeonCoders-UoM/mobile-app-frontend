import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/data/repositories/service_history_repository.dart';
import 'package:mobile_app_frontend/presentation/pages/payment_successful_message_page.dart';
import 'package:mobile_app_frontend/utils/platform/web_utils.dart';

class PaymentSuccessPage extends StatefulWidget {
  final int vehicleId;
  final String? token;
  const PaymentSuccessPage({Key? key, required this.vehicleId, this.token})
      : super(key: key);

  @override
  _PaymentSuccessPageState createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  String? status;
  bool loading = true;
  bool downloading = false;

  @override
  void initState() {
    super.initState();
    _checkPaymentStatus();
  }

  Future<void> _checkPaymentStatus() async {
    final uri = Uri.base;
    final orderId = uri.queryParameters['order_id'];
    if (orderId == null) {
      setState(() {
        status = 'No order ID found.';
        loading = false;
      });
      return;
    }
    final response = await http.get(
      Uri.parse(
          'http://192.168.8.161:5039/api/payhere/payment-status?orderId=$orderId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        status = data['status'];
        loading = false;
      });
    } else {
      setState(() {
        status = 'Failed to check payment status.';
        loading = false;
      });
    }
  }

  Future<void> _downloadPdf() async {
    setState(() => downloading = true);
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
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download PDF: $e')),
      );
    } finally {
      setState(() => downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: AppColors.neutral400,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.primary200,
          ),
        ),
      );
    }
    if (status == 'Paid') {
      // Redirect to the enhanced success page
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentSuccessfulMessagePage(
              customerId:
                  1, // TODO: Replace with actual customerId if available
              vehicleId: widget.vehicleId,
              token: widget.token ?? '',
            ),
          ),
        );
      });
      return const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 80,
                color: AppColors.neutral200,
              ),
              const SizedBox(height: 24),
              Text(
                'Payment Status',
                style: AppTextStyles.textLgSemibold.copyWith(
                  color: AppColors.neutral100,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                status ?? 'Unknown',
                style: AppTextStyles.textMdRegular.copyWith(
                  color: AppColors.neutral200,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
