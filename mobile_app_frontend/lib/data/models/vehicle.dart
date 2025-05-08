class Vehicle {
  final String registrationNumber;
  final String chassisNumber;
  final String mileage;
  final String brand;
  final String model;
  final String fuelType;

  Vehicle({
    required this.registrationNumber,
    required this.chassisNumber,
    required this.mileage,
    required this.brand,
    required this.model,
    required this.fuelType,
  });

  // Convert Vehicle object to JSON
  Map<String, dynamic> toJson() {
    return {
      'registrationNumber': registrationNumber,
      'chassisNumber': chassisNumber,
      'category': mileage,
      'vehicleType': brand,
      'model': model,
      'fuelType': fuelType,
    };
  }
}
