import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/pages/servicecenter_page.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/data/repositories/service_repository.dart';
import 'package:mobile_app_frontend/data/models/service_model.dart';
import 'package:dio/dio.dart';
import 'package:mobile_app_frontend/presentation/pages/appointmentconfirmation_page.dart';

class ServiceselectionPage extends StatefulWidget {
  final DateTime selectedDate;
  final int customerId;
  final int vehicleId;
  final String token;

  const ServiceselectionPage({
    Key? key,
    required this.selectedDate,
    required this.customerId,
    required this.vehicleId,
    required this.token,
  }) : super(key: key);

  @override
  _ServiceselectionPageState createState() => _ServiceselectionPageState();
}

class _ServiceselectionPageState extends State<ServiceselectionPage> {
  List<Service> availableServices = [];
  List<Service> selectedServices = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final repo = ServiceRepository(Dio());
      final services = await repo.getAllServices(token: widget.token);
      setState(() {
        availableServices = services;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _onServiceSelected(Service service) {
    setState(() {
      if (selectedServices.contains(service)) {
        selectedServices.remove(service);
      } else {
        selectedServices.add(service);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Select Services',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral400,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(child: Text('Error: $errorMessage'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          style: TextStyle(color: AppColors.neutral200),
                          decoration: InputDecoration(
                            hintText: 'Search',
                            prefixIcon: Icon(Icons.search),
                            fillColor: AppColors.neutral400,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: AppColors.neutral200),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: availableServices.length,
                            itemBuilder: (context, index) {
                              final service = availableServices[index];
                              return CheckboxListTile(
                                title: Text(
                                  service.serviceName,
                                  style: AppTextStyles.textLgRegular.copyWith(
                                    color: AppColors.neutral200,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                ),
                                value: selectedServices.contains(service),
                                onChanged: (bool? value) {
                                  _onServiceSelected(service);
                                },
                                controlAffinity:
                                    ListTileControlAffinity.trailing,
                                activeColor: AppColors.primary200,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            label: 'Continue',
                            type: ButtonType.primary,
                            size: ButtonSize.medium,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AppointmentconfirmationPage(
                                    selectedServices: selectedServices
                                        .map((s) => s.serviceName)
                                        .toList(),
                                    selectedDate: widget.selectedDate,
                                    customerId: widget.customerId,
                                    vehicleId: widget.vehicleId,
                                    token: widget.token,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
