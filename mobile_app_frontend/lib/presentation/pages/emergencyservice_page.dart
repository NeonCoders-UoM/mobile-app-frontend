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
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/emergency.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary300.withOpacity(0.3),
                            AppColors.neutral300,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
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
            const SizedBox(height: 28),

            // Service Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.neutral300.withOpacity(0.4),
                    AppColors.neutral300.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.neutral200.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Name
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary200,
                              AppColors.primary300,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.primary300.withOpacity(0.4),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.local_hospital,
                          color: AppColors.neutral100,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getEmergencyServiceName(),
                          style: AppTextStyles.displaySmBold.copyWith(
                            color: AppColors.neutral100,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Location
                  _buildInfoRow(
                    Icons.location_on,
                    _getEmergencyServiceLocation(),
                  ),
                  const SizedBox(height: 12),

                  // Phone Number
                  _buildInfoRow(
                    Icons.phone,
                    _getEmergencyServicePhone(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Guidelines Section
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.neutral300.withOpacity(0.25),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.neutral200.withOpacity(0.25),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.neutral100,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Emergency Guidelines',
                        style: AppTextStyles.textLgBold.copyWith(
                          color: AppColors.neutral100,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getEmergencyGuidelines(),
                    style: AppTextStyles.textSmRegular.copyWith(
                      color: AppColors.neutral100,
                      height: 1.7,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Call Button
            Center(
              child: Container(
                width: 260,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary300.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: CustomButton(
                  label: 'Call Emergency Service',
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
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.states['ok']!.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.states['ok']!.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud_done,
                        color: AppColors.states['ok']!, size: 22),
                    const SizedBox(width: 10),
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.neutral300.withOpacity(0.4),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.neutral200.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.neutral100,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.neutral100,
              fontSize: 14,
            ),
          ),
        ),
      ],
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

🔧 What We Provide:
• 24/7 emergency roadside assistance
• Professional certified mechanics
• Towing services if repair isn't possible on-site
• Mention if there are any safety concerns
• Our team will arrive within 30-45 minutes
''';
  }
}
