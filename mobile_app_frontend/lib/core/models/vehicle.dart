class Vehicle {
  final int vehicleId;
  final String registrationNumber;
  final String brand;
  final String model;
  final String chassisNumber;
  final int mileage;
  final String fuel;
  final int year;

  Vehicle({
    required this.vehicleId,
    required this.registrationNumber,
    required this.brand,
    required this.model,
    required this.chassisNumber,
    required this.mileage,
    required this.fuel,
    required this.year,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        vehicleId: json['vehicleId'],
        registrationNumber: json['registrationNumber'],
        brand: json['brand'],
        model: json['model'],
        chassisNumber: json['chassisNumber'],
        mileage: json['mileage'],
        fuel: json['fuel'],
        year: json['year'],
      );

  Map<String, dynamic> toJson() => {
        'vehicleId': vehicleId,
        'registrationNumber': registrationNumber,
        'brand': brand,
        'model': model,
        'chassisNumber': chassisNumber,
        'mileage': mileage,
        'fuel': fuel,
        'year': year,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Vehicle &&
          runtimeType == other.runtimeType &&
          vehicleId == other.vehicleId;

  @override
  int get hashCode => vehicleId.hashCode;
} 