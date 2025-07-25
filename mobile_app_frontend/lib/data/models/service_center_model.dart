class ServiceCenterModel {
  final int stationId;
  final String stationName;
  final String address;
  final String email;
  final String telephone;
  final String stationStatus;
  final double latitude;
  final double longitude;

  ServiceCenterModel({
    required this.stationId,
    required this.stationName,
    required this.address,
    required this.email,
    required this.telephone,
    required this.stationStatus,
    required this.latitude,
    required this.longitude,
  });

  factory ServiceCenterModel.fromJson(Map<String, dynamic> json) {
    return ServiceCenterModel(
      stationId: json['station_id'] ?? json['stationId'] ?? 0,
      stationName: json['station_name'] ?? '',
      address: json['address'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      stationStatus: json['station_status'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }
}
