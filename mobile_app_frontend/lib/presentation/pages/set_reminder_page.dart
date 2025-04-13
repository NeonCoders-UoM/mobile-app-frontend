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

class SetReminderPage extends StatefulWidget {
  const SetReminderPage({Key? key}) : super(key: key);

  @override
  _SetReminderPageState createState() => _SetReminderPageState();
}

class _SetReminderPageState extends State<SetReminderPage> {
  // Controllers for input fields
  final TextEditingController _serviceTypeController = TextEditingController();
  final TextEditingController _mileageIntervalController =
      TextEditingController();
  final TextEditingController _timeIntervalController = TextEditingController();

  // State for checkboxes
  bool _isMileageIntervalEnabled = false;
  bool _isTimeIntervalEnabled = false;

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
  void dispose() {
    _serviceTypeController.dispose();
    _mileageIntervalController.dispose();
    _timeIntervalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: const CustomAppBar(
        title: 'Set Reminders',
        showTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Header
            const VehicleHeader(
              vehicleName: 'Mustang 1977',
              vehicleId: 'AB89B395',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Additional vehicle details
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
                  const SizedBox(height: 24.0),
                  // Service Type Input
                  InputFieldAtom(
                    state: InputFieldState.defaultState,
                    label: 'Service Type',
                    placeholder: 'Service Type',
                    controller: _serviceTypeController,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Mileage Interval Checkbox and Input
                  Row(
                    children: [
                      Checkbox(
                        value: _isMileageIntervalEnabled,
                        onChanged: (value) {
                          setState(() {
                            _isMileageIntervalEnabled = value ?? false;
                            if (!_isMileageIntervalEnabled) {
                              _mileageIntervalController.clear();
                            }
                          });
                        },
                        activeColor: AppColors.primary200,
                        checkColor: AppColors.neutral100,
                        side: const BorderSide(color: AppColors.neutral200),
                      ),
                      Text(
                        'Mileage Interval',
                        style: AppTextStyles.textSmRegular.copyWith(
                          color: AppColors.neutral100,
                        ),
                      ),
                    ],
                  ),
                  InputFieldAtom(
                    state: _isMileageIntervalEnabled
                        ? InputFieldState.defaultState
                        : InputFieldState.disabled,
                    label: 'Mileage Interval',
                    placeholder: 'Mileage Interval',
                    controller: _mileageIntervalController,
                    keyboardType: TextInputType.number,
                    onChanged: _isMileageIntervalEnabled
                        ? (value) {
                            setState(() {});
                          }
                        : null,
                  ),
                  const SizedBox(height: 16.0),
                  // Time Interval Checkbox and Input
                  Row(
                    children: [
                      Checkbox(
                        value: _isTimeIntervalEnabled,
                        onChanged: (value) {
                          setState(() {
                            _isTimeIntervalEnabled = value ?? false;
                            if (!_isTimeIntervalEnabled) {
                              _timeIntervalController.clear();
                            }
                          });
                        },
                        activeColor: AppColors.primary200,
                        checkColor: AppColors.neutral100,
                        side: const BorderSide(color: AppColors.neutral200),
                      ),
                      Text(
                        'Time Interval',
                        style: AppTextStyles.textSmRegular.copyWith(
                          color: AppColors.neutral100,
                        ),
                      ),
                    ],
                  ),
                  InputFieldAtom(
                    state: _isTimeIntervalEnabled
                        ? InputFieldState.defaultState
                        : InputFieldState.disabled,
                    label: 'Time Interval',
                    placeholder: 'Time Interval',
                    controller: _timeIntervalController,
                    keyboardType: TextInputType.number,
                    onChanged: _isTimeIntervalEnabled
                        ? (value) {
                            setState(() {});
                          }
                        : null,
                  ),
                  const SizedBox(height: 16.0),
                  // Notify Period Dropdown
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
                  // Remind Me Button
                  // In SetReminderPage
                  Center(
                    child: CustomButton(
                      label: 'Remind Me',
                      type: ButtonType.primary,
                      size: ButtonSize.large,
                      customWidth: double.infinity,
                      onTap: () {
                        // Validate inputs before proceeding
                        if (_serviceTypeController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter a service type')),
                          );
                          return;
                        }
                        if (!_isMileageIntervalEnabled &&
                            !_isTimeIntervalEnabled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please select at least one interval (Mileage or Time)')),
                          );
                          return;
                        }
                        if (_isMileageIntervalEnabled &&
                            _mileageIntervalController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please enter a mileage interval')),
                          );
                          return;
                        }
                        if (_isTimeIntervalEnabled &&
                            _timeIntervalController.text.isEmpty) {
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

                        // Create the new reminder
                        final newReminder = {
                          'title': _serviceTypeController.text,
                          'description':
                              'Next: ${_isMileageIntervalEnabled ? _mileageIntervalController.text + ' km' : ''}${_isMileageIntervalEnabled && _isTimeIntervalEnabled ? ' or ' : ''}${_isTimeIntervalEnabled ? 'in ' + _timeIntervalController.text + ' months' : ''}',
                          'status': ServiceStatus.upcoming,
                          'nextDue':
                              'Next: ${_isMileageIntervalEnabled ? _mileageIntervalController.text + ' km' : ''}${_isMileageIntervalEnabled && _isTimeIntervalEnabled ? ' or ' : ''}${_isTimeIntervalEnabled ? 'in ' + _timeIntervalController.text + ' months' : ''}',
                          'mileageInterval': _isMileageIntervalEnabled
                              ? _mileageIntervalController.text + 'km'
                              : 'Not specified',
                          'timeInterval': _isTimeIntervalEnabled
                              ? _timeIntervalController.text + ' months'
                              : 'Not specified',
                          'lastServiceDate': 'Not specified',
                          'notifyPeriod': _selectedNotifyPeriod,
                        };

                        // Return the new reminder and navigate back
                        Navigator.pop(context, newReminder);
                      },
                    ),
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
