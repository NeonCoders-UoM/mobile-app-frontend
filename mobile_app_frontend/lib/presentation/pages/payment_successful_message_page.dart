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
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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
        // Mobile platform (Android/iOS)
        print('📱 Mobile platform detected - saving to device');

        // Request storage permission
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          print('📋 Requesting storage permission...');
          status = await Permission.storage.request();
        }

        // For Android 13+ (API 33+), use photos permission instead
        if (Platform.isAndroid) {
          var photosStatus = await Permission.photos.status;
          if (!photosStatus.isGranted) {
            print('📋 Requesting photos permission (Android 13+)...');
            photosStatus = await Permission.photos.request();
          }
        }

        // Get the downloads directory
        Directory? directory;
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            directory = await getExternalStorageDirectory();
          }
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory == null) {
          throw Exception('Could not access storage directory');
        }

        // Create file path
        final fileName =
            'service_history_${widget.vehicleId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final filePath = '${directory.path}/$fileName';

        print('💾 Saving to: $filePath');

        // Write file
        final file = File(filePath);
        await file.writeAsBytes(pdfBytes);

        print('✅ File saved successfully');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF saved to Downloads/$fileName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
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
      } else if (e.toString().contains('storage') ||
          e.toString().contains('permission')) {
        errorMessage =
            'Storage permission denied. Please enable storage access in settings.';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SuccessfulMessage(
                  para1: 'Thank you', para2: 'Payment done successfully'),
              const SizedBox(height: 60),
              // Download PDF Button
              CustomButton(
                label: isDownloading
                    ? 'Downloading...'
                    : 'Download Service History PDF',
                type: ButtonType.secondary,
                size: ButtonSize.large,
                customWidth: double.infinity,
                onTap: isDownloading ? null : _downloadPdf,
              ),
              const SizedBox(height: 16),
              // Home Button
              CustomButton(
                label: 'Home',
                type: ButtonType.primary,
                size: ButtonSize.large,
                customWidth: double.infinity,
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
                        content:
                            Text('Authentication error. Please log in again.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    // Navigate to login page
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
