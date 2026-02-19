import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/core/models/vehicle_transfer.dart';
import 'package:mobile_app_frontend/services/vehicle_transfer_service.dart';
import 'package:intl/intl.dart';

class PendingTransfersPage extends StatefulWidget {
  final int customerId;

  const PendingTransfersPage({
    super.key,
    required this.customerId,
  });

  @override
  State<PendingTransfersPage> createState() => _PendingTransfersPageState();
}

class _PendingTransfersPageState extends State<PendingTransfersPage> {
  final _transferService = VehicleTransferService();
  List<VehicleTransfer> _transfers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingTransfers();
  }

  Future<void> _loadPendingTransfers() async {
    setState(() => _isLoading = true);
    final transfers =
        await _transferService.getPendingTransfers(widget.customerId);
    setState(() {
      _transfers = transfers;
      _isLoading = false;
    });
  }

  Future<void> _acceptTransfer(VehicleTransfer transfer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.neutral400,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Accept Transfer',
          style: AppTextStyles.textLgSemibold
              .copyWith(color: AppColors.neutral100),
        ),
        content: Text(
          'Are you sure you want to accept this vehicle: ${transfer.vehicleName}?',
          style:
              AppTextStyles.textSmRegular.copyWith(color: AppColors.neutral100),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text('Cancel', style: TextStyle(color: AppColors.neutral200)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.states['ok']),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await _transferService.acceptTransfer(
      transferId: transfer.transferId,
      buyerId: widget.customerId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success']
              ? AppColors.states['ok']
              : AppColors.states['error'],
        ),
      );

      if (result['success']) {
        _loadPendingTransfers();
      }
    }
  }

  Future<void> _rejectTransfer(VehicleTransfer transfer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.neutral400,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Reject Transfer',
          style: AppTextStyles.textLgSemibold
              .copyWith(color: AppColors.neutral100),
        ),
        content: Text(
          'Are you sure you want to reject this transfer for ${transfer.vehicleName}?',
          style:
              AppTextStyles.textSmRegular.copyWith(color: AppColors.neutral100),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text('Cancel', style: TextStyle(color: AppColors.neutral200)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.states['error']),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await _transferService.rejectTransfer(
      transferId: transfer.transferId,
      buyerId: widget.customerId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success']
              ? AppColors.states['upcoming']
              : AppColors.states['error'],
        ),
      );

      if (result['success']) {
        _loadPendingTransfers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pending Transfers',
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
                  onRefresh: _loadPendingTransfers,
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
            Icons.transfer_within_a_station,
            size: 80,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: 16),
          Text(
            'No Pending Transfers',
            style: AppTextStyles.textSmSemibold.copyWith(
              color: AppColors.neutral100,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any vehicle transfer requests',
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.neutral200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferCard(VehicleTransfer transfer) {
    final daysLeft = transfer.expiresAt.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysLeft <= 2;

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
          // Vehicle Info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary300.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.directions_car,
                  color: AppColors.primary100,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transfer.vehicleName ?? 'Unknown Vehicle',
                      style: AppTextStyles.textLgSemibold.copyWith(
                        color: AppColors.neutral100,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transfer.registrationNumber ?? '',
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral200,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Divider
          Divider(color: AppColors.neutral200.withOpacity(0.3)),
          const SizedBox(height: 12),

          // Transfer Details
          _buildDetailRow(Icons.person_outline, 'From',
              transfer.fromOwnerName ?? 'Unknown'),
          if (transfer.mileageAtTransfer != null)
            _buildDetailRow(Icons.speed_outlined, 'Mileage',
                '${transfer.mileageAtTransfer} km'),
          if (transfer.salePrice != null)
            _buildDetailRow(Icons.attach_money_outlined, 'Price',
                'LKR ${transfer.salePrice!.toStringAsFixed(2)}'),
          _buildDetailRow(
            Icons.calendar_today_outlined,
            'Initiated',
            DateFormat('MMM dd, yyyy').format(transfer.initiatedAt),
          ),

          // Expiry Warning
          if (isExpiringSoon) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.states['upcoming']!.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.states['upcoming']!.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.states['upcoming'],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Expires in $daysLeft day${daysLeft == 1 ? '' : 's'}',
                      style: AppTextStyles.textSmSemibold.copyWith(
                        color: AppColors.neutral100,
                      ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes:',
                    style: AppTextStyles.textSmSemibold.copyWith(
                      color: AppColors.neutral100,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transfer.notes!,
                    style: AppTextStyles.textSmRegular.copyWith(
                      color: AppColors.neutral200,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Reject',
                  onTap: () => _rejectTransfer(transfer),
                  type: ButtonType.secondary,
                  size: ButtonSize.medium,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  label: 'Accept',
                  onTap: () => _acceptTransfer(transfer),
                  type: ButtonType.primary,
                  size: ButtonSize.medium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.neutral200),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.neutral200,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.textSmSemibold.copyWith(
              color: AppColors.neutral100,
            ),
          ),
        ],
      ),
    );
  }
}
