import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/date_picker.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/pages/serviceselection_page.dart';

class AppointmentdateselectionPage extends StatefulWidget {
  const AppointmentdateselectionPage({super.key});

  @override
  State<AppointmentdateselectionPage> createState() =>
      _AppointmentdateselectionPageState();
}

class _AppointmentdateselectionPageState
    extends State<AppointmentdateselectionPage> {
  DateTime selectedDate = DateTime.now(); // initialize to today by default

  void _handleDateChange(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Appointments',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral400,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Assuming your DatePicker accepts a callback like onDateChanged
              DatePicker(
                initialDate: selectedDate,
                onDateChanged: _handleDateChange,
              ),
              const SizedBox(height: 24),
              const Text(
                'Selected Services',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'No Selected Services',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 320),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceselectionPage(
                              selectedDate: selectedDate,
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
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Apply',
                  type: ButtonType.primary,
                  size: ButtonSize.medium,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  ServiceselectionPage(selectedDate: DateTime.now(),)));

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
