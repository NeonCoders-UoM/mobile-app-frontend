class ApiConfig {
  // Backend API base URL
  // Change this to your actual backend URL
  static const String baseUrl = 'http://localhost:5039/api';

  // Alternative configurations for different environments
  static const String devBaseUrl = 'http://localhost:5039/api';
  static const String stagingBaseUrl =
      'https://staging-api.your-domain.com/api';
  static const String prodBaseUrl = 'https://api.your-domain.com/api';

  // Default vehicle ID (in a real app, this would come from user session)
  static const int defaultVehicleId = 1; // Changed to int to match backend

  // API timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // API endpoints based on your .NET backend
  static const String serviceRemindersEndpoint = '/ServiceReminders';
  static const String vehicleRemindersEndpoint =
      '/ServiceReminders/Vehicle/{vehicleId}';
  static const String upcomingRemindersEndpoint = '/ServiceReminders/Upcoming';
  static const String reminderByIdEndpoint = '/ServiceReminders/{reminderId}';

  // Get the current environment's base URL
  static String get currentBaseUrl {
    // You can use environment variables or build configurations
    const environment =
        String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');

    switch (environment) {
      case 'dev':
        return devBaseUrl;
      case 'staging':
        return stagingBaseUrl;
      case 'prod':
        return prodBaseUrl;
      default:
        return baseUrl;
    }
  }

  // Build endpoint URLs based on your backend structure
  static String getAllRemindersUrl() => '$currentBaseUrl/ServiceReminders';

  static String getVehicleRemindersUrl(int vehicleId) =>
      '$currentBaseUrl/ServiceReminders/Vehicle/$vehicleId';

  static String getUpcomingRemindersUrl({int? days}) =>
      '$currentBaseUrl/ServiceReminders/Upcoming${days != null ? '?days=$days' : ''}';

  static String getReminderByIdUrl(int reminderId) =>
      '$currentBaseUrl/ServiceReminders/$reminderId';

  static String createReminderUrl() => '$currentBaseUrl/ServiceReminders';

  static String updateReminderUrl(int reminderId) =>
      '$currentBaseUrl/ServiceReminders/$reminderId';

  static String deleteReminderUrl(int reminderId) =>
      '$currentBaseUrl/ServiceReminders/$reminderId';
}
