import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/core/models/vehicle_transfer.dart';
import 'package:mobile_app_frontend/services/vehicle_transfer_service.dart';
import 'package:intl/intl.dart';

class VehicleTransferHistoryPage extends StatefulWidget {
  final int vehicleId;
  final String vehicleName;

  const VehicleTransferHistoryPage({
    super.key,
    required this.vehicleId,
    required this.vehicleName,
  });

  @override
  State<VehicleTransferHistoryPage> createState() =>
      _VehicleTransferHistoryPageState();
}

class _VehicleTransferHistoryPageState
    extends State<VehicleTransferHistoryPage> {
  final _transferService = VehicleTransferService();
  List<VehicleTransfer> _transfers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransferHistory();
  }

  Future<void> _loadTransferHistory() async {
    setState(() => _isLoading = true);
    final transfers =
        await _transferService.getTransferHistory(widget.vehicleId);
    setState(() {
      _transfers = transfers;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Transfer History',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral400,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary200),
            )
          : _transfers.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: AppColors.primary200,
                  backgroundColor: AppColors.neutral400,
                  onRefresh: _loadTransferHistory,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _transfers.length,
                    itemBuilder: (context, index) {
                      return _buildTransferCard(_transfers[index]);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Transfer History',
            style: AppTextStyles.textSmSemibold.copyWith(
              color: AppColors.neutral100,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This vehicle has no transfer history yet',
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.neutral200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferCard(VehicleTransfer transfer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.neutral300.withOpacity(0.6),
            AppColors.neutral300.withOpacity(0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neutral200.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badge and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(transfer.status),
              Text(
                DateFormat('MMM dd, yyyy').format(transfer.initiatedAt),
                style: AppTextStyles.textSmRegular.copyWith(
                  color: AppColors.neutral200,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Transfer Flow
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From',
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral200,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transfer.fromOwnerName ?? 'Unknown',
                      style: AppTextStyles.textSmSemibold.copyWith(
                        color: AppColors.neutral100,
                      ),
                    ),
                    Text(
                      transfer.fromOwnerEmail ?? '',
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral200,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward,
                  color: _getStatusColor(transfer.status),
                  size: 28,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'To',
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral200,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transfer.toOwnerName ?? 'Unknown',
                      style: AppTextStyles.textSmSemibold.copyWith(
                        color: AppColors.neutral100,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      transfer.toOwnerEmail ?? '',
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral200,
                      ),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (transfer.mileageAtTransfer != null ||
              transfer.salePrice != null) ...[
            const SizedBox(height: 16),
            Divider(color: AppColors.neutral200.withOpacity(0.3)),
            const SizedBox(height: 12),

            // Additional Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (transfer.mileageAtTransfer != null)
                  _buildDetailChip(
                    Icons.speed_outlined,
                    'Mileage',
                    '${transfer.mileageAtTransfer} km',
                  ),
                if (transfer.salePrice != null)
                  _buildDetailChip(
                    Icons.attach_money_outlined,
                    'Price',
                    'LKR ${transfer.salePrice!.toStringAsFixed(2)}',
                  ),
              ],
            ),
          ],

          // Completion Date for accepted transfers
          if (transfer.completedAt != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.states['ok']!.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.states['ok']!.withOpacity(0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.states['ok'],
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Completed: ${DateFormat('MMM dd, yyyy').format(transfer.completedAt!)}',
                    style: AppTextStyles.textSmRegular.copyWith(
                      color: AppColors.neutral100,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Notes
          if (transfer.notes != null && transfer.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neutral450.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note_outlined,
                    size: 16,
                    color: AppColors.neutral200,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      transfer.notes!,
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral100,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status,
        style: AppTextStyles.textSmSemibold.copyWith(
          color: color,
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary100),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.textSmRegular.copyWith(
            color: AppColors.neutral200,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.textSmSemibold.copyWith(
            color: AppColors.neutral100,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return AppColors.states['ok']!;
      case 'pending':
        return AppColors.states['upcoming']!;
      case 'rejected':
        return AppColors.states['error']!;
      case 'cancelled':
        return AppColors.states['canceled']!;
      case 'expired':
        return AppColors.states['overdue']!;
      default:
        return AppColors.primary200;
    }
  }
}
