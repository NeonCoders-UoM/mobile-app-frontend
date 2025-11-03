import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/data/models/emergency_call_center_model.dart';
import 'package:mobile_app_frontend/data/repositories/emergency_call_center_repository.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';

class EmergencyservicePage extends StatefulWidget {
  final String? token;

  const EmergencyservicePage({super.key, this.token});

  @override
  EmergencyservicePageState createState() => EmergencyservicePageState();
}

class EmergencyservicePageState extends State<EmergencyservicePage> {
  final EmergencyCallCenterRepository _repository =
      EmergencyCallCenterRepository();
  List<EmergencyCallCenterModel> _emergencyCallCenters = [];
  bool _isBackendConnected = false;

  @override
  void initState() {
    super.initState();
    _loadEmergencyCallCenters();
    _testBackendConnection();
  }

  Future<void> _testBackendConnection() async {
    final isConnected = await _repository.testConnection(token: widget.token);
    setState(() {
      _isBackendConnected = isConnected;
    });
  }

  Future<void> _loadEmergencyCallCenters() async {
    try {
      final centers =
          await _repository.getAllEmergencyCallCenters(token: widget.token);
      setState(() {
        _emergencyCallCenters = centers;
      });

      print('✅ Loaded ${centers.length} emergency call centers');
    } catch (e) {
      print('❌ Error loading emergency call centers: $e');
      // Use fallback data if backend fails
    }
  }

  void _handleCall(String phoneNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      throw 'Could not launch dialer for $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Emergency Service',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral400,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Service Image
            Container(
              height: 220,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/emergency.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: AppColors.neutral300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_hospital,
                              size: 48,
                              color: AppColors.neutral200,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Emergency Service',
                              style: AppTextStyles.textLgBold.copyWith(
                                color: AppColors.neutral200,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Service Name
            Text(
              _getEmergencyServiceName(),
              style: AppTextStyles.displaySmBold.copyWith(
                color: AppColors.neutral100,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 8),

            // Location with Icon
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 18,
                  color: AppColors.neutral200,
                ),
                const SizedBox(width: 4),
                Text(
                  _getEmergencyServiceLocation(),
                  style: AppTextStyles.textSmRegular.copyWith(
                    color: AppColors.neutral200,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Phone Number with Icon
            Row(
              children: [
                Icon(
                  Icons.phone,
                  size: 18,
                  color: AppColors.neutral200,
                ),
                const SizedBox(width: 4),
                Text(
                  _getEmergencyServicePhone(),
                  style: AppTextStyles.textSmRegular.copyWith(
                    color: AppColors.neutral200,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Guidelines Description
            Text(
              _getEmergencyGuidelines(),
              style: AppTextStyles.textSmRegular.copyWith(
                color: AppColors.neutral100,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 40),

            // Call Button
            Center(
              child: SizedBox(
                width: 220,
                height: 48,
                child: CustomButton(
                  label: 'Call',
                  type: ButtonType.primary,
                  size: ButtonSize.medium,
                  onTap: () => _handleCall(_getEmergencyServicePhone()),
                ),
              ),
            ),

            // Backend Status (for development)
            if (!_isBackendConnected && _emergencyCallCenters.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 24),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.states['ok']!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.states['ok']!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud_done,
                        color: AppColors.states['ok']!, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Connected to emergency services (${_emergencyCallCenters.length} centers available)',
                        style: AppTextStyles.textSmRegular.copyWith(
                          color: AppColors.states['ok']!,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper methods to get emergency service information
  String _getEmergencyServiceName() {
    if (_emergencyCallCenters.isNotEmpty) {
      return _emergencyCallCenters.first.name;
    }
    return 'Adonz Automotive';
  }

  String _getEmergencyServiceLocation() {
    if (_emergencyCallCenters.isNotEmpty) {
      return _emergencyCallCenters.first.address;
    }
    return 'Moratuwa, Sri Lanka';
  }

  String _getEmergencyServicePhone() {
    if (_emergencyCallCenters.isNotEmpty) {
      return _emergencyCallCenters.first.phoneNumber;
    }
    return '+94703681620';
  }

  String _getEmergencyGuidelines() {
    return '''Emergency Vehicle Service Guidelines:

🚗 Before Calling:
• Ensure you are in a safe location
• Have your vehicle registration number ready
• Note your exact location or nearest landmark
• Check if you have spare tire and basic tools

🔧 What We Provide:
• 24/7 emergency roadside assistance
• Professional certified mechanics
• Towing services if repair isn't possible on-site
• Battery jump-start and tire change services

⚡ Emergency Situations:
• Engine breakdown or overheating
• Flat tire or battery issues
• Fuel delivery service
• Lockout assistance

📞 When You Call:
• Stay calm and describe the problem clearly
• Provide your exact location
• Mention if there are any safety concerns
• Our team will arrive within 30-45 minutes

💡 Safety First:
• Turn on hazard lights
• Move to a safe location if possible
• Stay with your vehicle unless unsafe to do so''';
  }
}
