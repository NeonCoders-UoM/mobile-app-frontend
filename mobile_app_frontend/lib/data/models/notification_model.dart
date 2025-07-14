class NotificationModel {
  final int? notificationId;
  final int customerId;
  final int? serviceReminderId;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final bool isSent;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? sentAt;
  final DateTime? scheduledFor;
  final String priority;

  // Additional fields from the DTO
  final String? customerName;
  final String? customerEmail;
  final String? vehicleRegistrationNumber;
  final String? vehicleBrand;
  final String? vehicleModel;
  final DateTime? serviceReminderDate;
  final String? serviceName;

  NotificationModel({
    this.notificationId,
    required this.customerId,
    this.serviceReminderId,
    required this.title,
    required this.message,
    required this.type,
    this.isRead = false,
    this.isSent = false,
    required this.createdAt,
    this.readAt,
    this.sentAt,
    this.scheduledFor,
    required this.priority,
    this.customerName,
    this.customerEmail,
    this.vehicleRegistrationNumber,
    this.vehicleBrand,
    this.vehicleModel,
    this.serviceReminderDate,
    this.serviceName,
  });

  // Convert from JSON (matches NotificationDTO)
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'],
      customerId: json['customerId'] ?? 0,
      serviceReminderId: json['serviceReminderId'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      isRead: json['isRead'] ?? false,
      isSent: json['isSent'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
      scheduledFor: json['scheduledFor'] != null
          ? DateTime.parse(json['scheduledFor'])
          : null,
      priority: json['priority'] ?? 'Medium',
      customerName: json['customerName'],
      customerEmail: json['customerEmail'],
      vehicleRegistrationNumber: json['vehicleRegistrationNumber'],
      vehicleBrand: json['vehicleBrand'],
      vehicleModel: json['vehicleModel'],
      serviceReminderDate: json['serviceReminderDate'] != null
          ? DateTime.parse(json['serviceReminderDate'])
          : null,
      serviceName: json['serviceName'],
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      if (notificationId != null) 'notificationId': notificationId,
      'customerId': customerId,
      'serviceReminderId': serviceReminderId,
      'title': title,
      'message': message,
      'type': type,
      'isRead': isRead,
      'isSent': isSent,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'scheduledFor': scheduledFor?.toIso8601String(),
      'priority': priority,
    };
  }

  // Convert to CreateNotificationDTO format
  Map<String, dynamic> toCreateDto() {
    return {
      'customerId': customerId,
      'serviceReminderId': serviceReminderId,
      'title': title,
      'message': message,
      'type': type,
      'priority': priority,
      'scheduledFor': scheduledFor?.toIso8601String(),
    };
  }

  // Helper methods for UI display
  String get displayTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.day}.${createdAt.month.toString().padLeft(2, '0')}';
    }
  }

  String get priorityColor {
    switch (priority.toLowerCase()) {
      case 'critical':
        return '#FF4444'; // Red
      case 'high':
        return '#FF8800'; // Orange
      case 'medium':
        return '#FFD700'; // Yellow
      case 'low':
        return '#4CAF50'; // Green
      default:
        return '#9E9E9E'; // Grey
    }
  }

  bool get isUnread => !isRead;

  String get shortVehicleInfo {
    if (vehicleBrand != null && vehicleModel != null) {
      return '$vehicleBrand $vehicleModel';
    } else if (vehicleRegistrationNumber != null) {
      return vehicleRegistrationNumber!;
    }
    return 'Vehicle';
  }

  // Create a copy with updated fields
  NotificationModel copyWith({
    int? notificationId,
    int? customerId,
    int? serviceReminderId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    bool? isSent,
    DateTime? createdAt,
    DateTime? readAt,
    DateTime? sentAt,
    DateTime? scheduledFor,
    String? priority,
    String? customerName,
    String? customerEmail,
    String? vehicleRegistrationNumber,
    String? vehicleBrand,
    String? vehicleModel,
    DateTime? serviceReminderDate,
    String? serviceName,
  }) {
    return NotificationModel(
      notificationId: notificationId ?? this.notificationId,
      customerId: customerId ?? this.customerId,
      serviceReminderId: serviceReminderId ?? this.serviceReminderId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      sentAt: sentAt ?? this.sentAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      priority: priority ?? this.priority,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      vehicleRegistrationNumber:
          vehicleRegistrationNumber ?? this.vehicleRegistrationNumber,
      vehicleBrand: vehicleBrand ?? this.vehicleBrand,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      serviceReminderDate: serviceReminderDate ?? this.serviceReminderDate,
      serviceName: serviceName ?? this.serviceName,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $notificationId, title: $title, priority: $priority, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.notificationId == notificationId;
  }

  @override
  int get hashCode => notificationId.hashCode;
}

// Summary model for notification statistics
class NotificationSummaryModel {
  final int totalNotifications;
  final int unreadNotifications;
  final int pendingNotifications;
  final int sentNotifications;

  NotificationSummaryModel({
    required this.totalNotifications,
    required this.unreadNotifications,
    required this.pendingNotifications,
    required this.sentNotifications,
  });

  factory NotificationSummaryModel.fromJson(Map<String, dynamic> json) {
    return NotificationSummaryModel(
      totalNotifications: json['totalNotifications'] ?? 0,
      unreadNotifications: json['unreadNotifications'] ?? 0,
      pendingNotifications: json['pendingNotifications'] ?? 0,
      sentNotifications: json['sentNotifications'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalNotifications': totalNotifications,
      'unreadNotifications': unreadNotifications,
      'pendingNotifications': pendingNotifications,
      'sentNotifications': sentNotifications,
    };
  }
}
