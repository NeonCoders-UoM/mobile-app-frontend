class EmergencyCallCenterModel {
  final int emergencyCallCenterId;
  final String name;
  final String address;
  final String registrationNumber;
  final String phoneNumber;

  EmergencyCallCenterModel({
    required this.emergencyCallCenterId,
    required this.name,
    required this.address,
    required this.registrationNumber,
    required this.phoneNumber,
  });

  // Convert from JSON response
  factory EmergencyCallCenterModel.fromJson(Map<String, dynamic> json) {
    return EmergencyCallCenterModel(
      emergencyCallCenterId: json['emergencyCallCenterId'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'emergencyCallCenterId': emergencyCallCenterId,
      'name': name,
      'address': address,
      'registrationNumber': registrationNumber,
      'phoneNumber': phoneNumber,
    };
  }

  // Convert to create JSON (without ID for POST requests)
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'address': address,
      'registrationNumber': registrationNumber,
      'phoneNumber': phoneNumber,
    };
  }

  @override
  String toString() {
    return 'EmergencyCallCenterModel{id: $emergencyCallCenterId, name: $name, address: $address, phone: $phoneNumber}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmergencyCallCenterModel &&
        other.emergencyCallCenterId == emergencyCallCenterId &&
        other.name == name &&
        other.address == address &&
        other.registrationNumber == registrationNumber &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode {
    return emergencyCallCenterId.hashCode ^
        name.hashCode ^
        address.hashCode ^
        registrationNumber.hashCode ^
        phoneNumber.hashCode;
  }
}
