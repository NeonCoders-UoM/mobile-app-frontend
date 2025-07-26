class LoyaltyPointsModel {
  final int appointmentId;
  final int customerId;
  final int vehicleId;
  final int stationId;
  final int loyaltyPoints;
  final List<ServiceLoyaltyPoints> services;

  LoyaltyPointsModel({
    required this.appointmentId,
    required this.customerId,
    required this.vehicleId,
    required this.stationId,
    required this.loyaltyPoints,
    required this.services,
  });

  factory LoyaltyPointsModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyPointsModel(
      appointmentId: json['appointmentId'] ?? 0,
      customerId: json['customerId'] ?? 0,
      vehicleId: json['vehicleId'] ?? 0,
      stationId: json['stationId'] ?? 0,
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      services: (json['services'] as List<dynamic>?)
              ?.map((service) => ServiceLoyaltyPoints.fromJson(service))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'customerId': customerId,
      'vehicleId': vehicleId,
      'stationId': stationId,
      'loyaltyPoints': loyaltyPoints,
      'services': services.map((service) => service.toJson()).toList(),
    };
  }
}

class ServiceLoyaltyPoints {
  final int serviceId;
  final int loyaltyPoints;

  ServiceLoyaltyPoints({
    required this.serviceId,
    required this.loyaltyPoints,
  });

  factory ServiceLoyaltyPoints.fromJson(Map<String, dynamic> json) {
    return ServiceLoyaltyPoints(
      serviceId: json['serviceId'] ?? 0,
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'loyaltyPoints': loyaltyPoints,
    };
  }
}
