import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/service_center_card.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/pages/appointmentconfirmation_page.dart';
import 'package:mobile_app_frontend/presentation/pages/costestimate_page.dart';
import 'package:mobile_app_frontend/data/models/service_model.dart';
import 'package:mobile_app_frontend/data/models/service_center_model.dart';
import 'package:mobile_app_frontend/data/repositories/service_center_repository.dart';
import 'package:dio/dio.dart';

class ServiceCenterPage extends StatefulWidget {
  final List<Service> selectedServices;
  final DateTime selectedDate;
  final int customerId;
  final int vehicleId;
  final String token;

  const ServiceCenterPage({
    Key? key,
    required this.selectedServices,
    required this.selectedDate,
    required this.customerId,
    required this.vehicleId,
    required this.token,
  }) : super(key: key);

  @override
  State<ServiceCenterPage> createState() => _ServiceCenterPageState();
}

class _ServiceCenterPageState extends State<ServiceCenterPage> {
  List<ServiceCenterModel> centers = [];
  Map<int, double> costEstimates = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCentersAndCosts();
  }

  Future<void> _fetchCentersAndCosts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final repo = ServiceCenterRepository(Dio());
      final data = await repo.getAllServiceCenters(token: widget.token);
      final Map<int, double> costs = {};
      for (final center in data) {
        final services = await repo.getServicesForCenter(
            centerId: center.stationId, token: widget.token);
        double total = 0.0;
        for (final selected in widget.selectedServices) {
          final svc =
              services.where((s) => s.serviceId == selected.serviceId).toList();
          if (svc.isNotEmpty) {
            total += svc.first.basePrice;
          }
        }
        costs[center.stationId] = total;
      }
      setState(() {
        centers = data;
        costEstimates = costs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Select Service Center',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral400,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text('Error: $errorMessage'))
                : ListView.separated(
                    itemCount: centers.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final center = centers[index];
                      final cost = costEstimates[center.stationId] ?? 0.0;
                      return ServiceCenterCard(
                        servicecenterName: center.stationName,
                        address: center.address,
                        distance: '', // TODO: Add real distance if available
                        loyaltyPoints:
                            '', // TODO: Add real loyalty points if available
                        estimatedCost: 'Rs. ${cost.toStringAsFixed(2)}',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CostEstimatePage(
                                customerId: widget.customerId,
                                vehicleId: widget.vehicleId,
                                token: widget.token,
                                serviceCenterId: center.stationId,
                                selectedServices: widget.selectedServices,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
