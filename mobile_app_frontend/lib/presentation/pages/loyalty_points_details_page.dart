import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/data/repositories/loyalty_points_repository.dart';
import 'package:mobile_app_frontend/data/models/loyalty_points_model.dart';
import 'package:intl/intl.dart';

class LoyaltyPointsDetailsPage extends StatefulWidget {
  final int customerId;
  final String token;

  const LoyaltyPointsDetailsPage({
    Key? key,
    required this.customerId,
    required this.token,
  }) : super(key: key);

  @override
  State<LoyaltyPointsDetailsPage> createState() =>
      _LoyaltyPointsDetailsPageState();
}

class _LoyaltyPointsDetailsPageState extends State<LoyaltyPointsDetailsPage> {
  final _loyaltyPointsRepository = LoyaltyPointsRepository();
  List<LoyaltyPointsModel> _loyaltyPointsHistory = [];
  int _totalLoyaltyPoints = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLoyaltyPointsHistory();
  }

  Future<void> _loadLoyaltyPointsHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get total loyalty points
      final totalPoints =
          await _loyaltyPointsRepository.getTotalCustomerLoyaltyPoints(
        widget.customerId,
        widget.token,
      );

      // For now, we'll show a simplified view since we don't have individual appointment loyalty points
      // In a real implementation, you would fetch the detailed history
      setState(() {
        _totalLoyaltyPoints = totalPoints;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load loyalty points: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: CustomAppBar(
        title: 'Loyalty Points',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorWidget()
                : _buildContent(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.neutral200,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Loyalty Points',
            style: AppTextStyles.textLgMedium.copyWith(
              color: AppColors.neutral100,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.neutral200,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadLoyaltyPointsHistory,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary200,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadLoyaltyPointsHistory,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // Total Points Card
            _buildTotalPointsCard(),
            const SizedBox(height: 32),

            // How to Earn Points Section
            _buildHowToEarnSection(),
            const SizedBox(height: 32),

            // Points History Section (placeholder for now)
            _buildPointsHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPointsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary200,
            AppColors.primary300,
          ],
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary200.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.stars,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Loyalty Points',
                      style: AppTextStyles.textLgMedium.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Earned from completed services',
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _totalLoyaltyPoints.toString(),
                style: AppTextStyles.displaySmBold.copyWith(
                  color: Colors.white,
                  fontSize: 48,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'points',
                style: AppTextStyles.textLgRegular.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHowToEarnSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.neutral450,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppColors.neutral300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to Earn Points',
            style: AppTextStyles.textLgMedium.copyWith(
              color: AppColors.neutral100,
            ),
          ),
          const SizedBox(height: 16),
          _buildEarningMethod(
            Icons.build,
            'Complete Services',
            'Earn points for every service completed at our partner service centers',
            '5-50 points per service',
          ),
          const SizedBox(height: 16),
          _buildEarningMethod(
            Icons.schedule,
            'Regular Maintenance',
            'Get bonus points for regular maintenance appointments',
            '10 bonus points',
          ),
          const SizedBox(height: 16),
          _buildEarningMethod(
            Icons.star,
            'Premium Services',
            'Earn extra points for premium and specialized services',
            '15-25 extra points',
          ),
        ],
      ),
    );
  }

  Widget _buildEarningMethod(
      IconData icon, String title, String description, String points) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary200.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary200,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.textMdSemibold.copyWith(
                  color: AppColors.neutral100,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.textSmRegular.copyWith(
                  color: AppColors.neutral200,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                points,
                style: AppTextStyles.textSmMedium.copyWith(
                  color: AppColors.primary200,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPointsHistorySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.neutral450,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppColors.neutral300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Points History',
            style: AppTextStyles.textLgMedium.copyWith(
              color: AppColors.neutral100,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: AppColors.neutral200,
                ),
                const SizedBox(height: 12),
                Text(
                  'Detailed history coming soon!',
                  style: AppTextStyles.textMdRegular.copyWith(
                    color: AppColors.neutral200,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'re working on bringing you detailed breakdown of your loyalty points.',
                  style: AppTextStyles.textSmRegular.copyWith(
                    color: AppColors.neutral200,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
