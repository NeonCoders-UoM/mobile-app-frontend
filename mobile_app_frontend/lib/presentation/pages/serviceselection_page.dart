import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/pages/appointmentconfirmation_page.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';

class ServiceselectionPage extends StatefulWidget {
  final DateTime selectedDate;

  const ServiceselectionPage({Key? key, required this.selectedDate})
      : super(key: key);

  @override
  _ServiceselectionPageState createState() => _ServiceselectionPageState();
}

class _ServiceselectionPageState extends State<ServiceselectionPage> {
  final List<String> services = [
    'Oil Change',
    'Tire Rotation & Balancing',
    'Oil Change',
    'Tire Rotation & Balancing',
    'Oil Change',
    'Tire Rotation & Balancing',
    'Oil Change',
    'Tire Rotation & Balancing',
    'Brake Inspection'
  ];
  final List<String> selectedServices = [];

  void _onServiceSelected(String service) {
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
        title: 'Appointment',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral400,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔍 Search Bar
              TextField(
                style: TextStyle(color: AppColors.neutral200),
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  fillColor: AppColors.neutral400,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.neutral200),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 📦 Container for the service list
              Container(
                margin: const EdgeInsets.all(4.0),
                width: double.infinity,
                height: 548,
                decoration: BoxDecoration(
                  color: AppColors.neutral450,
                  border: Border.all(color: AppColors.neutral200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text(
                        services[index],
                        style: AppTextStyles.textLgRegular.copyWith(
                          color: AppColors.neutral200,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                      value: selectedServices.contains(services[index]),
                      onChanged: (bool? value) {
                        _onServiceSelected(services[index]);
                      },
                      controlAffinity: ListTileControlAffinity.trailing,
                      activeColor: AppColors.primary200,
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ✅ Select Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'Select',
                  type: ButtonType.primary,
                  size: ButtonSize.medium,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AppointmentconfirmationPage(
                          selectedServices: selectedServices,
                          selectedDate: widget.selectedDate,
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
