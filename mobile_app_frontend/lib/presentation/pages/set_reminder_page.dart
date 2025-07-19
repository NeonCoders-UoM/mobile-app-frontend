import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/data/models/reminder_model.dart';
import 'package:mobile_app_frontend/data/repositories/reminder_repository.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/vehicle_header.dart';

class SetReminderPage extends StatefulWidget {
  final int vehicleId;
  final String? token;

  const SetReminderPage({
    Key? key,
    required this.vehicleId,
    this.token,
  }) : super(key: key);

  @override
  _SetReminderPageState createState() => _SetReminderPageState();
}

class _SetReminderPageState extends State<SetReminderPage> {
  // Controllers for input fields
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _timeIntervalController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // State for notify period dropdown
  String? _selectedNotifyPeriod;

  // Loading state
  bool _isLoading = false;

  // Repository
  final ReminderRepository _reminderRepository = ReminderRepository();

  // Get vehicle ID and token from widget
  int get _vehicleId => widget.vehicleId;
  String? get _token => widget.token;

  // Service ID - In a real app, this would be selected from a dropdown of available services
  final int _serviceId = 1; // Default service ID

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
    _serviceNameController.dispose();
    _timeIntervalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _createReminderSync() {
    _createReminder();
  }

  Future<void> _createReminder() async {
    // Validate inputs before proceeding
    if (_serviceNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a service name')),
      );
      return;
    }
    if (_timeIntervalController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a time interval (in months)')),
      );
      return;
    }
    if (_selectedNotifyPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a notify period')),
      );
      return;
    }

    // Validate that time interval is a valid number
    final intervalMonths = int.tryParse(_timeIntervalController.text);
    if (intervalMonths == null || intervalMonths <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number of months')),
      );
      return;
    }

    // Parse notify period to get days
    final notifyDays = _parseNotifyPeriod(_selectedNotifyPeriod!);

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Calculate reminder date (current date + interval months)
      final reminderDate = DateTime.now()
          .add(Duration(days: intervalMonths * 30)); // Approximate

      // Create the new reminder model
      final newReminder = ServiceReminderModel(
        vehicleId: _vehicleId,
        serviceId: _serviceId,
        reminderDate: reminderDate,
        intervalMonths: intervalMonths,
        notifyBeforeDays: notifyDays,
        // Use service name as notes for backend storage and display
        notes: _serviceNameController.text.trim(),
        isActive: true,
      );

      // Save to backend
      print('🔧 Creating reminder: ${newReminder.toJson()}');
      print('🔑 Using token: ${_token != null ? "✅ Yes" : "❌ No"}');
      final createdReminder =
          await _reminderRepository.createReminder(newReminder, token: _token);
      print(
          '✅ Reminder created successfully with ID: ${createdReminder.serviceReminderId}');

      // Return success indicator and navigate back (don't show message here as it will be shown in parent)
      print('Navigating back with success result');
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create reminder: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Reset loading state
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper method to parse notify period string to days
  int _parseNotifyPeriod(String period) {
    switch (period) {
      case '1 day before':
        return 1;
      case '3 days before':
        return 3;
      case '7 days before':
        return 7;
      case '14 days before':
        return 14;
      case '30 days before':
        return 30;
      default:
        return 7; // Default to 7 days
    }
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
            const SizedBox(height: 32.0),
            // Vehicle Header
            const VehicleHeader(
              vehicleName: 'Mustang 1977',
              vehicleId: 'AB89B395',
            ),
            const SizedBox(height: 48.0),
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
                  const SizedBox(height: 48.0),
                  // Service Name Input
                  InputFieldAtom(
                    state: InputFieldState.defaultState,
                    label: 'Service Name',
                    placeholder:
                        'Enter service name (e.g., Oil Change, Brake Service)',
                    controller: _serviceNameController,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16.0),
                  // Time Interval Input
                  InputFieldAtom(
                    state: InputFieldState.defaultState,
                    label: 'Time Interval',
                    placeholder: 'Time Interval',
                    controller: _timeIntervalController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {});
                    },
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
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary200),
                          )
                        : CustomButton(
                            label: 'Remind Me',
                            type: ButtonType.primary,
                            size: ButtonSize.large,
                            customWidth: double.infinity,
                            onTap: _createReminderSync,
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
