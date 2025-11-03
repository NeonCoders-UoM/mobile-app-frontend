class ServiceHistoryModel {
  final int? serviceHistoryId; // Primary key - matches backend DTO
  final int vehicleId;
  final String serviceType; // Type of service - matches backend DTO
  final String description; // Service description - matches backend DTO
  final DateTime serviceDate;
  final int? serviceCenterId; // ID of the service center - matches backend DTO
  final int?
      servicedByUserId; // User who performed the service - matches backend DTO
  final String?
      serviceCenterName; // Name of the service center - matches backend DTO
  final String?
      servicedByUserName; // Name of the user who performed service - matches backend DTO
  final double? cost;
  final int?
      mileage; // Vehicle mileage at time of service - matches backend DTO
  final bool isVerified;
  final String?
      externalServiceCenterName; // For unverified services - matches backend DTO
  final String?
      receiptDocumentPath; // Path to receipt document - matches backend DTO
  final String? notes; // Additional notes
  final DateTime createdAt;
  final DateTime? updatedAt;

  ServiceHistoryModel({
    this.serviceHistoryId,
    required this.vehicleId,
    required this.serviceType,
    required this.description,
    required this.serviceDate,
    this.serviceCenterId,
    this.servicedByUserId,
    this.serviceCenterName,
    this.servicedByUserName,
    this.cost,
    this.mileage,
    this.isVerified = true,
    this.externalServiceCenterName,
    this.receiptDocumentPath,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Factory constructor for creating an unverified service record
  factory ServiceHistoryModel.unverified({
    required int vehicleId,
    required String serviceType,
    required String description,
    required DateTime serviceDate,
    required String externalServiceCenterName,
    double? cost,
    int? mileage,
    String? receiptDocumentPath,
    String? notes,
  }) {
    return ServiceHistoryModel(
      vehicleId: vehicleId,
      serviceType: serviceType,
      description: description,
      serviceDate: serviceDate,
      externalServiceCenterName: externalServiceCenterName,
      cost: cost,
      mileage: mileage,
      receiptDocumentPath: receiptDocumentPath,
      isVerified: false,
      notes: notes,
    );
  }

  // Convert to JSON for API calls - matches backend DTO structure
  Map<String, dynamic> toJson() {
    return {
      'serviceHistoryId': serviceHistoryId,
      'vehicleId': vehicleId,
      'serviceType': serviceType,
      'description': description,
      'serviceDate': serviceDate.toIso8601String(),
      'serviceCenterId': serviceCenterId,
      'servicedByUserId': servicedByUserId,
      'serviceCenterName': serviceCenterName,
      'servicedByUserName': servicedByUserName,
      'cost': cost,
      'mileage': mileage,
      'isVerified': isVerified,
      'externalServiceCenterName': externalServiceCenterName,
      'receiptDocumentPath': receiptDocumentPath,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Convert to JSON for CREATE requests - matches AddServiceHistoryDTO structure
  Map<String, dynamic> toCreateJson() {
    return {
      // Note: vehicleId is passed in URL path, not in body
      'serviceType': serviceType,
      'description': description,
      'serviceDate': serviceDate.toIso8601String(),
      'serviceCenterId': serviceCenterId,
      'servicedByUserId': servicedByUserId,
      'cost': cost,
      'mileage': mileage,
      'externalServiceCenterName': externalServiceCenterName,
      'receiptDocument': null, // Base64 string if uploading receipt
    };
  }

  // Convert to JSON for UPDATE requests - matches UpdateServiceHistoryDTO structure
  Map<String, dynamic> toUpdateJson() {
    return {
      'serviceHistoryId': serviceHistoryId,
      'vehicleId': vehicleId,
      'serviceType': serviceType,
      'description': description,
      'serviceDate': serviceDate.toIso8601String(),
      'serviceCenterId': serviceCenterId,
      'servicedByUserId': servicedByUserId,
      'cost': cost,
      'mileage': mileage,
      'externalServiceCenterName': externalServiceCenterName,
      'receiptDocument': null, // Base64 string if uploading receipt
    };
  }

  // Create from JSON response - matches backend DTO structure
  factory ServiceHistoryModel.fromJson(Map<String, dynamic> json) {
    return ServiceHistoryModel(
      serviceHistoryId: json['serviceHistoryId'],
      vehicleId: json['vehicleId'],
      serviceType: json['serviceType'] ?? '',
      description: json['description'] ?? '',
      serviceDate: DateTime.parse(json['serviceDate']),
      serviceCenterId: json['serviceCenterId'],
      servicedByUserId: json['servicedByUserId'],
      serviceCenterName: json['serviceCenterName'],
      servicedByUserName: json['servicedByUserName'],
      cost: json['cost']?.toDouble(),
      mileage: json['mileage'],
      isVerified: json['isVerified'] ?? true,
      externalServiceCenterName: json['externalServiceCenterName'],
      receiptDocumentPath: json['receiptDocumentPath'],
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  // Create a copy with updated fields
  ServiceHistoryModel copyWith({
    int? serviceHistoryId,
    int? vehicleId,
    String? serviceType,
    String? description,
    DateTime? serviceDate,
    int? serviceCenterId,
    int? servicedByUserId,
    String? serviceCenterName,
    String? servicedByUserName,
    double? cost,
    int? mileage,
    bool? isVerified,
    String? externalServiceCenterName,
    String? receiptDocumentPath,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceHistoryModel(
      serviceHistoryId: serviceHistoryId ?? this.serviceHistoryId,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      serviceDate: serviceDate ?? this.serviceDate,
      serviceCenterId: serviceCenterId ?? this.serviceCenterId,
      servicedByUserId: servicedByUserId ?? this.servicedByUserId,
      serviceCenterName: serviceCenterName ?? this.serviceCenterName,
      servicedByUserName: servicedByUserName ?? this.servicedByUserName,
      cost: cost ?? this.cost,
      mileage: mileage ?? this.mileage,
      isVerified: isVerified ?? this.isVerified,
      externalServiceCenterName:
          externalServiceCenterName ?? this.externalServiceCenterName,
      receiptDocumentPath: receiptDocumentPath ?? this.receiptDocumentPath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters for backward compatibility and UI display
  String get serviceTitle => serviceType;
  String get serviceDescription => description;
  String get serviceProvider =>
      serviceCenterName ?? externalServiceCenterName ?? 'Unknown';
  String get location => serviceCenterName ?? externalServiceCenterName ?? '';
  String get status => isVerified ? 'Verified' : 'Unverified';

  // Helper getter for display ID
  String get displayId => serviceHistoryId?.toString() ?? 'Local';
}
