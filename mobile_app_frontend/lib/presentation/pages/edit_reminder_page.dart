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
  late TextEditingController _serviceTypeController;
  late TextEditingController _mileageIntervalController;
  late TextEditingController _timeIntervalController;

  // State for checkboxes
  late bool _isMileageIntervalEnabled;
  late bool _isTimeIntervalEnabled;

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

    // Extract mileage interval (remove 'km' if present)
    String mileageInterval =
        widget.reminder['mileageInterval'] ?? 'Not specified';
    if (mileageInterval != 'Not specified') {
      mileageInterval = mileageInterval.replaceAll('km', '').trim();
    }
    _mileageIntervalController = TextEditingController(
      text: mileageInterval != 'Not specified' ? mileageInterval : '',
    );

    // Extract time interval (remove ' months' if present)
    String timeInterval = widget.reminder['timeInterval'] ?? 'Not specified';
    if (timeInterval != 'Not specified') {
      timeInterval = timeInterval.replaceAll(' months', '').trim();
    }
    _timeIntervalController = TextEditingController(
      text: timeInterval != 'Not specified' ? timeInterval : '',
    );

    // Initialize checkbox states
    _isMileageIntervalEnabled =
        widget.reminder['mileageInterval'] != 'Not specified';
    _isTimeIntervalEnabled = widget.reminder['timeInterval'] != 'Not specified';

    // Initialize notify period
    _selectedNotifyPeriod = widget.reminder['notifyPeriod'];
  }

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
        title: 'Edit Reminder',
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
                  // Save Button (full width, as in SetReminderPage)
                  CustomButton(
                    label: 'Save Changes',
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
                              content: Text('Please enter a mileage interval')),
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

                      // Create the updated reminder
                      final updatedReminder = {
                        'title': _serviceTypeController.text,
                        'description':
                            'Next: ${_isMileageIntervalEnabled ? _mileageIntervalController.text + ' km' : ''}${_isMileageIntervalEnabled && _isTimeIntervalEnabled ? ' or ' : ''}${_isTimeIntervalEnabled ? 'in ' + _timeIntervalController.text + ' months' : ''}',
                        'status': widget.reminder['status'] ??
                            ServiceStatus
                                .upcoming, // Preserve the original status
                        'nextDue':
                            'Next: ${_isMileageIntervalEnabled ? _mileageIntervalController.text + ' km' : ''}${_isMileageIntervalEnabled && _isTimeIntervalEnabled ? ' or ' : ''}${_isTimeIntervalEnabled ? 'in ' + _timeIntervalController.text + ' months' : ''}',
                        'mileageInterval': _isMileageIntervalEnabled
                            ? _mileageIntervalController.text + 'km'
                            : 'Not specified',
                        'timeInterval': _isTimeIntervalEnabled
                            ? _timeIntervalController.text + ' months'
                            : 'Not specified',
                        'lastServiceDate': widget.reminder['lastServiceDate'] ??
                            'Not specified', // Preserve the original last service date
                        'notifyPeriod': _selectedNotifyPeriod,
                      };

                      // Return the updated reminder and its index
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
