import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/data/models/reminder_model.dart';
import 'package:mobile_app_frontend/data/repositories/reminder_repository.dart';
import 'package:mobile_app_frontend/core/config/api_config.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/add_reminders_button.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/reminder_details_dialog.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/service_reminder_card.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/vehicle_header.dart';
import 'package:mobile_app_frontend/presentation/pages/set_reminder_page.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({Key? key}) : super(key: key);

  @override
  _RemindersPageState createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  List<ServiceReminderModel> reminders = [];
  bool _isLoading = true;
  String? _error;
  int _refreshCount = 0; // Add refresh counter for ListView key

  // Repository
  final ReminderRepository _reminderRepository = ReminderRepository();

  // Vehicle ID - In a real app, this would come from user session or route parameters
  final int _vehicleId = ApiConfig.defaultVehicleId;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    print('=== _loadReminders called ===');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Loading reminders for vehicle $_vehicleId');
      final List<ServiceReminderModel> reminderModels =
          await _reminderRepository.getVehicleReminders(_vehicleId);

      print('Loaded ${reminderModels.length} reminders from backend');
      for (var reminder in reminderModels) {
        print(
            'Reminder: ${reminder.notes ?? reminder.serviceName} - ${reminder.reminderDate} - ID: ${reminder.serviceReminderId}');
        print('  Notes (Service Name): ${reminder.notes}');
        print('  ServiceId: ${reminder.serviceId}');
        print('  VehicleId: ${reminder.vehicleId}');
        print('  IsActive: ${reminder.isActive}');
      }

      // Force UI rebuild by creating a new list instance
      final newReminders = List<ServiceReminderModel>.from(reminderModels);

      setState(() {
        reminders = newReminders;
        _isLoading = false;
        _refreshCount++; // Increment refresh counter to force ListView rebuild
      });
      print('State updated with ${reminders.length} reminders');
    } catch (e) {
      print('Error loading reminders: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _refreshCount++; // Increment refresh counter
        // Fallback to sample data if backend is not available
        reminders = _getSampleReminders();
      });
      print('Using fallback sample data with ${reminders.length} reminders');
    }
    print('=== _loadReminders completed ===');
  }

  // Pull-to-refresh functionality
  Future<void> _handleRefresh() async {
    print('Pull-to-refresh triggered');
    await _loadReminders();
  }

  List<ServiceReminderModel> _getSampleReminders() {
    return [
      ServiceReminderModel(
        serviceReminderId: null,
        vehicleId: _vehicleId,
        serviceId: 1,
        reminderDate: DateTime.now().add(const Duration(days: 30)),
        intervalMonths: 6,
        notifyBeforeDays: 7,
        notes: 'Oil Change Service',
        isActive: true,
        serviceName: 'Oil Change',
      ),
      ServiceReminderModel(
        serviceReminderId: null,
        vehicleId: _vehicleId,
        serviceId: 2,
        reminderDate: DateTime.now().subtract(const Duration(days: 5)),
        intervalMonths: 6,
        notifyBeforeDays: 7,
        notes: 'Tire Rotation & Alignment',
        isActive: true,
        serviceName: 'Tire Rotation',
      ),
      ServiceReminderModel(
        serviceReminderId: null,
        vehicleId: _vehicleId,
        serviceId: 3,
        reminderDate: DateTime.now().add(const Duration(days: 15)),
        intervalMonths: 12,
        notifyBeforeDays: 14,
        notes: 'Brake System Inspection',
        isActive: true,
        serviceName: 'Brake Inspection',
      ),
    ];
  }

  Future<void> _deleteReminder(int index) async {
    final reminder = reminders[index];
    final reminderId = reminder.serviceReminderId;

    if (reminderId != null) {
      try {
        await _reminderRepository.deleteReminder(reminderId);

        // Refresh the entire list from backend to ensure consistency
        await _loadReminders();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reminder deleted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete reminder: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      // Handle local-only reminders (fallback data)
      setState(() {
        reminders.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample reminder removed!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Helper methods for generating UI-friendly information
  String _generateDescription(ServiceReminderModel reminder) {
    // Since we're using notes as the title, show date-based description with interval info
    final daysUntilDue =
        reminder.reminderDate.difference(DateTime.now()).inDays;

    String dueDateInfo;
    if (daysUntilDue < 0) {
      dueDateInfo = 'Overdue by ${-daysUntilDue} days';
    } else if (daysUntilDue == 0) {
      dueDateInfo = 'Due today';
    } else {
      dueDateInfo = 'Due in $daysUntilDue days';
    }

    // Add interval information
    return '$dueDateInfo • Every ${reminder.intervalMonths} months';
  }

  ServiceStatus _getStatusFromDate(ServiceReminderModel reminder) {
    final now = DateTime.now();
    final daysUntilDue = reminder.reminderDate.difference(now).inDays;

    if (daysUntilDue < 0) {
      return ServiceStatus.overdue;
    } else if (daysUntilDue <= reminder.notifyBeforeDays) {
      return ServiceStatus.upcoming;
    } else {
      return ServiceStatus.upcoming;
    }
  }

  String _generateNextDue(ServiceReminderModel reminder) {
    final daysUntilDue =
        reminder.reminderDate.difference(DateTime.now()).inDays;
    if (daysUntilDue < 0) {
      return 'Overdue by ${-daysUntilDue} days';
    } else if (daysUntilDue == 0) {
      return 'Due today';
    } else {
      return 'Due in $daysUntilDue days';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: const CustomAppBar(
        title: 'Reminders',
        showTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary200),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading reminders',
                        style: TextStyle(color: AppColors.neutral100),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Using offline data',
                        style: TextStyle(
                            color: AppColors.neutral200, fontSize: 12),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadReminders,
                        child: const Text('Retry'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          // Show error details for debugging
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Error Details'),
                              content: SingleChildScrollView(
                                child: Text(_error ?? 'Unknown error'),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Show Error Details'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: _buildRemindersList(),
                ),
    );
  }

  Widget _buildRemindersList() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32.0),
          const VehicleHeader(
            vehicleName: 'Mustang 1977',
            vehicleId: 'AB89B395',
          ),
          const SizedBox(height: 48.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: AddReminderButton(
              onPressed: () async {
                print('Add Reminder button pressed');
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SetReminderPage()),
                );

                print('Returned from SetReminderPage with result: $result');

                // If a reminder was successfully created, refresh the list
                if (result == true) {
                  print('Reminder created successfully, refreshing list...');

                  // Add a small delay to ensure backend processing is complete
                  await Future.delayed(const Duration(milliseconds: 500));

                  await _loadReminders(); // Refresh the entire list from backend
                  print('List refreshed after adding reminder');

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reminder added successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  print('No result returned or reminder creation failed');
                }
              },
            ),
          ),
          const SizedBox(height: 32.0),
          reminders.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 64,
                          color: AppColors.neutral200,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No reminders yet',
                          style: TextStyle(
                            color: AppColors.neutral100,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first reminder to get started',
                          style: TextStyle(
                            color: AppColors.neutral200,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  key: ValueKey(
                      'reminders_${reminders.length}_$_refreshCount'), // Force rebuild with refresh counter
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    final reminderMap =
                        reminder.toMap(); // Convert to Map for UI compatibility

                    return ServiceReminderCard(
                      title: reminder.notes?.isNotEmpty == true
                          ? reminder.notes!
                          : reminder.serviceName ?? 'Service Reminder',
                      description: _generateDescription(reminder),
                      status: _getStatusFromDate(reminder),
                      onTap: () async {
                        // Show the dialog and wait for a result
                        final result = await showDialog<Map<String, dynamic>>(
                          context: context,
                          builder: (context) => ReminderDetailsDialog(
                            title: reminder.notes?.isNotEmpty == true
                                ? reminder.notes!
                                : reminder.serviceName ?? 'Service Reminder',
                            nextDue: _generateNextDue(reminder),
                            status: _getStatusFromDate(reminder),
                            mileageInterval:
                                'Every ${reminder.intervalMonths} months',
                            timeInterval: '${reminder.intervalMonths} months',
                            lastServiceDate: 'Not available',
                            reminder: reminderMap, // Pass the map version
                            index: index, // Pass the index
                            onEdit:
                                () {}, // Not used anymore, but required by the constructor
                            onDelete: () {
                              _deleteReminder(index);
                              Navigator.pop(context);
                            },
                          ),
                        );

                        // If a result is returned (from EditReminderPage), refresh the list
                        if (result != null) {
                          await _loadReminders(); // Refresh from backend
                        }
                      },
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 4.0),
                ),
        ],
      ),
    );
  }
}
