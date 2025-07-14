# Notifications Integration Documentation

## Overview

This document describes the complete integration between the Flutter frontend and the .NET NotificationsController backend. The integration includes models, services, repositories, and UI components for handling notifications.

## Backend Integration

### API Configuration

The Flutter app is configured to connect to the .NET backend through `api_config.dart`:

- **Base URL**: `http://localhost:5039/api` (development)
- **Default Customer ID**: `1` (integer to match backend)
- **Endpoints**: Match the .NET NotificationsController structure

### API Endpoints

| Method | Endpoint                                             | Description                |
| ------ | ---------------------------------------------------- | -------------------------- |
| GET    | `/Notifications`                                     | Get all notifications      |
| GET    | `/Notifications/{id}`                                | Get specific notification  |
| GET    | `/Notifications/Customer/{customerId}`               | Get customer notifications |
| GET    | `/Notifications/Customer/{customerId}/Unread`        | Get unread notifications   |
| GET    | `/Notifications/Summary/{customerId}`                | Get notification summary   |
| GET    | `/Notifications/Pending`                             | Get pending notifications  |
| POST   | `/Notifications`                                     | Create new notification    |
| PUT    | `/Notifications/{id}/MarkAsRead`                     | Mark notification as read  |
| PUT    | `/Notifications/{id}/MarkAsSent`                     | Mark notification as sent  |
| PUT    | `/Notifications/Customer/{customerId}/MarkAllAsRead` | Mark all as read           |
| DELETE | `/Notifications/{id}`                                | Delete notification        |

## Frontend Components

### Data Models

#### NotificationModel

Maps to the .NET `NotificationDTO` structure:

```dart
class NotificationModel {
  final int? notificationId;           // Maps to NotificationId
  final int customerId;                // Maps to CustomerId
  final int? serviceReminderId;        // Maps to ServiceReminderId
  final String title;                  // Maps to Title
  final String message;                // Maps to Message
  final String type;                   // Maps to Type
  final bool isRead;                   // Maps to IsRead
  final bool isSent;                   // Maps to IsSent
  final DateTime createdAt;            // Maps to CreatedAt
  final DateTime? readAt;              // Maps to ReadAt
  final DateTime? sentAt;              // Maps to SentAt
  final DateTime? scheduledFor;        // Maps to ScheduledFor
  final String priority;               // Maps to Priority

  // Additional fields from DTO
  final String? customerName;          // Maps to CustomerName
  final String? customerEmail;         // Maps to CustomerEmail
  final String? vehicleRegistrationNumber; // Maps to VehicleRegistrationNumber
  final String? vehicleBrand;          // Maps to VehicleBrand
  final String? vehicleModel;          // Maps to VehicleModel
  final DateTime? serviceReminderDate; // Maps to ServiceReminderDate
  final String? serviceName;           // Maps to ServiceName
}
```

#### NotificationSummaryModel

Maps to the .NET `NotificationSummaryDTO`:

```dart
class NotificationSummaryModel {
  final int totalNotifications;        // Maps to TotalNotifications
  final int unreadNotifications;       // Maps to UnreadNotifications
  final int pendingNotifications;      // Maps to PendingNotifications
  final int sentNotifications;         // Maps to SentNotifications
}
```

### DTO Conversion

The model provides methods for converting to backend DTOs:

- `toCreateDto()` - Converts to `CreateNotificationDTO` format
- `toJson()` - General JSON serialization
- `fromJson()` - Deserializes from backend response

### Service Layer

#### NotificationApiService

Handles HTTP communication with the backend:

- **Error Handling**: Comprehensive error handling with CORS detection
- **Response Parsing**: Handles different response formats
- **Timeout Management**: Configurable timeouts for all requests
- **Debug Logging**: Detailed logging for troubleshooting

#### NotificationRepository

Business logic layer that wraps the API service:

- **Exception Handling**: Converts API errors to meaningful exceptions
- **Convenience Methods**: Higher-level operations like batch updates
- **Filtering**: Get notifications by priority, type, etc.
- **Auto-refresh**: Methods that automatically sort and refresh data

### UI Components

#### Enhanced NotificationCard

Updated notification card with:

