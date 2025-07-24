class ApiConfig {
  // Backend API base URL
  // Change this to your actual backend URL
  static const String baseUrl = 'http://192.168.1.11:5039/api';

  // Alternative configurations for different environments
  static const String devBaseUrl = 'http://192.168.1.11:5039/api';
  static const String stagingBaseUrl =
      'https://staging-api.your-domain.com/api';
  static const String prodBaseUrl = 'https://api.your-domain.com/api';

  // Default vehicle ID for legacy/testing purposes only
  // TODO: Remove this and use dynamic vehicle data from authenticated user
  static const int defaultVehicleId = 1;

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

  // Emergency Call Center endpoints
  static const String emergencyCallCenterEndpoint = '/EmergencyCallCenter';

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

  // Add this method for PDF download endpoint
  static String getServiceHistoryPdfUrl(int vehicleId) =>
      '$currentBaseUrl/VehicleServiceHistory/Vehicle/$vehicleId/pdf';

  static String getServiceHistoryPdfPreviewUrl(int vehicleId) =>
      '$currentBaseUrl/pdf/vehicle-service-history/$vehicleId/preview';

  static String getServiceHistoryPdfDownloadUrl(int vehicleId) =>
      '$currentBaseUrl/pdf/vehicle-service-history/$vehicleId';

  // Fuel Efficiency URL builders
  static String getFuelEfficienciesByVehicleUrl(int vehicleId) =>
      '$currentBaseUrl/FuelEfficiency/vehicle/$vehicleId';

  static String getFuelEfficiencySummaryUrl(int vehicleId, {int? year}) =>
      '$currentBaseUrl/FuelEfficiency/vehicle/$vehicleId/summary${year != null ? '?year=$year' : ''}';

  static String getMonthlyChartDataUrl(int vehicleId, int year) =>
      '$currentBaseUrl/FuelEfficiency/vehicle/$vehicleId/chart/$year';

  static String addFuelEfficiencyUrl() => '$currentBaseUrl/FuelEfficiency';

  static String updateFuelEfficiencyUrl(int id) =>
      '$currentBaseUrl/FuelEfficiency/$id';

  static String deleteFuelEfficiencyUrl(int id) =>
      '$currentBaseUrl/FuelEfficiency/$id';

  static String getMonthlyFuelRecordsUrl(int vehicleId, int year, int month) =>
      '$currentBaseUrl/FuelEfficiency/vehicle/$vehicleId/monthly/$year/$month';

  static String getFuelForPeriodUrl(
          int vehicleId, DateTime startDate, DateTime endDate) =>
      '$currentBaseUrl/FuelEfficiency/vehicle/$vehicleId/period?startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}';

  static String getAverageFuelPerMonthUrl(int vehicleId, int year) =>
      '$currentBaseUrl/FuelEfficiency/vehicle/$vehicleId/average/$year';

  // Emergency Call Center URL methods
  static String getAllEmergencyCallCentersUrl() =>
      '$currentBaseUrl$emergencyCallCenterEndpoint';

  static String testConnectionUrl() => '$currentBaseUrl/test';
}
