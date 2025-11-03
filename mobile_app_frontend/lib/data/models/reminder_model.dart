import 'package:mobile_app_frontend/presentation/components/molecules/service_reminder_card.dart';

class ServiceReminderModel {
  final int? serviceReminderId;
  final int vehicleId;
  final int serviceId;
  final DateTime reminderDate;
  final int intervalMonths;
  final int notifyBeforeDays;
  final String? notes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Additional fields from the DTO
  final String? serviceName;
  final String? vehicleRegistrationNumber;
  final String? vehicleBrand;
  final String? vehicleModel;

  ServiceReminderModel({
    this.serviceReminderId,
    required this.vehicleId,
    required this.serviceId,
    required this.reminderDate,
    required this.intervalMonths,
    required this.notifyBeforeDays,
    this.notes,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.serviceName,
    this.vehicleRegistrationNumber,
    this.vehicleBrand,
    this.vehicleModel,
  });

  // Convert from JSON (matches ServiceReminderDTO)
  factory ServiceReminderModel.fromJson(Map<String, dynamic> json) {
    return ServiceReminderModel(
      serviceReminderId: json['serviceReminderId'],
      vehicleId: json['vehicleId'] ?? 0,
      serviceId: json['serviceId'] ?? 0,
      reminderDate: DateTime.parse(json['reminderDate']),
      intervalMonths: json['intervalMonths'] ?? 0,
      notifyBeforeDays: json['notifyBeforeDays'] ?? 0,
      notes: json['notes'],
      isActive: json['isActive'] ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      serviceName: json['serviceName'],
      vehicleRegistrationNumber: json['vehicleRegistrationNumber'],
      vehicleBrand: json['vehicleBrand'],
      vehicleModel: json['vehicleModel'],
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      if (serviceReminderId != null) 'serviceReminderId': serviceReminderId,
      'vehicleId': vehicleId,
      'serviceId': serviceId,
      'reminderDate': reminderDate.toIso8601String(),
      'intervalMonths': intervalMonths,
      'notifyBeforeDays': notifyBeforeDays,
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Convert to CreateServiceReminderDTO format
  Map<String, dynamic> toCreateDto() {
    return {
      'vehicleId': vehicleId,
      'serviceId': serviceId,
      'reminderDate': reminderDate.toIso8601String(),
      'intervalMonths': intervalMonths,
      'notifyBeforeDays': notifyBeforeDays,
      'notes': notes,
    };
  }

  // Convert to UpdateServiceReminderDTO format
  Map<String, dynamic> toUpdateDto() {
    return {
      'serviceId': serviceId,
      'reminderDate': reminderDate.toIso8601String(),
      'intervalMonths': intervalMonths,
      'notifyBeforeDays': notifyBeforeDays,
      'notes': notes,
      'isActive': isActive,
    };
  }

  // Convert to Map for UI compatibility (maintains backward compatibility)
  Map<String, dynamic> toMap() {
    return {
      'id': serviceReminderId?.toString(),
      'vehicleId': vehicleId.toString(),
      'title': serviceName ?? 'Service Reminder',
      'description': _generateDescription(),
      'status': _getStatusFromDate(),
      'nextDue': _generateNextDue(),
      'mileageInterval': 'Not specified',
      'timeInterval': '$intervalMonths months',
      'lastServiceDate': 'Not specified',
      'notifyPeriod': '$notifyBeforeDays days before',
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      // Backend specific fields
      'serviceReminderId': serviceReminderId,
      'serviceId': serviceId,
      'reminderDate': reminderDate.toIso8601String(),
      'intervalMonths': intervalMonths,
      'notifyBeforeDays': notifyBeforeDays,
      'notes': notes,
      'isActive': isActive,
      'serviceName': serviceName,
      'vehicleRegistrationNumber': vehicleRegistrationNumber,
      'vehicleBrand': vehicleBrand,
      'vehicleModel': vehicleModel,
    };
  }

  // Create from Map (for UI compatibility)
  factory ServiceReminderModel.fromMap(Map<String, dynamic> map) {
    return ServiceReminderModel(
      serviceReminderId: map['serviceReminderId'] ??
          (map['id'] != null ? int.tryParse(map['id']) : null),
      vehicleId: map['vehicleId'] is int
          ? map['vehicleId']
          : int.tryParse(map['vehicleId']?.toString() ?? '0') ?? 0,
      serviceId: map['serviceId'] ?? 1, // Default service ID
      reminderDate: map['reminderDate'] != null
          ? DateTime.parse(map['reminderDate'])
          : DateTime.now()
              .add(Duration(days: 30)), // Default to 30 days from now
      intervalMonths: map['intervalMonths'] ?? 6, // Default 6 months
      notifyBeforeDays: map['notifyBeforeDays'] ?? 7, // Default 7 days
      notes: map['notes'] ?? map['title'], // Use title as notes if available
      isActive: map['isActive'] ?? true,
      createdAt:
          map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      serviceName: map['serviceName'] ?? map['title'],
      vehicleRegistrationNumber: map['vehicleRegistrationNumber'],
      vehicleBrand: map['vehicleBrand'],
      vehicleModel: map['vehicleModel'],
    );
  }

  // Helper method to generate description for UI
  String _generateDescription() {
    if (notes != null && notes!.isNotEmpty) {
      return notes!;
    }
    return 'Next: ${_formatDate(reminderDate)} (in $intervalMonths months)';
  }

  // Helper method to generate next due text
  String _generateNextDue() {
    return 'Next: ${_formatDate(reminderDate)}';
  }

  // Helper method to determine status based on date
  ServiceStatus _getStatusFromDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderDay =
        DateTime(reminderDate.year, reminderDate.month, reminderDate.day);

    if (!isActive) {
      return ServiceStatus.canceled;
    }

    if (reminderDay.isBefore(today)) {
      return ServiceStatus.overdue;
    } else if (reminderDay.isAtSameMomentAs(today) ||
        reminderDay.isBefore(today.add(Duration(days: notifyBeforeDays)))) {
      return ServiceStatus.upcoming;
    } else {
      return ServiceStatus.scheduled;
    }
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Create a copy with updated fields
  ServiceReminderModel copyWith({
    int? serviceReminderId,
    int? vehicleId,
    int? serviceId,
    DateTime? reminderDate,
    int? intervalMonths,
    int? notifyBeforeDays,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? serviceName,
    String? vehicleRegistrationNumber,
    String? vehicleBrand,
    String? vehicleModel,
  }) {
    return ServiceReminderModel(
      serviceReminderId: serviceReminderId ?? this.serviceReminderId,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceId: serviceId ?? this.serviceId,
      reminderDate: reminderDate ?? this.reminderDate,
      intervalMonths: intervalMonths ?? this.intervalMonths,
      notifyBeforeDays: notifyBeforeDays ?? this.notifyBeforeDays,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      serviceName: serviceName ?? this.serviceName,
      vehicleRegistrationNumber:
          vehicleRegistrationNumber ?? this.vehicleRegistrationNumber,
      vehicleBrand: vehicleBrand ?? this.vehicleBrand,
      vehicleModel: vehicleModel ?? this.vehicleModel,
    );
  }

  @override
  String toString() {
    return 'ServiceReminderModel(id: $serviceReminderId, vehicleId: $vehicleId, serviceName: $serviceName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceReminderModel &&
        other.serviceReminderId == serviceReminderId;
  }

  @override
  int get hashCode => serviceReminderId.hashCode;
}
