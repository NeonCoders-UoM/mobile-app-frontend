# Service Reminders Integration Documentation

## Overview

This document describes the integration between the Flutter mobile app frontend and the .NET backend for service reminders functionality. The integration has been completed to match the backend's `ServiceRemindersController` structure and endpoints.

## Backend Integration

### API Configuration

The Flutter app is configured to connect to the .NET backend through `api_config.dart`:

- **Base URL**: `http://192.168.8.186:5039/api` (development)
- **Default Vehicle ID**: `1` (integer to match backend)
- **Endpoints**: Match the .NET controller structure

### Endpoint Mapping

| Frontend Method                  | Backend Endpoint                                 | Description                        |
| -------------------------------- | ------------------------------------------------ | ---------------------------------- |
| `getAllReminders()`              | `GET /api/ServiceReminders`                      | Get all service reminders          |
| `getVehicleReminders(vehicleId)` | `GET /api/ServiceReminders/Vehicle/{vehicleId}`  | Get reminders for specific vehicle |
| `getUpcomingReminders(days?)`    | `GET /api/ServiceReminders/Upcoming?days={days}` | Get upcoming reminders             |
| `getReminder(id)`                | `GET /api/ServiceReminders/{id}`                 | Get specific reminder              |
| `createReminder(reminder)`       | `POST /api/ServiceReminders`                     | Create new reminder                |
| `updateReminder(id, reminder)`   | `PUT /api/ServiceReminders/{id}`                 | Update existing reminder           |
| `deleteReminder(id)`             | `DELETE /api/ServiceReminders/{id}`              | Delete reminder                    |

## Data Models

### ServiceReminderModel

The Flutter model (`ServiceReminderModel`) matches the .NET `ServiceReminderDTO`:

```dart
class ServiceReminderModel {
  final int? serviceReminderId;      // Maps to ServiceReminderId
  final int vehicleId;               // Maps to VehicleId
  final int serviceId;               // Maps to ServiceId
  final DateTime reminderDate;       // Maps to ReminderDate
  final int intervalMonths;          // Maps to IntervalMonths
  final int notifyBeforeDays;        // Maps to NotifyBeforeDays
  final String? notes;               // Maps to Notes
  final bool isActive;               // Maps to IsActive
  final DateTime? createdAt;         // Maps to CreatedAt
  final DateTime? updatedAt;         // Maps to UpdatedAt

  // Additional fields from DTO
  final String? serviceName;                 // Maps to ServiceName
  final String? vehicleRegistrationNumber;   // Maps to VehicleRegistrationNumber
  final String? vehicleBrand;               // Maps to VehicleBrand
  final String? vehicleModel;               // Maps to VehicleModel
}
```

### DTO Conversion

The model provides methods for converting to backend DTOs:

- `toCreateDto()` - Converts to `CreateServiceReminderDTO` format
- `toUpdateDto()` - Converts to `UpdateServiceReminderDTO` format
- `toJson()` - General JSON serialization
- `fromJson()` - Deserializes from backend response

## File Structure

### Core Files

- `lib/core/config/api_config.dart` - API configuration and endpoint URLs
- `lib/core/services/reminder_api_service.dart` - HTTP service layer
- `lib/data/models/reminder_model.dart` - Data model matching backend DTO
- `lib/data/repositories/reminder_repository.dart` - Repository pattern implementation

### UI Pages

- `lib/presentation/pages/set_reminder_page.dart` - Create new reminders
- `lib/presentation/pages/scheduled_reminders.dart` - View and manage reminders

### Tests

- `test/integration/reminder_integration_test.dart` - Integration tests with backend

## Key Features

### 1. Set Reminder Page

- **Service Name Input**: Free text input for service name
- **Time Interval**: Months between services
- **Notify Period**: Days before reminder date to notify
- **Notes**: Optional additional information
- **Backend Integration**: Creates reminders via API

### 2. Scheduled Reminders Page

- **List View**: Displays all reminders for the vehicle
- **Status Indicators**: Shows overdue, upcoming, and scheduled status
- **Real-time Data**: Fetches from backend API
- **Delete Functionality**: Removes reminders via API

### 3. Error Handling

- **Network Errors**: Graceful fallback to sample data
- **Validation**: Input validation before API calls
- **User Feedback**: Success/error messages for all operations

## Running the Integration

### Prerequisites

1. .NET backend running on `http://192.168.8.186:5039`
2. Database with Vehicle and Service tables populated
3. Flutter development environment set up

### Steps

1. **Start Backend**: Ensure your .NET API is running
2. **Configure Frontend**: Update `api_config.dart` if needed
3. **Run Flutter App**: `flutter run`
4. **Test Integration**: Run integration tests or use the UI

### Testing

```bash
# Run integration tests
flutter test test/integration/reminder_integration_test.dart

# Run all tests
flutter test
```

## Backend Requirements

For the integration to work properly, ensure your .NET backend has:

1. **Vehicle Table**: With at least one vehicle with ID = 1
2. **Service Table**: With service types (ID = 1 for testing)
3. **ServiceReminders Table**: For storing reminders
4. **CORS Configuration**: Allow requests from Flutter app
5. **Running Service**: API accessible on configured port

## Error Scenarios

The app handles these error scenarios:

1. **Backend Unavailable**: Shows offline data with retry option
2. **Invalid Vehicle ID**: Returns appropriate error message
3. **Missing Service**: Validation prevents invalid service IDs
4. **Network Issues**: Graceful degradation with user feedback

## Future Enhancements

Potential improvements for the integration:

1. **Service Dropdown**: Fetch available services from backend
2. **Vehicle Selection**: Multi-vehicle support
3. **Push Notifications**: Real reminder notifications
4. **Offline Sync**: Local storage with sync capabilities
5. **Authentication**: User-based reminder management

## Troubleshooting

### Common Issues

1. **Connection Refused**: Check if backend is running on correct port
2. **CORS Errors**: Ensure backend allows cross-origin requests
3. **404 Errors**: Verify endpoint URLs match controller routes
4. **Data Format Errors**: Check model serialization/deserialization

### Debug Steps

1. Check backend logs for API call details
2. Enable Flutter HTTP logging for request/response inspection
3. Verify database has required data (vehicles, services)
4. Test API endpoints directly with tools like Postman

## Conclusion

The frontend is now fully integrated with the .NET backend for service reminders. The integration follows REST API best practices and provides a robust, user-friendly interface for managing vehicle service reminders.
