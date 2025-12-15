import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
      print('📥 Starting PDF download...');
      print('🆔 Vehicle ID: ${widget.vehicleId}');
      print(
          '🔑 Token: ${widget.token.substring(0, widget.token.length > 20 ? 20 : widget.token.length)}...');

      final pdfBytes =
          await ServiceHistoryRepository().downloadServiceHistoryPdf(
        widget.vehicleId,
        token: widget.token,
      );

      print('✅ PDF bytes received: ${pdfBytes.length}');

      if (kIsWeb) {
        print('🌐 Initiating web download...');
        WebUtils.downloadFile(
          pdfBytes,
          'service_history_${widget.vehicleId}.pdf',
        );
        print('✅ Web download initiated');
      } else {
        print('📱 Mobile platform detected, requesting storage permission...');

        // Request storage permission
        PermissionStatus status;
        if (Platform.isAndroid) {
          // For Android 13+ (API 33+), use photos permission
          // For older Android versions, use storage permission
          final androidInfo = await Permission.storage.request();
          status = androidInfo;

          if (status.isDenied) {
            // Try photos permission for Android 13+
            status = await Permission.photos.request();
          }
        } else {
          // For iOS, request photos permission
          status = await Permission.photos.request();
        }

        if (!status.isGranted) {
          print('❌ Storage permission denied');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                    'Storage permission is required to download PDF'),
                backgroundColor: Colors.orange,
                action: SnackBarAction(
                  label: 'Settings',
                  textColor: Colors.white,
                  onPressed: () => openAppSettings(),
                ),
              ),
            );
          }
          return;
        }

        print('✅ Storage permission granted');

        // Get the directory to save the file
        Directory? directory;
        if (Platform.isAndroid) {
          // Save to Downloads folder on Android
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        } else {
          // Save to Documents folder on iOS
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory == null) {
          throw Exception('Could not access storage directory');
        }

        final fileName =
            'service_history_${widget.vehicleId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final filePath = '${directory.path}/$fileName';

        print('💾 Saving PDF to: $filePath');
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes);
        print('✅ PDF saved successfully');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'PDF saved to ${Platform.isAndroid ? "Downloads" : "Documents"}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF downloaded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ PDF Download Error: $e');
      print('❌ Error type: ${e.runtimeType}');

      String errorMessage = 'Failed to download PDF';
      if (e.toString().contains('Payment required')) {
        errorMessage = 'Payment verification failed. Please contact support.';
      } else if (e.toString().contains('Authentication failed')) {
        errorMessage = 'Session expired. Please log in again.';
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'Network connection error. Please check your internet.';
      } else if (e.toString().contains('Exception:')) {
        // Extract the actual error message
        errorMessage = e.toString().replaceAll('Exception:', '').trim();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _downloadPdf,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isDownloading = false);
      }
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
