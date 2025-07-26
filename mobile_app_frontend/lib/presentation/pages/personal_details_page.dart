import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/services/auth_service.dart';
import 'package:mobile_app_frontend/presentation/pages/profile_options_page.dart';
import 'package:mobile_app_frontend/data/repositories/loyalty_points_repository.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/loyalty_points_card.dart';
import 'package:mobile_app_frontend/presentation/pages/loyalty_points_details_page.dart';

class PersonalDetailsPage extends StatefulWidget {
  final int customerId;
  final String token;

  const PersonalDetailsPage({
    Key? key,
    required this.customerId,
    required this.token,
  }) : super(key: key);

  @override
  State<PersonalDetailsPage> createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  final _authService = AuthService();
  final _loyaltyPointsRepository = LoyaltyPointsRepository();
  Map<String, dynamic>? _customerData;
  int _totalLoyaltyPoints = 0;
  bool _isLoading = true;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _refreshCustomerData() async {
    setState(() {
      _isLoading = true;
      _isInitialLoad = false; // This is a refresh, not initial load
    });
    await _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    try {
      // Load customer data and loyalty points in parallel
      final customerDataFuture = _authService.getCustomerDetails(
        customerId: widget.customerId,
        token: widget.token,
      );

      final loyaltyPointsFuture =
          _loyaltyPointsRepository.getTotalCustomerLoyaltyPoints(
        widget.customerId,
        widget.token,
      );

      // Wait for both to complete
      final results = await Future.wait([
        customerDataFuture,
        loyaltyPointsFuture,
      ]);

      final customerData = results[0] as Map<String, dynamic>?;
      final totalLoyaltyPoints = results[1] as int;

      if (customerData != null) {
        setState(() {
          _customerData = customerData;
          _totalLoyaltyPoints = totalLoyaltyPoints;
          _isLoading = false;
        });
        // Only show success message if this is a refresh, not initial load
        if (!_isInitialLoad) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Personal details refreshed successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        // Mark as no longer initial load
        _isInitialLoad = false;
      } else {
        setState(() {
          _customerData = {
            'firstName': 'Not Available',
            'lastName': 'Not Available',
            'email': 'Not Available',
            'phoneNumber': 'Not Available',
            'nic': 'Not Available',
            'address': 'Not Available',
            'loyaltyPoints': 0,
          };
          _totalLoyaltyPoints = totalLoyaltyPoints;
          _isLoading = false;
        });
        // Mark as no longer initial load
        _isInitialLoad = false;
        // Show info message instead of error since this might be expected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to load personal details from server.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _customerData = {
          'firstName': 'Error Loading',
          'lastName': 'Error Loading',
          'email': 'Error Loading',
          'phoneNumber': 'Error Loading',
          'nic': 'Error Loading',
          'address': 'Error Loading',
          'loyaltyPoints': 0,
        };
        _totalLoyaltyPoints = 0;
        _isLoading = false;
      });
      // Mark as no longer initial load
      _isInitialLoad = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error occurred while loading personal details.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.neutral400,
        appBar: CustomAppBar(
          title: 'Personal Details',
          showTitle: true,
          onBackPressed: () => Navigator.of(context).pop(),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: CustomAppBar(
        title: 'Personal Details',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refreshCustomerData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    // Profile Picture Section
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.neutral300,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.neutral200,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: AppColors.neutral100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Loyalty Points Card
                    LoyaltyPointsCard(
                      totalLoyaltyPoints: _totalLoyaltyPoints,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoyaltyPointsDetailsPage(
                              customerId: widget.customerId,
                              token: widget.token,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Personal Details Section
                    Text(
                      'Personal Information',
                      style: AppTextStyles.textLgMedium.copyWith(
                        color: AppColors.neutral100,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildDetailRow(
                        'First Name', _customerData!['firstName'] ?? 'N/A'),
                    _buildDetailRow(
                        'Last Name', _customerData!['lastName'] ?? 'N/A'),
                    _buildDetailRow('Email', _customerData!['email'] ?? 'N/A'),
                    _buildDetailRow(
                        'Phone Number', _customerData!['phoneNumber'] ?? 'N/A'),
                    _buildDetailRow('NIC', _customerData!['nic'] ?? 'N/A'),
                    _buildDetailRow(
                        'Address', _customerData!['address'] ?? 'N/A'),

                    // Add some bottom padding to ensure settings icon doesn't overlap
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            // Settings icon positioned in top right corner
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileOptionPage(
                        customerId: widget.customerId,
                        token: widget.token,
                      ),
                    ),
                  );
                  // Refresh data when returning from settings
                  // If result is true, data was updated, so refresh immediately
                  if (result == true) {
                    _refreshCustomerData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Personal details refreshed with latest updates!'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neutral300.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: AppColors.neutral100,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.neutral450,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: AppColors.neutral300,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: AppTextStyles.textSmMedium.copyWith(
                  color: AppColors.neutral150,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                value,
                style: AppTextStyles.textSmRegular.copyWith(
                  color: AppColors.neutral100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
