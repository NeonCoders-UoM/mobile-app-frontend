class ServiceCenterSearchResult {
  final int stationId;
  final String stationName;
  final String address;
  final double latitude;
  final double longitude;
  final double distance;
  final double totalCost;
  final int loyaltyPoints;
  final int availableSlots;
  final List<ServiceDetail> services;

  ServiceCenterSearchResult({
    required this.stationId,
    required this.stationName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.totalCost,
    required this.loyaltyPoints,
    required this.availableSlots,
    required this.services,
  });

  factory ServiceCenterSearchResult.fromJson(Map<String, dynamic> json) {
    return ServiceCenterSearchResult(
      stationId: json['stationId'] ?? 0,
      stationName: json['stationName'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      availableSlots: json['availableSlots'] ?? 0,
      services: (json['services'] as List<dynamic>?)
              ?.map((service) => ServiceDetail.fromJson(service))
              .toList() ??
          [],
    );
  }
}

class ServiceDetail {
  final int serviceId;
  final String serviceName;
  final double cost;

  ServiceDetail({
    required this.serviceId,
    required this.serviceName,
    required this.cost,
  });

  factory ServiceDetail.fromJson(Map<String, dynamic> json) {
    return ServiceDetail(
      serviceId: json['serviceId'] ?? 0,
      serviceName: json['serviceName'] ?? '',
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
