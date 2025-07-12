# Type Conversion Error Troubleshooting

## Error Description

```
DartError: TypeError: Instance of 'IdentityMap<String, dynamic>': type 'IdentityMap<String, dynamic>' is not a subtype of type 'ServiceReminderModel'
```

## Root Cause

This error occurs when there's a mismatch between the expected data structure and the actual data returned from the backend API. The issue is typically caused by:

1. **Backend Response Format**: The API is returning a different JSON structure than expected
2. **Model Parsing Issues**: The `ServiceReminderModel.fromJson()` method can't parse the response
3. **Type Safety**: Dart's type system is detecting an invalid type conversion

## Troubleshooting Steps

### Step 1: Check Backend Response Format

The error suggests that the backend is returning an `IdentityMap` instead of a proper JSON object. This can happen when:

- The backend returns HTML error pages instead of JSON
- The API endpoint doesn't exist (404 error)
- The response is wrapped in an unexpected format

### Step 2: Verify API Endpoints

Make sure your .NET backend has the correct endpoints:

```csharp
[HttpGet("Vehicle/{vehicleId}")]
public async Task<ActionResult<IEnumerable<ServiceReminderDTO>>> GetVehicleServiceReminders(int vehicleId)
```

### Step 3: Check Network Response

Open browser developer tools and check:

1. **Network Tab**: Look at the actual API response
2. **Console**: Check for CORS or other network errors
3. **Response Body**: Verify it's valid JSON

### Step 4: Debug JSON Structure

The updated API service now includes debug logging. Check the console for:

```
API Response type: [actual type]
API Response: [actual data]
```

## Common Fixes

### Fix 1: CORS Configuration

If you see CORS errors, add this to your .NET `Program.cs`:

```csharp
builder.Services.AddCors();

var app = builder.Build();

app.UseCors(policy =>
{
    policy.AllowAnyOrigin()
          .AllowAnyMethod()
          .AllowAnyHeader();
});
```

### Fix 2: Check Backend Database

Ensure your database has:

- Vehicle with ID = 1 (or your configured defaultVehicleId)
- Service records
- ServiceReminders table with proper relationships

### Fix 3: Verify DTO Structure

Make sure your .NET DTO matches the Flutter model:

**.NET ServiceReminderDTO:**

```csharp
public class ServiceReminderDTO
{
    public int ServiceReminderId { get; set; }
    public int VehicleId { get; set; }
    public int ServiceId { get; set; }
    public DateTime ReminderDate { get; set; }
    public int IntervalMonths { get; set; }
    public int NotifyBeforeDays { get; set; }
    public string? Notes { get; set; }
    public bool IsActive { get; set; }
    public DateTime? CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public string? ServiceName { get; set; }
    public string? VehicleRegistrationNumber { get; set; }
    public string? VehicleBrand { get; set; }
    public string? VehicleModel { get; set; }
}
```

### Fix 4: Test with Sample Data

If the backend is not ready, you can test with mock data by setting:

```dart
// In dev_api_config.dart
static bool get useMockData => true;
```

## Updated Error Handling

The API service now includes:

1. **Response Type Checking**: Validates the response format
2. **Better Error Messages**: Specific error messages for different issues
3. **Debug Logging**: Console output to help identify issues
4. **Graceful Fallbacks**: Falls back to sample data when backend is unavailable

## Testing the Fix

1. **Check Console Output**: Look for debug messages about response types
2. **Test API Directly**: Use Postman to test your endpoints
3. **Verify Data Flow**: Ensure data flows from backend to frontend correctly

## Expected Console Output (Success)

```
Loading reminders for vehicle 1
getAllReminders Response type: List<dynamic>
Loaded 2 reminders
Reminder: Oil Change - 2025-08-11 00:00:00.000
Reminder: Annual Inspection - 2025-07-15 00:00:00.000
```

## Expected Console Output (Error)

```
API Response type: String
API Response: <!DOCTYPE html>...
Error parsing reminder JSON: FormatException: Invalid JSON
```

This debug information will help identify exactly what's going wrong with the data conversion.
