/// Development configuration for testing without CORS issues
/// This can be used when the backend CORS is not yet configured
class DevApiConfig {
  // Alternative approach: Use a proxy or different backend URL
  static const String proxyBaseUrl =
      'http://localhost:3001/api'; // If you set up a proxy

  // For development, you might want to use a different approach
  static bool get useMockData =>
      false; // Set to true to use mock data instead of API calls

  // Mock data for development when backend is not available
  static const List<Map<String, dynamic>> mockReminders = [
    {
      'serviceReminderId': 1,
      'vehicleId': 1,
      'serviceId': 1,
      'reminderDate': '2025-08-11T00:00:00Z',
      'intervalMonths': 6,
      'notifyBeforeDays': 7,
      'notes': 'Regular oil change service',
      'isActive': true,
      'createdAt': '2025-07-11T10:00:00Z',
      'updatedAt': null,
      'serviceName': 'Oil Change',
      'vehicleRegistrationNumber': 'ABC123',
      'vehicleBrand': 'Ford',
      'vehicleModel': 'Mustang'
    },
    {
      'serviceReminderId': 2,
      'vehicleId': 1,
      'serviceId': 2,
      'reminderDate': '2025-07-15T00:00:00Z', // Overdue
      'intervalMonths': 12,
      'notifyBeforeDays': 14,
      'notes': 'Annual inspection required',
      'isActive': true,
      'createdAt': '2025-07-11T10:00:00Z',
      'updatedAt': null,
      'serviceName': 'Annual Inspection',
      'vehicleRegistrationNumber': 'ABC123',
      'vehicleBrand': 'Ford',
      'vehicleModel': 'Mustang'
    }
  ];

  // Development instructions
  static String get corsInstructions => '''
CORS Configuration Required!

Your .NET backend needs CORS configuration to allow requests from Flutter web.

Quick fix for development:
1. Add this to your Program.cs before app.UseRouting():

app.UseCors(policy =>
{
    policy.AllowAnyOrigin()
          .AllowAnyMethod()
          .AllowAnyHeader();
});

2. Make sure you have: builder.Services.AddCors(); in your service configuration.

3. Restart your backend and try again.

See CORS_SETUP.md for detailed instructions.
  ''';
}
