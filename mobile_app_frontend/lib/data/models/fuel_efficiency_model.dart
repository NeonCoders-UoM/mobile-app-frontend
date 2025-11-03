class FuelEfficiencyModel {
  final int?
      fuelEfficiencyId; // Primary key (matches FuelEfficiencyDTO.FuelEfficiencyId)
  final int vehicleId; // matches FuelEfficiencyDTO.VehicleId
  final DateTime date; // matches FuelEfficiencyDTO.Date (renamed from fuelDate)
  final double fuelAmount; // matches FuelEfficiencyDTO.FuelAmount (in liters)
  final DateTime createdAt; // matches FuelEfficiencyDTO.CreatedAt

  // Extra properties for future use (not in current backend DTO)
  final int? odometer;
  final String? location;
  final String? fuelType;
  final String? notes;
  final DateTime? updatedAt;

  FuelEfficiencyModel({
    this.fuelEfficiencyId,
    required this.vehicleId,
    required this.date, // renamed from fuelDate to match backend
    required this.fuelAmount,
    DateTime? createdAt,
    // Optional properties
    this.odometer,
    this.location,
    this.fuelType,
    this.notes,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert from JSON response - matches FuelEfficiencyDTO structure exactly
  factory FuelEfficiencyModel.fromJson(Map<String, dynamic> json) {
    return FuelEfficiencyModel(
      fuelEfficiencyId: json['fuelEfficiencyId'] ?? json['FuelEfficiencyId'],
      vehicleId: (json['vehicleId'] ?? json['VehicleId'] ?? 0),
      // Backend uses 'Date' property (not 'FuelDate')
      date: json['date'] != null || json['Date'] != null
          ? DateTime.parse(json['date'] ?? json['Date'])
          : DateTime.now(),
      fuelAmount: ((json['fuelAmount'] ?? json['FuelAmount']) ?? 0).toDouble(),
      createdAt: json['createdAt'] != null || json['CreatedAt'] != null
          ? DateTime.parse(json['createdAt'] ?? json['CreatedAt'])
          : DateTime.now(),
      // Optional properties (not in current backend DTO)
      odometer: json['odometer'] ?? json['Odometer'],
      location: (json['location'] ?? json['Location'])?.toString(),
      fuelType: (json['fuelType'] ?? json['FuelType'])?.toString(),
      notes: (json['notes'] ?? json['Notes'])?.toString(),
      updatedAt: json['updatedAt'] != null || json['UpdatedAt'] != null
          ? DateTime.parse(json['updatedAt'] ?? json['UpdatedAt'])
          : null,
    );
  }

  // Convert to JSON for API calls - matches FuelEfficiencyDTO structure
  Map<String, dynamic> toJson() {
    return {
      'FuelEfficiencyId': fuelEfficiencyId, // Matches FuelEfficiencyDTO
      'VehicleId': vehicleId, // Matches FuelEfficiencyDTO
      'Date': _formatDateForBackend(
          date), // Matches FuelEfficiencyDTO (not FuelDate)
      'FuelAmount': fuelAmount, // Matches FuelEfficiencyDTO
      'CreatedAt':
          _formatDateForBackend(createdAt), // Matches FuelEfficiencyDTO
      // Optional properties (not in current DTO but included for future use)
      'Odometer': odometer,
      'Location': location,
      'FuelType': fuelType,
      'Notes': notes,
      'UpdatedAt': updatedAt != null ? _formatDateForBackend(updatedAt!) : null,
    };
  }

  // Convert to JSON for CREATE requests - matches AddFuelEfficiencyDTO exactly
  Map<String, dynamic> toCreateJson() {
    return {
      'VehicleId': vehicleId, // Required in AddFuelEfficiencyDTO
      'FuelAmount': fuelAmount, // Required in AddFuelEfficiencyDTO
      'Date': _formatDateForBackend(date), // Required in AddFuelEfficiencyDTO
      'Cost': 0.01, // Required by backend validation (Cost > 0), using minimal value since cost tracking was removed
    };
  }

  // Helper method to format date for .NET backend compatibility
  String _formatDateForBackend(DateTime date) {
    // .NET DateTime.Parse works best with this format: yyyy-MM-ddTHH:mm:ss.fffZ
    // Or yyyy-MM-ddTHH:mm:ss for local time interpretation

    // Try format that .NET definitely understands
    final utcDate = date.isUtc ? date : date.toUtc();

    // Format: 2024-07-13T14:30:15.123Z (standard ISO with Z for UTC)
    return utcDate.toIso8601String();
  }

  // Convert to JSON for UPDATE requests - matches your backend structure
  Map<String, dynamic> toUpdateJson() {
    return {
      'Date': _formatDateForBackend(date), // Matches your DTO (not FuelDate)
      'FuelAmount': fuelAmount, // Matches your DTO
      'Odometer': odometer,
      'Location': location,
      'FuelType': fuelType,
      'Notes': notes,
    };
  }

  // Create a copy with updated fields
  FuelEfficiencyModel copyWith({
    int? fuelEfficiencyId,
    int? vehicleId,
    DateTime? date, // renamed from fuelDate to match backend
    double? fuelAmount,
    int? odometer,
    String? location,
    String? fuelType,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FuelEfficiencyModel(
      fuelEfficiencyId: fuelEfficiencyId ?? this.fuelEfficiencyId,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date, // using date instead of fuelDate
      fuelAmount: fuelAmount ?? this.fuelAmount,
      odometer: odometer ?? this.odometer,
      location: location ?? this.location,
      fuelType: fuelType ?? this.fuelType,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods for backward compatibility with existing UI
  DateTime get fuelDate => date; // For backward compatibility
  double get amount => fuelAmount;
}

// DTO for fuel efficiency summary - matches FuelEfficiencySummaryDTO
class FuelEfficiencySummaryModel {
  final int vehicleId;
  final String vehicleRegistrationNumber;
  final List<MonthlyFuelSummaryModel> monthlySummary;
  final double totalFuelThisYear;
  final double averageMonthlyFuel;

  FuelEfficiencySummaryModel({
    required this.vehicleId,
    required this.vehicleRegistrationNumber,
    required this.monthlySummary,
    required this.totalFuelThisYear,
    required this.averageMonthlyFuel,
  });

  factory FuelEfficiencySummaryModel.fromJson(Map<String, dynamic> json) {
    return FuelEfficiencySummaryModel(
      vehicleId: json['vehicleId'] ?? json['VehicleId'] ?? 0,
      vehicleRegistrationNumber: (json['vehicleRegistrationNumber'] ??
              json['VehicleRegistrationNumber'] ??
              '')
          .toString(),
      monthlySummary:
          ((json['monthlySummary'] ?? json['MonthlySummary']) as List<dynamic>?)
                  ?.map((item) => MonthlyFuelSummaryModel.fromJson(item))
                  .toList() ??
              [],
      totalFuelThisYear:
          (json['totalFuelThisYear'] ?? json['TotalFuelThisYear'] ?? 0)
              .toDouble(),
      averageMonthlyFuel:
          (json['averageMonthlyFuel'] ?? json['AverageMonthlyFuel'] ?? 0)
              .toDouble(),
    );
  }

  // Computed properties for UI compatibility (since your backend doesn't provide these)
  double get totalFuelAmount => totalFuelThisYear;
  int get totalRecords =>
      monthlySummary.fold(0, (sum, month) => sum + month.recordCount);
}

// DTO for monthly chart data - matches MonthlyFuelSummaryDTO
class MonthlyFuelSummaryModel {
  final int year;
  final int month;
  final String monthName;
  final double totalFuelAmount;
  final int recordCount;

  MonthlyFuelSummaryModel({
    required this.year,
    required this.month,
    required this.monthName,
    required this.totalFuelAmount,
    required this.recordCount,
  });

  factory MonthlyFuelSummaryModel.fromJson(Map<String, dynamic> json) {
    return MonthlyFuelSummaryModel(
      year: json['year'] ?? json['Year'] ?? DateTime.now().year,
      month: json['month'] ?? json['Month'] ?? 1,
      monthName:
          (json['monthName'] ?? json['MonthName'])?.toString() ?? 'Unknown',
      totalFuelAmount:
          (json['totalFuelAmount'] ?? json['TotalFuelAmount'] ?? 0).toDouble(),
      recordCount: json['recordCount'] ?? json['RecordCount'] ?? 0,
    );
  }

  // Helper for chart display
  String get displayMonth => monthName.substring(0, 3); // Show first 3 chars
}
