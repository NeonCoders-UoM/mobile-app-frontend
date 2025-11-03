import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/data/models/service_history_model.dart';
import 'package:mobile_app_frontend/data/repositories/service_history_repository.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/vehicle_header.dart';
import 'package:mobile_app_frontend/data/repositories/reminder_repository.dart';

class EditServiceHistoryPage extends StatefulWidget {
  final ServiceHistoryModel service;
  final String vehicleName;
  final String vehicleRegistration;
  final String? token;

  const EditServiceHistoryPage({
    Key? key,
    required this.service,
    required this.vehicleName,
    required this.vehicleRegistration,
    this.token,
  }) : super(key: key);

  @override
  _EditServiceHistoryPageState createState() => _EditServiceHistoryPageState();
}

class _EditServiceHistoryPageState extends State<EditServiceHistoryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _serviceTitleController;
  late TextEditingController _serviceDescriptionController;
  late TextEditingController _serviceProviderController;
  late TextEditingController _locationController;
  late TextEditingController _costController;
  late TextEditingController _notesController;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  final ServiceHistoryRepository _serviceHistoryRepository =
      ServiceHistoryRepository();
  final List<String> _commonServices = [
    'Oil Change',
    'Brake Service',
    'Tire Replacement',
    'Air Filter Replacement',
    'Battery Replacement',
    'Transmission Service',
    'Coolant Flush',
    'Wheel Alignment',
    'Engine Diagnostic',
    'Spark Plug Replacement',
    'Belt Replacement',
    'Suspension Repair',
    'Exhaust Repair',
    'AC Service',
    'Custom Service',
  ];
  String? _selectedServiceType;

  @override
  void initState() {
    super.initState();
    _selectedServiceType = widget.service.serviceType;
    _serviceTitleController =
        TextEditingController(text: widget.service.serviceType);
    _serviceDescriptionController =
        TextEditingController(text: widget.service.description);
    _serviceProviderController = TextEditingController(
        text: widget.service.externalServiceCenterName ??
            widget.service.serviceCenterName ??
            '');
    _locationController = TextEditingController(); // Not in model, left blank
    _costController =
        TextEditingController(text: widget.service.cost?.toString() ?? '');
    _notesController = TextEditingController(text: widget.service.notes ?? '');
    _selectedDate = widget.service.serviceDate;
  }

  @override
  void dispose() {
    _serviceTitleController.dispose();
    _serviceDescriptionController.dispose();
    _serviceProviderController.dispose();
    _locationController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary200,
              onPrimary: AppColors.neutral100,
              surface: AppColors.neutral400,
              onSurface: AppColors.neutral100,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Future<void> _updateService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      double? cost;
      if (_costController.text.trim().isNotEmpty) {
        cost = double.tryParse(_costController.text.trim());
        if (cost == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid cost amount'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      String serviceTitle = _selectedServiceType == 'Custom Service'
          ? _serviceTitleController.text.trim()
          : _selectedServiceType ?? _serviceTitleController.text.trim();
      final updatedService = widget.service.copyWith(
        serviceType: serviceTitle,
        description: _serviceDescriptionController.text.trim(),
        serviceDate: _selectedDate,
        externalServiceCenterName: _serviceProviderController.text.trim(),
        cost: cost,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      final success = await _serviceHistoryRepository
          .updateService(updatedService, token: widget.token);
      if (success) {
        // Remove matching reminder(s) after service completion
        try {
          final reminderRepo = ReminderRepository();
          final reminders = await reminderRepo.getVehicleReminders(
              widget.service.vehicleId,
              token: widget.token);
          final matchingReminders = reminders.where((reminder) =>
              (reminder.serviceName != null &&
                  reminder.serviceName!.toLowerCase().trim() ==
                      serviceTitle.toLowerCase().trim()));
          for (final reminder in matchingReminders) {
            if (reminder.serviceReminderId != null) {
              await reminderRepo.deleteReminder(reminder.serviceReminderId!,
                  token: widget.token);
            }
          }
        } catch (e) {
          // Optionally log or show error, but don't block service update
          print('Error removing matching reminders: $e');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service record updated!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update service record. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
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
        title: 'Edit Service Record',
        showTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32.0),
            VehicleHeader(
              vehicleName: widget.vehicleName,
              vehicleId: widget.vehicleRegistration,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48.0),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.neutral300,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: AppColors.neutral200),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.primary200,
                            size: 24.0,
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Text(
                              'Edit your service record details below. Changes will be saved to your service history.',
                              style: AppTextStyles.textSmRegular.copyWith(
                                color: AppColors.neutral100,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    Text(
                      'Service Type',
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral100,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    DropdownButtonFormField<String>(
                      value: _commonServices.contains(_selectedServiceType)
                          ? _selectedServiceType
                          : null,
                      hint: Text(
                        'Select service type',
                        style: AppTextStyles.textSmSemibold.copyWith(
                          color: AppColors.neutral200,
                        ),
                      ),
                      items: _commonServices.map((String service) {
                        return DropdownMenuItem<String>(
                          value: service,
                          child: Text(
                            service,
                            style: AppTextStyles.textSmRegular.copyWith(
                              color: AppColors.neutral100,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedServiceType = newValue;
                          if (newValue != 'Custom Service') {
                            _serviceTitleController.text = newValue ?? '';
                          }
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a service type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    if (_selectedServiceType == 'Custom Service') ...[
                      Text(
                        'Custom Service Title',
                        style: AppTextStyles.textSmRegular.copyWith(
                          color: AppColors.neutral100,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: _serviceTitleController,
                        style: AppTextStyles.textSmRegular.copyWith(
                          color: AppColors.neutral100,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter custom service name',
                          hintStyle: AppTextStyles.textSmRegular.copyWith(
                            color: AppColors.neutral200,
                          ),
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
                        validator: (value) {
                          if (_selectedServiceType == 'Custom Service' &&
                              (value == null || value.isEmpty)) {
                            return 'Please enter a service title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                    ],
                    Text(
                      'Service Description',
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral100,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _serviceDescriptionController,
                      maxLines: 3,
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral100,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Describe what was done (e.g., Changed engine oil, replaced filters)',
                        hintStyle: AppTextStyles.textSmRegular.copyWith(
                          color: AppColors.neutral200,
                        ),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a service description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Service Provider',
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral100,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _serviceProviderController,
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral100,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter service center or mechanic name',
                        hintStyle: AppTextStyles.textSmRegular.copyWith(
                          color: AppColors.neutral200,
                        ),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the service provider name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Service Date',
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral100,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 16.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.neutral200),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDate(_selectedDate),
                              style: AppTextStyles.textSmRegular.copyWith(
                                color: AppColors.neutral100,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.neutral200,
                              size: 20.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Cost (Optional)',
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral100,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _costController,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral100,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter service cost (e.g., 5000)',
                        hintStyle: AppTextStyles.textSmRegular.copyWith(
                          color: AppColors.neutral200,
                        ),
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
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Additional Notes (Optional)',
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral100,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 2,
                      style: AppTextStyles.textSmRegular.copyWith(
                        color: AppColors.neutral100,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Any additional information about the service',
                        hintStyle: AppTextStyles.textSmRegular.copyWith(
                          color: AppColors.neutral200,
                        ),
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
                    ),
                    const SizedBox(height: 32.0),
                    CustomButton(
                      label: _isLoading ? 'Saving...' : 'Save Changes',
                      type: ButtonType.primary,
                      size: ButtonSize.large,
                      customWidth: double.infinity,
                      onTap: _isLoading ? () {} : _updateService,
                    ),
                    const SizedBox(height: 16.0),
                    CustomButton(
                      label: 'Cancel',
                      type: ButtonType.secondary,
                      size: ButtonSize.large,
                      customWidth: double.infinity,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 32.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
