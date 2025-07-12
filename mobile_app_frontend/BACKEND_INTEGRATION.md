# Backend Integration for Reminders

This document explains how the reminder functionality has been integrated with the backend API.

## Overview

The reminders feature now supports full CRUD operations with a backend API:

- Create new reminders
- Read/fetch existing reminders
- Update reminder details
- Delete reminders
- Update reminder status

## Architecture

### 1. Data Layer

- **Models**: `ReminderModel` - Handles data serialization/deserialization
- **Repository**: `ReminderRepository` - Abstracts API calls and provides data to UI
- **API Service**: `ReminderApiService` - Handles HTTP requests to backend

### 2. Configuration

- **ApiConfig**: Centralized configuration for API endpoints and environment settings

### 3. UI Integration

- **SetReminderPage**: Creates new reminders with backend persistence
- **ScheduledRemindersPage**: Displays reminders from backend with loading states

## API Endpoints

The app expects the following REST API endpoints:

### Reminders

- `GET /api/vehicles/{vehicleId}/reminders` - Get all reminders for a vehicle
- `POST /api/vehicles/{vehicleId}/reminders` - Create a new reminder
- `GET /api/reminders/{reminderId}` - Get specific reminder
- `PUT /api/reminders/{reminderId}` - Update reminder
- `DELETE /api/reminders/{reminderId}` - Delete reminder
- `PATCH /api/reminders/{reminderId}/status` - Update reminder status
- `GET /api/vehicles/{vehicleId}/reminders?status={status}` - Get reminders by status

### Expected JSON Format

#### Reminder Object

```json
{
  "id": "string",
  "vehicleId": "string",
  "title": "string",
  "description": "string",
  "status": "upcoming|overdue|completed|scheduled|inProgress|canceled",
  "nextDue": "string",
  "mileageInterval": "string (optional)",
  "timeInterval": "string",
  "lastServiceDate": "string (optional)",
  "notifyPeriod": "string",
  "createdAt": "ISO date string",
  "updatedAt": "ISO date string"
}
```

#### Create Reminder Request

```json
{
  "vehicleId": "AB89B395",
  "title": "Oil Change",
  "description": "Next: in 6 months",
  "status": "upcoming",
  "nextDue": "Next: in 6 months",
  "timeInterval": "6 months",
  "notifyPeriod": "7 days before"
}
```

#### Update Status Request

```json
{
  "status": "completed"
}
```

## Configuration

### Backend URL

Update the API base URL in `/lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  // Update these URLs to match your backend
  static const String devBaseUrl = 'http://localhost:3000/api';
  static const String stagingBaseUrl = 'https://staging-api.your-domain.com/api';
  static const String prodBaseUrl = 'https://api.your-domain.com/api';
}
```

### Environment Variables

You can also use environment variables:

```bash
flutter run --dart-define=ENVIRONMENT=dev
flutter run --dart-define=ENVIRONMENT=staging
flutter run --dart-define=ENVIRONMENT=prod
```

## Error Handling

The app includes comprehensive error handling:

1. **Network Errors**: Displays user-friendly error messages
2. **Fallback Data**: Shows sample data when backend is unavailable
3. **Loading States**: Shows loading indicators during API calls
4. **Retry Logic**: Allows users to retry failed operations

## Features

### SetReminderPage

- ✅ Form validation
- ✅ Loading state during creation
- ✅ Success/error messages
- ✅ Backend persistence
- ✅ Navigation with result

### ScheduledRemindersPage

- ✅ Load reminders from backend
- ✅ Loading indicators
- ✅ Empty state handling
- ✅ Error handling with fallback
- ✅ Delete functionality
- ✅ Refresh capability

## Dependencies

Added to `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.2.0 # For API calls
```

## Files Created/Modified

### New Files

- `/lib/data/models/reminder_model.dart` - Data model
- `/lib/data/repositories/reminder_repository.dart` - Repository pattern
- `/lib/core/services/reminder_api_service.dart` - API service
- `/lib/core/config/api_config.dart` - Configuration

### Modified Files

- `/lib/presentation/pages/set_reminder_page.dart` - Added backend integration
- `/lib/presentation/pages/scheduled_reminders.dart` - Added backend integration
- `/pubspec.yaml` - Added http dependency

## Testing

### Backend Testing

1. Start your backend server
2. Update the API URL in `ApiConfig`
3. Test creating, viewing, updating, and deleting reminders

### Offline Testing

The app gracefully handles backend unavailability by:

- Showing error messages
- Falling back to sample data
- Providing retry options

## Next Steps

1. **Authentication**: Add user authentication and authorization headers
2. **Caching**: Implement local caching for offline support
3. **Push Notifications**: Integrate with notification service for reminder alerts
4. **Sync**: Add data synchronization for offline/online scenarios
5. **Validation**: Add server-side validation and error handling
6. **Pagination**: Add pagination for large reminder lists

## Backend Requirements

Your backend should implement:

1. **CORS**: Enable cross-origin requests for Flutter web
2. **Authentication**: JWT or session-based auth (when implemented)
3. **Validation**: Input validation and error responses
4. **Database**: Persistent storage for reminders
5. **Error Handling**: Consistent error response format

Example error response format:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": ["Title is required", "Time interval must be a number"]
  }
}
```
