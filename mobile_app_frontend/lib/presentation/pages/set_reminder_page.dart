import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/data/models/reminder_model.dart';
import 'package:mobile_app_frontend/data/models/service_model.dart';
import 'package:mobile_app_frontend/data/repositories/reminder_repository.dart';
import 'package:mobile_app_frontend/data/repositories/service_repository.dart';
import 'package:mobile_app_frontend/data/repositories/service_history_repository.dart';
import 'package:dio/dio.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/vehicle_header.dart';
import 'package:mobile_app_frontend/services/auth_service.dart';

class SetReminderPage extends StatefulWidget {
  final int vehicleId;
  final int customerId;
  final String? token;

  const SetReminderPage({
    Key? key,
    required this.vehicleId,
    required this.customerId,
    this.token,
  }) : super(key: key);

  @override
  _SetReminderPageState createState() => _SetReminderPageState();
}

class _SetReminderPageState extends State<SetReminderPage> {
  // Controllers for input fields
  final TextEditingController _timeIntervalController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // State for service dropdown
  List<Service> _services = [];
  Service? _selectedService;

  // State for notify period dropdown
  String? _selectedNotifyPeriod;

  // Loading state
  bool _isLoading = false;

  // Repositories
  final ReminderRepository _reminderRepository = ReminderRepository();
  final ServiceRepository _serviceRepository = ServiceRepository(Dio());
  final ServiceHistoryRepository _serviceHistoryRepository =
      ServiceHistoryRepository();

  final AuthService _authService = AuthService();
  Map<String, dynamic>? _vehicle;
  bool _vehicleLoading = true;
  String? _vehicleError;

  // Get vehicle ID and token from widget
  int get _vehicleId => widget.vehicleId;
  String? get _token => widget.token;

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
    _fetchServices();
    _fetchVehicleDetails();
  }

  Future<void> _fetchServices() async {
    try {
      // You may want to pass token if required
      final token = _token ?? '';
      final services = await _serviceRepository.getAllServices(token: token);
      setState(() {
        _services = services;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load services: $e')),
      );
    }
  }

  Future<void> _fetchVehicleDetails() async {
    setState(() {
      _vehicleLoading = true;
      _vehicleError = null;
    });
    try {
      final vehicle = await _authService.getVehicleById(
        customerId: widget.customerId,
        vehicleId: widget.vehicleId,
        token: widget.token ?? '',
      );
      setState(() {
        _vehicle = vehicle;
        _vehicleLoading = false;
      });
    } catch (e) {
      setState(() {
        _vehicleError = 'Failed to load vehicle details: $e';
        _vehicleLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timeIntervalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _createReminderSync() {
    _createReminder();
  }

  Future<DateTime> _getLastServiceDate(String serviceType) async {
    final history = await _serviceHistoryRepository
        .getServiceHistory(_vehicleId, token: _token);
    final matching = history
        .where((s) => s.serviceType.toLowerCase() == serviceType.toLowerCase())
        .toList();
    if (matching.isNotEmpty) {
      return matching.first.serviceDate;
    }
    return DateTime.now();
  }

  Future<void> _createReminder() async {
    // Validate inputs before proceeding
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service')),
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
      // Get last service date for the selected serviceType
      final lastServiceDate =
          await _getLastServiceDate(_selectedService!.serviceName);
      // Calculate reminder date (last service date + interval months)
      final reminderDate = lastServiceDate
          .add(Duration(days: intervalMonths * 30)); // Approximate

      // Create the new reminder model
      final newReminder = ServiceReminderModel(
        vehicleId: _vehicleId,
        serviceId: _selectedService!.serviceId,
        reminderDate: reminderDate,
        intervalMonths: intervalMonths,
        notifyBeforeDays: notifyDays,
        notes: _notesController.text.trim(),
        isActive: true,
      );

      // Save to backend
      print('Creating reminder: ${newReminder.toJson()}');
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
      body: _vehicleLoading
          ? const Center(child: CircularProgressIndicator())
          : _vehicleError != null
              ? Center(child: Text(_vehicleError!))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32.0),
                      // Vehicle Header
                      VehicleHeader(
                        vehicleName: _vehicle?['model'] ?? '',
                        vehicleId: _vehicle?['registrationNumber'] ?? '',
                      ),
                      const SizedBox(height: 48.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Additional vehicle details
                            Text(
                              'Vehicle Registration No: ${_vehicle?['registrationNumber'] ?? ''}',
                              style: AppTextStyles.textSmRegular.copyWith(
                                color: AppColors.neutral200,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'Vehicle Model: ${_vehicle?['model'] ?? ''}',
                              style: AppTextStyles.textSmRegular.copyWith(
                                color: AppColors.neutral200,
                              ),
                            ),
                            const SizedBox(height: 48.0),
                            // Service Name Input (now a dropdown)
                            Text(
                              'Service',
                              style: AppTextStyles.textSmRegular.copyWith(
                                color: AppColors.neutral100,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            DropdownButtonFormField<Service>(
                              value: _selectedService,
                              hint: Text(
                                'Select Service',
                                style: AppTextStyles.textSmSemibold.copyWith(
                                  color: AppColors.neutral200,
                                ),
                              ),
                              items: _services.map((Service service) {
                                return DropdownMenuItem<Service>(
                                  value: service,
                                  child: Text(
                                    service.serviceName,
                                    style: AppTextStyles.textSmRegular.copyWith(
                                      color: AppColors.neutral100,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (Service? newValue) {
                                setState(() {
                                  _selectedService = newValue;
                                });
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.transparent,
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: AppColors.neutral200),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: AppColors.neutral200),
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
                            const SizedBox(height: 16.0),
                            // Time Interval Input
                            InputFieldAtom(
                              state: InputFieldState.defaultState,
                              label: 'Time Interval (in Months)',
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
                                  borderSide: const BorderSide(
                                      color: AppColors.neutral200),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: AppColors.neutral200),
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
                            // Notes Input (optional)
                            InputFieldAtom(
                              state: InputFieldState.defaultState,
                              label: 'Notes (optional)',
                              placeholder: 'Add any notes for this reminder',
                              controller: _notesController,
                              onChanged: (value) {
                                setState(() {});
                              },
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
