import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/pages/appointment_page.dart';
import 'package:mobile_app_frontend/presentation/pages/servicecenter_page.dart';
import 'package:mobile_app_frontend/presentation/pages/serviceselection_page.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/date_picker.dart';
import 'package:mobile_app_frontend/data/repositories/appointment_repository.dart';
import 'package:mobile_app_frontend/data/models/appointment_model.dart';
import 'package:mobile_app_frontend/data/models/service_model.dart';
import 'package:dio/dio.dart';

class AppointmentconfirmationPage extends StatefulWidget {
  final DateTime selectedDate;
  final List<Service> selectedServices;
  final int customerId;
  final int vehicleId;
  final String token;

  const AppointmentconfirmationPage({
    Key? key,
    required this.selectedDate,
    required this.selectedServices, // full Service list
    required this.customerId,
    required this.vehicleId,
    required this.token,
  }) : super(key: key);

  @override
  _AppointmentconfirmationPageState createState() =>
      _AppointmentconfirmationPageState();
}

class _AppointmentconfirmationPageState
    extends State<AppointmentconfirmationPage> {
  late DateTime selectedDate;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }


  Future<void> _proceedToServiceCenterSelection() async {
    // Navigate directly to service center selection without creating appointment
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceCenterPage(
          selectedServices: widget.selectedServices,
          selectedDate: selectedDate,
          customerId: widget.customerId,
          vehicleId: widget.vehicleId,
          token: widget.token,

//   Future<void> _createAppointment() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });
//     try {
//       // Map selectedServices to their real serviceId property
//       final serviceIds =
//           widget.selectedServices.map((s) => s.serviceId).toList();
//       final appointment = AppointmentCreate(
//         customerId: widget.customerId,
//         vehicleId: widget.vehicleId,
//         stationId: 1, // TODO: Replace with actual selected stationId
//         appointmentDate: selectedDate,
//         serviceIds: serviceIds,
//       );
//       await AppointmentRepository()
//           .createAppointment(appointment, widget.token);
//       if (!mounted) return;
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => ServiceCenterPage(
//             selectedServices: widget.selectedServices,
//             selectedDate: selectedDate,
//             customerId: widget.customerId,
//             vehicleId: widget.vehicleId,
//             token: widget.token,
//           ),

        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: CustomAppBar(
        title: 'Appointment',
        showTitle: true,
        onBackPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentPage(
                customerId: widget.customerId,
                vehicleId: widget.vehicleId,
                token: widget.token,
              ),
            ),
          );
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DatePicker(
                initialDate: selectedDate,
              ),
              const SizedBox(height: 24),
              Text(
                'Selected Services',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 440,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.neutral450,
                  border: Border.all(color: AppColors.neutral200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: widget.selectedServices.isEmpty
                          ? const Center(
                              child: Text(
                                'No Selected Services',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: widget.selectedServices.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        widget.selectedServices[index]
                                            .serviceName,
                                        style: AppTextStyles.textLgRegular
                                            .copyWith(
                                          color: AppColors.neutral200,
                                        ),
                                      ),
                                      Checkbox(
                                          value: true,
                                          onChanged: (_) {},
                                          checkColor: Colors.white,
                                          activeColor: AppColors.primary200)
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServiceselectionPage(
                                selectedDate: selectedDate,
                                customerId: widget.customerId,
                                vehicleId: widget.vehicleId,
                                token: widget.token,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(8.0),
                          alignment: Alignment.center,
                          child: const Text(
                            '+',
                            style: TextStyle(
                              fontSize: 24,
                              color: AppColors.neutral200,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: isLoading ? 'Applying...' : 'Apply',
                  type: ButtonType.primary,
                  size: ButtonSize.medium,
                  onTap: !isLoading
                      ? () {
                          _proceedToServiceCenterSelection();
                        }
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
