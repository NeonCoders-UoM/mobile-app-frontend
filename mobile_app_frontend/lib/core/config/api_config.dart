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

  // Service History endpoints - Updated to match VehicleServiceHistoryController
  static const String vehicleServiceHistoryEndpoint = '/VehicleServiceHistory';
  static const String vehicleServiceHistoryByVehicleEndpoint =
      '/VehicleServiceHistory/Vehicle/{vehicleId}';
  static const String vehicleServiceHistoryByIdEndpoint =
      '/VehicleServiceHistory/{vehicleId}/{serviceHistoryId}';
  static const String createVehicleServiceHistoryEndpoint =
      '/VehicleServiceHistory/{vehicleId}';
  static const String updateVehicleServiceHistoryEndpoint =
      '/VehicleServiceHistory/{vehicleId}/{serviceHistoryId}';
  static const String deleteVehicleServiceHistoryEndpoint =
      '/VehicleServiceHistory/{vehicleId}/{serviceHistoryId}';

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

  // Service History URL builders - Updated to match VehicleServiceHistoryController
  static String getVehicleServiceHistoryUrl(int vehicleId) =>
      '$currentBaseUrl/VehicleServiceHistory/Vehicle/$vehicleId';

  static String getServiceHistoryByIdUrl(int vehicleId, int serviceHistoryId) =>
      '$currentBaseUrl/VehicleServiceHistory/$vehicleId/$serviceHistoryId';

  static String createServiceHistoryUrl(int vehicleId) =>
      '$currentBaseUrl/VehicleServiceHistory/$vehicleId';

  static String updateServiceHistoryUrl(int vehicleId, int serviceHistoryId) =>
      '$currentBaseUrl/VehicleServiceHistory/$vehicleId/$serviceHistoryId';

  static String deleteServiceHistoryUrl(int vehicleId, int serviceHistoryId) =>
      '$currentBaseUrl/VehicleServiceHistory/$vehicleId/$serviceHistoryId';

  // Alternative method names for consistency with repository usage
  static String createVehicleServiceHistoryUrl(int vehicleId) =>
      createServiceHistoryUrl(vehicleId);

  static String updateVehicleServiceHistoryUrl(
          int vehicleId, int serviceHistoryId) =>
      updateServiceHistoryUrl(vehicleId, serviceHistoryId);

  static String deleteVehicleServiceHistoryUrl(
          int vehicleId, int serviceHistoryId) =>
      deleteServiceHistoryUrl(vehicleId, serviceHistoryId);

  static String getVehicleServiceHistoryByIdUrl(
          int vehicleId, int serviceHistoryId) =>
      getServiceHistoryByIdUrl(vehicleId, serviceHistoryId);
}
