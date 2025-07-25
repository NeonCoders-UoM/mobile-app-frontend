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
import 'package:mobile_app_frontend/presentation/pages/pdf_view_page.dart';
import 'dart:io';

class ServiceHistoryPage extends StatefulWidget {
  final int vehicleId;
  final String vehicleName;
  final String vehicleRegistration;
  final String? token;

  const ServiceHistoryPage({
    Key? key,
    this.vehicleId = 1, // Default vehicle ID
    this.vehicleName = 'Mustang 1977',
    this.vehicleRegistration = 'AB89B395',
    this.token,
  }) : super(key: key);

  @override
  _ServiceHistoryPageState createState() => _ServiceHistoryPageState();
}

class _ServiceHistoryPageState extends State<ServiceHistoryPage> {
  final ServiceHistoryRepository _serviceHistoryRepository = ServiceHistoryRepository();
  List<ServiceHistoryModel> _serviceHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServiceHistory();
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
      final pdfBytes = await _serviceHistoryRepository.downloadServiceHistoryPdf(
        widget.vehicleId,
        token: widget.token,
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/service_history_${widget.vehicleId}.pdf');
      await file.writeAsBytes(pdfBytes);
      // TODO: Use a package like `open_file` or `share_plus` to open or share the file
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to ${file.path}')),
      );
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

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day}, ${months[date.month - 1]}, ${date.year}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: const CustomAppBar(title: 'Service History'),
      body: Column(
        children: [
          // Backend Connection Status
          const BackendConnectionWidget(),

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
          // View PDF Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfViewPage(
                              vehicleId: widget.vehicleId,
                              token: widget.token,
                            ),
                          ),
                        );
                      },
                icon: const Icon(Icons.visibility, color: Colors.white),
                label: Text(
                  'View Service History PDF',
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
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary200,
                    ),
                  )
                : _serviceHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: AppColors.neutral200,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Service History',
                              style: AppTextStyles.textLgSemibold.copyWith(
                                color: AppColors.neutral100,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first service record to get started',
                              style: AppTextStyles.textSmRegular.copyWith(
                                color: AppColors.neutral200,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadServiceHistory,
                        color: AppColors.primary200,
                        backgroundColor: AppColors.neutral400,
                        child: ListView.builder(
                          itemCount: _serviceHistory.length,
                          itemBuilder: (context, index) {
                            return _buildServiceRecord(_serviceHistory[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}