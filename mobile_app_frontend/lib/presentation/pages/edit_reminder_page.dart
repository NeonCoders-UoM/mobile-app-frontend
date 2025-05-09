import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/service_reminder_card.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/vehicle_header.dart';

class EditReminderPage extends StatefulWidget {
  final Map<String, dynamic> reminder;
  final int index;

  const EditReminderPage({
    Key? key,
    required this.reminder,
    required this.index,
  }) : super(key: key);

  @override
  _EditReminderPageState createState() => _EditReminderPageState();
}

class _EditReminderPageState extends State<EditReminderPage> {
  // Controllers for input fields
  TextEditingController? _serviceTypeController;
  TextEditingController? _timeIntervalController;

  // State for notify period dropdown
  String? _selectedNotifyPeriod;

  // List of notify period options
  final List<String> _notifyPeriods = [
    '1 day before',
    '3 days before',
    '7 days before',
    '14 days before',
    '30 days before',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _serviceTypeController =
        TextEditingController(text: widget.reminder['title']);

    // Extract time interval (remove ' months' if present)
    String timeInterval = widget.reminder['timeInterval'] ?? 'Not specified';
    if (timeInterval != 'Not specified') {
      timeInterval = timeInterval.replaceAll(' months', '').trim();
    }
    _timeIntervalController = TextEditingController(
      text: timeInterval != 'Not specified' ? timeInterval : '',
    );

    // Initialize notify period
    _selectedNotifyPeriod = widget.reminder['notifyPeriod'];
  }

  // Dispose controllers to free up resources
  @override
  void dispose() {
    _serviceTypeController?.dispose();
    _timeIntervalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: const CustomAppBar(
        title: 'Edit Reminder',
        showTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32.0),
            const VehicleHeader(
              vehicleName: 'Mustang 1977',
              vehicleId: 'AB89B395',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48.0),
                  Text(
                    'Vehicle Registration No: AB89B395',
                    style: AppTextStyles.textSmRegular.copyWith(
                      color: AppColors.neutral200,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Vehicle Registration Date: 14-12-2024',
                    style: AppTextStyles.textSmRegular.copyWith(
                      color: AppColors.neutral200,
                    ),
                  ),
                  const SizedBox(height: 32.0),
                  InputFieldAtom(
                    state: InputFieldState.defaultState,
                    label: 'Service Type',
                    placeholder: 'Service Type',
                    controller:
                        _serviceTypeController ?? TextEditingController(),
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16.0),
                  InputFieldAtom(
                    state: InputFieldState.defaultState,
                    label: 'Time Interval',
                    placeholder: 'Time Interval',
                    controller:
                        _timeIntervalController ?? TextEditingController(),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => setState(() {}),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Notify Period',
                    style: AppTextStyles.textSmRegular.copyWith(
                      color: AppColors.neutral100,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  DropdownButtonFormField<String>(
                    value: _selectedNotifyPeriod,
                    hint: Text(
                      'Notify Period',
                      style: AppTextStyles.textSmSemibold.copyWith(
                        color: AppColors.neutral200,
                      ),
                    ),
                    items: _notifyPeriods.map((String period) {
                      return DropdownMenuItem<String>(
                        value: period,
                        child: Text(
                          period,
                          style: AppTextStyles.textSmRegular.copyWith(
                            color: AppColors.neutral100,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedNotifyPeriod = newValue;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: AppColors.neutral200),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: AppColors.neutral200),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: AppColors.neutral200, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    dropdownColor: AppColors.neutral400,
                    iconEnabledColor: AppColors.neutral100,
                  ),
                  const SizedBox(height: 32.0),
                  CustomButton(
                    label: 'Save Changes',
                    type: ButtonType.primary,
                    size: ButtonSize.large,
                    customWidth: double.infinity,
                    onTap: () {
                      if ((_serviceTypeController?.text ?? '').isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter a service type')),
                        );
                        return;
                      }
                      if ((_timeIntervalController?.text ?? '').isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter a time interval')),
                        );
                        return;
                      }
                      if (_selectedNotifyPeriod == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please select a notify period')),
                        );
                        return;
                      }

                      final updatedReminder = {
                        'title': _serviceTypeController!.text,
                        'description':
                            'Next: in ${_timeIntervalController!.text} months',
                        'status':
                            widget.reminder['status'] ?? ServiceStatus.upcoming,
                        'nextDue':
                            'Next: in ${_timeIntervalController!.text} months',
                        'mileageInterval': 'Not specified',
                        'timeInterval':
                            '${_timeIntervalController!.text} months',
                        'lastServiceDate': widget.reminder['lastServiceDate'] ??
                            'Not specified',
                        'notifyPeriod': _selectedNotifyPeriod,
                      };

                      Navigator.pop(context, {
                        'reminder': updatedReminder,
                        'index': widget.index,
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
