import 'package:flutter/material.dart';
import '../../core/models/vehicle.dart';
import '../../data/repositories/vehicle_repository.dart';

class VehicleProvider with ChangeNotifier {
  final VehicleRepository repository;
  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;

  VehicleProvider(this.repository);

  List<Vehicle> get vehicles => _vehicles;
  Vehicle? get selectedVehicle => _selectedVehicle;

  Future<void> loadVehicles(int customerId, String token) async {
    _vehicles = await repository.fetchVehicles(customerId, token);
    if (_vehicles.isNotEmpty && _selectedVehicle == null) {
      _selectedVehicle = _vehicles.first;
    }
    notifyListeners();
  }

  void selectVehicle(Vehicle vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  Future<void> addVehicle(int customerId, Map<String, dynamic> vehicleData, String token) async {
    final newVehicle = await repository.addVehicle(customerId, vehicleData, token);
    _vehicles.add(newVehicle);
    _selectedVehicle = newVehicle;
    notifyListeners();
  }

  Future<void> updateVehicle(int customerId, int vehicleId, Map<String, dynamic> vehicleData, String token) async {
    await repository.updateVehicle(customerId, vehicleId, vehicleData, token);
    final idx = _vehicles.indexWhere((v) => v.vehicleId == vehicleId);
    if (idx != -1) {
      _vehicles[idx] = Vehicle.fromJson(vehicleData..['vehicleId'] = vehicleId);
      notifyListeners();
    }
  }

  Future<void> deleteVehicle(int customerId, int vehicleId, String token) async {
    await repository.deleteVehicle(customerId, vehicleId, token);
    _vehicles.removeWhere((v) => v.vehicleId == vehicleId);
    if (_selectedVehicle?.vehicleId == vehicleId) {
      _selectedVehicle = _vehicles.isNotEmpty ? _vehicles.first : null;
    }
    notifyListeners();
  }
}
