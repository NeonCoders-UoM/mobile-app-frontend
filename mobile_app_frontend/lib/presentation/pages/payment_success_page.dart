import 'dart:html' as html;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/data/repositories/service_history_repository.dart';
import 'package:mobile_app_frontend/presentation/pages/payment_successful_message_page.dart';

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
          'http://localhost:5039/api/payhere/payment-status?orderId=$orderId'),
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
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'service_history_${widget.vehicleId}.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
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
    if (loading) return const Center(child: CircularProgressIndicator());
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
    return Center(child: Text('Payment status: $status'));
  }
}
