import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/data/models/service_history_model.dart';
import 'package:mobile_app_frontend/data/repositories/service_history_repository.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/backend_connection_widget.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/service_history_card.dart';
import 'package:mobile_app_frontend/presentation/pages/add_unverified_service_page.dart';
import 'package:mobile_app_frontend/presentation/pages/payhere_payment_page.dart';
import 'package:mobile_app_frontend/presentation/pages/payment_success_page.dart';
import 'package:mobile_app_frontend/utils/platform/web_utils.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'pdf_view_page.dart';
import 'edit_service_history_page.dart';
import 'package:mobile_app_frontend/presentation/pages/pdf_view_page.dart';
import 'dart:io';

class ServiceHistoryPage extends StatefulWidget {
  final int vehicleId;
  final String vehicleName;
  final String vehicleRegistration;
  final String? token;
  final int? customerId;

  const ServiceHistoryPage({
    Key? key,
    this.vehicleId = 1,
    this.vehicleName = 'Mustang 1977',
    this.vehicleRegistration = 'AB89B395',
    this.token,
    this.customerId,
  }) : super(key: key);

  @override
  _ServiceHistoryPageState createState() => _ServiceHistoryPageState();
}

class _ServiceHistoryPageState extends State<ServiceHistoryPage> {
  final ServiceHistoryRepository _serviceHistoryRepository = ServiceHistoryRepository();
  List<ServiceHistoryModel> _serviceHistory = [];
  bool _isLoading = true;

  // Payment status logic
  String? _paymentStatus; // 'Paid', 'Pending', etc.
  String? _orderId;
  bool get _hasPaid => _paymentStatus == 'Paid';

  @override
  void initState() {
    super.initState();
    // Check for order_id in URL (web)
    if (kIsWeb) {
      final uri = Uri.base;
      final orderIdFromUrl = uri.queryParameters['order_id'];
      if (orderIdFromUrl != null && orderIdFromUrl.isNotEmpty) {
        WebUtils.setLocalStorage(
          'service_history_order_id_${widget.vehicleId}',
          orderIdFromUrl,
        );
        _orderId = orderIdFromUrl;
      }
    }
    _loadServiceHistory();
    _checkPaymentStatus();
  }

  Future<void> _loadServiceHistory() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final serviceHistory = await _serviceHistoryRepository.getServiceHistory(
        widget.vehicleId,
        token: widget.token,
      );

      setState(() {
        _serviceHistory = serviceHistory;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading service history: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkPaymentStatus() async {
    // Try to get orderId from local storage (web) or state
    String? orderId = _orderId;
    if (orderId == null && kIsWeb) {
      orderId = WebUtils.getLocalStorage(
        'service_history_order_id_${widget.vehicleId}',
      );
    }
    if (orderId == null) {
      setState(() {
        _paymentStatus = null;
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
        _paymentStatus = data['status'];
        _orderId = orderId;
      });
    } else {
      setState(() {
        _paymentStatus = null;
      });
    }
  }

  Future<void> _navigateToAddService() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddUnverifiedServicePage(
          vehicleId: widget.vehicleId,
          vehicleName: widget.vehicleName,
          vehicleRegistration: widget.vehicleRegistration,
          token: widget.token,
        ),
      ),
    );

