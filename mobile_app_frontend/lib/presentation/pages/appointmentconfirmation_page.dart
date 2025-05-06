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


class AppointmentconfirmationPage extends StatefulWidget {
  final DateTime selectedDate;
  final List<String> selectedServices;

  const AppointmentconfirmationPage({
    Key? key,
    required this.selectedDate,
    required this.selectedServices,
  }) : super(key: key);

  @override
  _AppointmentconfirmationPageState createState() =>
      _AppointmentconfirmationPageState();
}

class _AppointmentconfirmationPageState
    extends State<AppointmentconfirmationPage> {
  late DateTime selectedDate;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: CustomAppBar(
        title: 'Appointment',
        showTitle: true,
        onBackPressed: () => {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AppointmentPage()))
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
                                        widget.selectedServices[index],
                                        style: AppTextStyles.textLgRegular
                                            .copyWith(
                                          color: AppColors.neutral200,
                                        ),
                                      ),
                                      Checkbox(
                                          value: true,
                                          onChanged: (_) {},
                                          checkColor:
                                              Colors.white, // Tick color
                                          activeColor: AppColors
                                              .primary200 // Box fill color when checked
                                          )
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
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Apply',
                  type: ButtonType.primary,
                  size: ButtonSize.medium,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceCenterPage()),);
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
