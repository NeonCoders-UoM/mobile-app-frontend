import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/appointment_card.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/pages/appointmentdateselection_page.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';
import 'package:mobile_app_frontend/data/repositories/appointment_repository.dart';
import 'package:mobile_app_frontend/data/models/appointment_model.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

class AppointmentPage extends StatefulWidget {
  final int customerId;
  final int vehicleId;
  final String token;

  const AppointmentPage({
    required this.customerId,
    required this.vehicleId,
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  late Future<List<AppointmentSummary>> _appointments;

  @override
  void initState() {
    super.initState();
    _appointments = AppointmentRepository().getAppointmentsByVehicle(
      widget.customerId,
      widget.vehicleId,
      widget.token,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Appointments',
        showTitle: true,
        onBackPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VehicleDetailsHomePage(
                customerId: widget.customerId,
                token: widget.token,
              ),
            ),
          );
        },
      ),
      backgroundColor: AppColors.neutral400,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: FutureBuilder<List<AppointmentSummary>>(
          future: _appointments,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: \\${snapshot.error}'));
            }
            final appointments = snapshot.data ?? [];
            if (appointments.isEmpty) {
              return const Center(child: Text('No appointments found'));
            }
            return ListView.separated(
              itemCount: appointments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 24),
              itemBuilder: (context, index) {
                final appt = appointments[index];
                return AppointmentCard(
                  servicecenterName: appt.stationName,
                  date:
                      DateFormat('EEE, MMM, yyyy').format(appt.appointmentDate),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppointmentdateselectionPage(
                customerId: widget.customerId,
                vehicleId: widget.vehicleId,
                token: widget.token,
              ),
            ),
          );
        },
        backgroundColor: AppColors.neutral150,
        child: const Icon(Icons.add),
      ),
    );
  }
}