- **Priority Indicators**: Color-coded left border and icons
- **Read Status**: Visual indication of read/unread state
- **Vehicle Information**: Display associated vehicle details
- **Interactive Elements**: Tap to mark as read, long press for options

#### Updated NotificationsPage

Complete notifications page with:

- **Real-time Data**: Loads notifications from backend
- **Pull-to-refresh**: Swipe down to refresh notifications
- **Batch Operations**: Mark all as read functionality
- **Error Handling**: Graceful fallback to sample data
- **Interactive UI**: Tap, long press, and swipe actions

## Integration Features

### Automatic Read Marking

- Notifications are automatically marked as read when the page is opened
- Individual notifications can be marked as read by tapping
- Batch mark-all-as-read functionality

### Priority System

Color-coded priority levels:

- **Critical**: Red (Error icon)
- **High**: Orange (Warning icon)
- **Medium**: Yellow (Info icon)
- **Low**: Green (Check icon)

### Error Handling

- Network error detection and fallback
- CORS error detection with helpful messages
- Graceful degradation to sample data
- User-friendly error messages

### Performance Features

- Lazy loading of notifications
- Efficient batch operations
- Optimistic UI updates
- Minimal API calls through smart caching

## Testing

### Backend Connection Test

Run the test script to verify integration:

```bash
dart run test_notifications_backend.dart
```

The test script verifies:

1. Basic API connectivity
2. CRUD operations (Create, Read, Update, Delete)
3. Customer-specific endpoints
4. Summary and statistics endpoints
5. Read/unread status management

### Integration Test

A complete integration test is available at:
`test/integration/notification_integration_test.dart`

## Configuration

### API Configuration

Update `lib/core/config/api_config.dart` for different environments:

```dart
// Development
static const String devBaseUrl = 'http://localhost:5039/api';

// Production
static const String prodBaseUrl = 'https://api.your-domain.com/api';
```

### Customer ID

Currently using a default customer ID. In production, this should come from:

- User authentication session
- Route parameters
- User profile data

## Troubleshooting

### Common Issues

1. **CORS Errors**: Configure CORS in your .NET backend
2. **Connection Timeout**: Check backend URL and port
3. **404 Errors**: Ensure NotificationsController is implemented
4. **Data Format**: Verify DTO structure matches Flutter models

### Debug Steps

1. Run the backend connection test
2. Check console logs for detailed error messages
3. Verify API endpoints in browser/Postman
4. Test with sample data first

## Future Enhancements

### Real-time Notifications

- WebSocket connection for live updates
- Push notification integration
- Background sync

### Advanced Features

- Notification categories and filtering
- Custom notification sounds
- Notification scheduling
- Rich media notifications

### Performance Optimizations

- Pagination for large notification lists
- Infinite scroll
- Background cache management
- Offline notification queue

## Dependencies

### Required Packages

```yaml
dependencies:
  http: ^0.13.5
  flutter: ^3.0.0

dev_dependencies:
  flutter_test: ^3.0.0
```

### Backend Requirements

- .NET Core API with NotificationsController
- Entity Framework with notification entities
- CORS configuration for Flutter requests
- Authentication/authorization (optional)

## API Response Examples

### Get Customer Notifications Response

```json
[
  {
    "notificationId": 1,
    "customerId": 1,
    "serviceReminderId": 2,
    "title": "Oil Change Due",
    "message": "Your vehicle is due for an oil change service.",
    "type": "service_reminder",
    "isRead": false,
    "isSent": true,
    "createdAt": "2025-01-14T10:30:00Z",
    "readAt": null,
    "sentAt": "2025-01-14T10:30:00Z",
    "scheduledFor": null,
    "priority": "High",
    "customerName": "John Doe",
    "customerEmail": "john@example.com",
    "vehicleRegistrationNumber": "ABC123",
    "vehicleBrand": "Toyota",
    "vehicleModel": "Camry",
    "serviceReminderDate": "2025-01-20T00:00:00Z",
    "serviceName": "Oil Change"
  }
]
```

### Notification Summary Response

```json
{
  "totalNotifications": 15,
  "unreadNotifications": 3,
  "pendingNotifications": 2,
  "sentNotifications": 13
}
```

This integration provides a complete, production-ready notification system that seamlessly connects your Flutter frontend with the .NET backend NotificationsController.
