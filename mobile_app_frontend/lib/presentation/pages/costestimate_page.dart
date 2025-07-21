import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/cost_estimate_table.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/cost_estimate_description.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/pages/advanced_payment_required_page.dart';
import 'package:mobile_app_frontend/presentation/pages/appointment_page.dart';
import 'package:mobile_app_frontend/presentation/pages/servicecenter_page.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';
import 'package:mobile_app_frontend/data/repositories/service_center_repository.dart';
import 'package:mobile_app_frontend/data/models/service_model.dart';
import 'package:dio/dio.dart';

class CostEstimatePage extends StatefulWidget {
  final int customerId;
  final int vehicleId;
  final String token;
  final int serviceCenterId;
  final List<Service> selectedServices;

  const CostEstimatePage({
    Key? key,
    required this.customerId,
    required this.vehicleId,
    required this.token,
    required this.serviceCenterId,
    required this.selectedServices,
  }) : super(key: key);

  @override
  State<CostEstimatePage> createState() => _CostEstimatePageState();
}

class _CostEstimatePageState extends State<CostEstimatePage> {
  double totalCost = 0.0;
  bool isLoading = true;
  String? errorMessage;
  List<Service> centerServices = [];

  @override
  void initState() {
    super.initState();
    _fetchCostEstimate();
  }

  Future<void> _fetchCostEstimate() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final repo = ServiceCenterRepository(Dio());
      final services = await repo.getServicesForCenter(
          centerId: widget.serviceCenterId, token: widget.token);
      double total = 0.0;
      for (final selected in widget.selectedServices) {
        final svc =
            services.where((s) => s.serviceId == selected.serviceId).toList();
        if (svc.isNotEmpty) {
          total += svc.first.basePrice;
        }
      }
      setState(() {
        centerServices = services;
        totalCost = total;
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
        title: 'Cost Estimation',
        showTitle: true,
        onBackPressed: () => {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceCenterPage(
                selectedServices: widget.selectedServices,
                selectedDate: DateTime.now(), // Pass real date if needed
                customerId: widget.customerId,
                vehicleId: widget.vehicleId,
                token: widget.token,
              ),
            ),
          ),
        },
      ),
      backgroundColor: AppColors.neutral400,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(child: Text('Error: $errorMessage'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CostEstimateDescription(
                            servicecenterName:
                                '', // TODO: Add real name if needed
                            vehicleRegNo: '', // TODO: Add real reg no if needed
                            appointmentDate:
                                '', // TODO: Add real date if needed
                            loyaltyPoints: '',
                            serviceCenterId: widget.serviceCenterId.toString(),
                            address: '',
                            distance: '',
                          ),
                          const SizedBox(height: 48),
                          CostEstimateTable(
                            services: widget.selectedServices
                                .map((s) => s.serviceName)
                                .toList(),
                            costs: widget.selectedServices.map((s) {
                              final svc = centerServices
                                  .where((cs) => cs.serviceId == s.serviceId)
                                  .toList();
                              return svc.isNotEmpty
                                  ? svc.first.basePrice.toInt()
                                  : 0;
                            }).toList(),
                            total: totalCost.toInt(),
                          ),
                          const SizedBox(height: 80),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              label: 'Book an Appointment',
                              type: ButtonType.primary,
                              size: ButtonSize.medium,
                              onTap: () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AppointmentPage(
                                      customerId: widget.customerId,
                                      vehicleId: widget.vehicleId,
                                      token: widget.token,
                                    ),
                                  ),
                                )
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
