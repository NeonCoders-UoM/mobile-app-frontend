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
  late TextEditingController _serviceNameController;
  late TextEditingController _timeIntervalController;

  // State for notify period dropdown
  String? _selectedNotifyPeriod;

  // Loading state
  bool _isLoading = false;

  // Repository
  final ReminderRepository _reminderRepository = ReminderRepository();

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
    // Use notes as the service name (our new approach)
    _serviceNameController = TextEditingController(
      text: widget.reminder['notes'] ?? widget.reminder['title'] ?? '',
    );

    // Extract time interval (remove ' months' if present and handle various formats)
    String timeInterval =
        widget.reminder['timeInterval']?.toString() ?? 'Not specified';
    if (timeInterval != 'Not specified') {
      // Remove various possible suffixes and clean up
      timeInterval = timeInterval
          .replaceAll(' months', '')
          .replaceAll('months', '')
          .replaceAll(' ', '')
          .trim();
    }

    // Also check intervalMonths field directly
    if ((timeInterval == 'Not specified' || timeInterval.isEmpty) &&
        widget.reminder['intervalMonths'] != null) {
      timeInterval = widget.reminder['intervalMonths'].toString();
    }

    _timeIntervalController = TextEditingController(
      text: timeInterval != 'Not specified' && timeInterval.isNotEmpty
          ? timeInterval
          : '',
    );

    // Initialize notify period - parse from existing notifyBeforeDays or notifyPeriod
    int? notifyDays = widget.reminder['notifyBeforeDays'];
    if (notifyDays != null) {
      _selectedNotifyPeriod = _convertDaysToNotifyPeriod(notifyDays);
    } else {
      _selectedNotifyPeriod = widget.reminder['notifyPeriod'];
    }
  }

  // Helper method to convert days to notify period string
  String _convertDaysToNotifyPeriod(int days) {
    switch (days) {
      case 1:
        return '1 day before';
      case 3:
        return '3 days before';
      case 7:
        return '7 days before';
      case 14:
        return '14 days before';
      case 30:
        return '30 days before';
      default:
        return '7 days before'; // Default
    }
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _timeIntervalController.dispose();
    super.dispose();
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

  Future<void> _updateReminder() async {
    print('=== _updateReminder called ===');
    print('Current reminder data: ${widget.reminder}');

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

    print('Parsed values:');
    print('  Service name: ${_serviceNameController.text.trim()}');
    print('  Interval months: $intervalMonths');
    print('  Notify days: $notifyDays');

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the current reminder data
      final currentReminderId = widget.reminder['serviceReminderId'];

      if (currentReminderId != null) {
        // Parse IDs to ensure they are integers
        final reminderIdInt = currentReminderId is int
            ? currentReminderId
            : int.tryParse(currentReminderId.toString()) ?? 0;

        final vehicleIdInt = widget.reminder['vehicleId'] is int
            ? widget.reminder['vehicleId']
            : int.tryParse(widget.reminder['vehicleId']?.toString() ?? '1') ??
                1;

        final serviceIdInt = widget.reminder['serviceId'] is int
            ? widget.reminder['serviceId']
            : int.tryParse(widget.reminder['serviceId']?.toString() ?? '1') ??
                1;

        print('Parsed IDs:');
        print('  Reminder ID: $reminderIdInt (from ${currentReminderId})');
        print(
            '  Vehicle ID: $vehicleIdInt (from ${widget.reminder['vehicleId']})');
        print(
            '  Service ID: $serviceIdInt (from ${widget.reminder['serviceId']})');

        // Calculate new reminder date (current date + interval months)
        final reminderDate = DateTime.now()
            .add(Duration(days: intervalMonths * 30)); // Approximate

        print('New reminder date: $reminderDate');

        // Create updated reminder model
        final updatedReminder = ServiceReminderModel(
          serviceReminderId: reminderIdInt,
          vehicleId: vehicleIdInt,
          serviceId: serviceIdInt,
          reminderDate: reminderDate,
          intervalMonths: intervalMonths,
          notifyBeforeDays: notifyDays,
          notes:
              _serviceNameController.text.trim(), // Use service name as notes
          isActive: widget.reminder['isActive'] ?? true,
        );

        print('Created reminder model: ${updatedReminder.toJson()}');

        // Update via repository
        await _reminderRepository.updateReminder(
            reminderIdInt, updatedReminder);

        print('Successfully updated reminder');

        // Return updated reminder data instead of just true
        final updatedData = {
          ...widget.reminder,
          'notes': _serviceNameController.text.trim(),
          'intervalMonths': intervalMonths,
          'notifyBeforeDays': notifyDays,
          'timeInterval': '$intervalMonths months',
          'reminderDate': reminderDate.toIso8601String(),
        };

        Navigator.pop(context, updatedData);
      } else {
        // This is a local reminder, just return the updated data
        final updatedData = {
          ...widget.reminder,
          'notes': _serviceNameController.text.trim(),
          'intervalMonths': intervalMonths,
          'notifyBeforeDays': notifyDays,
          'timeInterval': '$intervalMonths months',
        };
        Navigator.pop(context, updatedData);
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update reminder: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
      // Still return to previous screen on error, but with null result
      Navigator.pop(context, null);
    } finally {
      // Reset loading state
      setState(() {
        _isLoading = false;
      });
    }
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
                  const SizedBox(height: 48.0),
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
                  const SizedBox(height: 32.0),
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
                    label: 'Time Interval (Months)',
                    placeholder: 'Enter number of months',
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
                  // Save Button (full width)
                  CustomButton(
                    label: _isLoading ? 'Saving...' : 'Save Changes',
                    type: ButtonType.primary,
                    size: ButtonSize.large,
                    customWidth: double.infinity,
                    onTap: _isLoading ? () {} : () => _updateReminder(),
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
