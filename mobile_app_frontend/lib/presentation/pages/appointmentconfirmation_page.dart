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
  final int? stationId;

  const AppointmentconfirmationPage({
    Key? key,
    required this.selectedDate,
    required this.selectedServices,
    required this.customerId,
    required this.vehicleId,
    required this.token,
    this.stationId,
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

  Future<void> _createAppointment() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final serviceIds = widget.selectedServices.map((s) => s.serviceId).toList();
      final appointment = AppointmentCreate(
        customerId: widget.customerId,
        vehicleId: widget.vehicleId,
        stationId: widget.stationId ?? 1,
        appointmentDate: selectedDate,
        serviceIds: serviceIds,
      );
      print('Appointment payload: ${appointment.toJson()}');
      await AppointmentRepository(Dio())
          .createAppointment(appointment, widget.token);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceCenterPage(
            selectedServices: widget.selectedServices,
            selectedDate: selectedDate,
            customerId: widget.customerId,
            vehicleId: widget.vehicleId,
            token: widget.token,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        if (e is DioException && e.response != null) {
          errorMessage = 'Error: ${e.response?.data?['message'] ?? e.message}';
        } else {
          errorMessage = e.toString();
        }
      });
      print('Error: $e, Response: ${e is DioException ? e.response : null}');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ServiceCenterPage(
            selectedServices: widget.selectedServices,
            selectedDate: selectedDate,
            customerId: widget.customerId,
            vehicleId: widget.vehicleId,
            token: widget.token,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage!)),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: DatePicker(
                    initialDate: selectedDate,
                  ),
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.neutral450,
                    border: Border.all(color: AppColors.neutral200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      widget.selectedServices.isEmpty
                          ? const Center(
                              child: Text(
                                'No Selected Services',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : SizedBox(
                              height: (widget.selectedServices.length * 100.0)
                                  .clamp(100.0, double.infinity),
                              child: ListView.builder(
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
                                          widget.selectedServices[index].serviceName,
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
                  SizedBox(
                    height: 20,
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: isLoading ? 'Applying...' : 'Apply',
                    type: ButtonType.primary,
                    size: ButtonSize.medium,
                    onTap: !isLoading
                        ? () {
                            _createAppointment();
                          }
                        : null,
                  ),
                ),
                const SizedBox(height: 60), // Increased padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}