class Service {
  final int serviceId;
  final String serviceName;
  final String description;
  final double basePrice;
  final String category;

  Service({
    required this.serviceId,
    required this.serviceName,
    required this.description,
    required this.basePrice,
    required this.category,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
      description: json['description'] ?? '',
      basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? '',
    );
  }
}