    // Refresh the service history if a service was added
    if (result == true) {
      _loadServiceHistory();
    }
  }

  Future<void> _downloadServiceHistoryPdf() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final pdfBytes = await _serviceHistoryRepository
          .downloadServiceHistoryPdf(widget.vehicleId, token: widget.token);

      if (kIsWeb) {
        WebUtils.downloadFile(
          pdfBytes,
          'service_history_${widget.vehicleId}.pdf',
        );
      } else {
        // Implement mobile file saving / opening if needed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('PDF downloaded (handle file saving on mobile).')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download PDF: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// This function triggers the payment flow and then downloads PDF after success.
  Future<void> _startPaymentFlow() async {
    if (kIsWeb) {
      // 1. Call backend to create PayHere session
      final response = await http.post(
        Uri.parse('http://192.168.8.161:5039/api/payhere/create-session'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'vehicleId': widget.vehicleId,
          'userEmail': 'testuser@example.com', // TODO: use actual user email
          'userName': 'Test User', // TODO: use actual user name
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final payHereUrl = data['payHereUrl'];
        final paymentFields = data['paymentFields'] as Map<String, dynamic>;
        final orderId = data['orderId'];
        // Store orderId for later payment status checks
        WebUtils.setLocalStorage(
          'service_history_order_id_${widget.vehicleId}',
          orderId,
        );
        setState(() {
          _orderId = orderId;
        });
        // 2. Create and submit a form to PayHere
        final fields = Map<String, String>.fromEntries(
          paymentFields.entries.map((e) => MapEntry(e.key, e.value.toString())),
        );
        WebUtils.submitForm(payHereUrl, fields);
        // 3. After payment, user will be redirected to /payment-success?order_id=...
        //    You need to handle this in your frontend router/page.
        // Optionally, you can navigate to PaymentSuccessPage manually if you want to support SPA routing.
        // Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentSuccessPage(vehicleId: widget.vehicleId)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to initiate payment: ${response.body}')),
        );
      }
      return;
    }
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PayHerePaymentPage(
          vehicleId: widget.vehicleId,
          customerEmail:
              "testuser@example.com", // TODO: replace with actual user email
          customerName: "Test User", // TODO: replace with actual user name
          customerId: widget.customerId,
          token: widget.token,
        ),
      ),
    );

    if (result == true) {
      // Payment successful - download the PDF
      await _downloadServiceHistoryPdf();
      // After download, update payment status and button
      await _checkPaymentStatus();
    } else if (result == false) {
      // Payment failed or cancelled - show message or handle accordingly
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment cancelled or failed.')),
      );
    }
    // If result is null, do nothing (user backed out)
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Widget _buildServiceRecord(ServiceHistoryModel service) {
    final description = '${service.serviceProvider}\n${service.status}';
    return ServiceHistoryCard(
      title: service.serviceTitle,
      description: description,
      date: _formatDate(service.serviceDate),
      isVerified: service.isVerified,
    );
  }

  Widget _buildServiceHistoryList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_serviceHistory.isEmpty) {
      return const Center(child: Text('No service history records found.'));
    }
    return Expanded(
      child: ListView.builder(
        itemCount: _serviceHistory.length,
        itemBuilder: (context, index) {
          final service = _serviceHistory[index];
          return ServiceHistoryCard(
            title: service.serviceTitle,
            description: service.serviceDescription,
            date: _formatDate(service.serviceDate),
            isVerified: service.isVerified,
            onEdit: service.isVerified
                ? null
                : () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditServiceHistoryPage(
                          service: service,
                          vehicleName: widget.vehicleName,
                          vehicleRegistration: widget.vehicleRegistration,
                          token: widget.token,
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadServiceHistory();
                    }
                  },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: const CustomAppBar(title: 'Service History'),
      body: Column(
        children: [
          // Add Service Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToAddService,
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  'Add Service Record',
                  style: AppTextStyles.textMdSemibold.copyWith(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary200,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ),
          // Pay/View PDF Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : _hasPaid
                        ? _downloadServiceHistoryPdf
                        : _startPaymentFlow,
                icon: Icon(_hasPaid ? Icons.visibility : Icons.lock_open,
                    color: Colors.white),

//                     : () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => PdfViewPage(
//                               vehicleId: widget.vehicleId,
//                               token: widget.token,
//                             ),
//                           ),
//                         );
//                       },
//                 icon: const Icon(Icons.picture_as_pdf, color: Colors.white),

                label: Text(
                  _hasPaid ? 'View Service History PDF' : 'Pay & Download PDF',
                  style: AppTextStyles.textMdSemibold.copyWith(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary200,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ),
          // Service History List
          _buildServiceHistoryList(),
        ],
      ),
    );
  }
}