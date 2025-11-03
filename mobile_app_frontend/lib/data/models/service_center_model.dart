class ServiceCenterDTO {
  final int stationId;
  final String? ownerName;
  final String? vatNumber;
  final String? registrationNumber;
  final String? stationName;
  final String? email;
  final String? telephone;
  final String? address;
  final String? stationStatus;
  final double? latitude;
  final double? longitude;

  ServiceCenterDTO({
    required this.stationId,
    this.ownerName,
    this.vatNumber,
    this.registrationNumber,
    this.stationName,
    this.email,
    this.telephone,
    this.address,
    this.stationStatus,
    this.latitude,
    this.longitude,
  });

  factory ServiceCenterDTO.fromJson(Map<String, dynamic> json) {
    return ServiceCenterDTO(
      stationId: json['station_id'] ?? json['Station_id'],
      ownerName: json['ownerName'] ?? json['OwnerName'],
      vatNumber: json['vatNumber'] ?? json['VATNumber'],
      registrationNumber:
          json['registrationNumber'] ?? json['RegisterationNumber'],
      stationName: json['station_name'] ?? json['Station_name'],
      email: json['email'] ?? json['Email'],
      telephone: json['telephone'] ?? json['Telephone'],
      address: json['address'] ?? json['Address'],
      stationStatus: json['station_status'] ?? json['Station_status'],
      latitude: json['latitude']?.toDouble() ?? json['Latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble() ?? json['Longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'station_id': stationId,
      'ownerName': ownerName,
      'vatNumber': vatNumber,
      'registrationNumber': registrationNumber,
      'station_name': stationName,
      'email': email,
      'telephone': telephone,
      'address': address,
      'station_status': stationStatus,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  String toString() {
    return stationName ?? 'Service Center $stationId';
  }
}

class CreateServiceCenterDTO {
  final String ownerName;
  final String? vatNumber;
  final String? registrationNumber;
  final String stationName;
  final String? email;
  final String? telephone;
  final String address;
  final String? stationStatus;
  final double? latitude;
  final double? longitude;

  CreateServiceCenterDTO({
    required this.ownerName,
    this.vatNumber,
    this.registrationNumber,
    required this.stationName,
    this.email,
    this.telephone,
    required this.address,
    this.stationStatus,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'ownerName': ownerName,
      'vatNumber': vatNumber,
      'registrationNumber': registrationNumber,
      'station_name': stationName,
      'email': email,
      'telephone': telephone,
      'address': address,
      'station_status': stationStatus,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class UpdateServiceCenterDTO {
  final String? ownerName;
  final String? vatNumber;
  final String? registrationNumber;
  final String? stationName;
  final String? email;
  final String? telephone;
  final String? address;
  final String? stationStatus;

  UpdateServiceCenterDTO({
    this.ownerName,
    this.vatNumber,
    this.registrationNumber,
    this.stationName,
    this.email,
    this.telephone,
    this.address,
    this.stationStatus,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (ownerName != null) data['ownerName'] = ownerName;
    if (vatNumber != null) data['vatNumber'] = vatNumber;
    if (registrationNumber != null)
      data['registrationNumber'] = registrationNumber;
    if (stationName != null) data['station_name'] = stationName;
    if (email != null) data['email'] = email;
    if (telephone != null) data['telephone'] = telephone;
    if (address != null) data['address'] = address;
    if (stationStatus != null) data['station_status'] = stationStatus;
    return data;
  }
}
