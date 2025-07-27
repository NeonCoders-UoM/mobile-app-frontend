import 'package:flutter/material.dart';
import '../../core/models/vehicle.dart';
import '../../data/repositories/vehicle_repository.dart';

class VehicleProvider with ChangeNotifier {
  final VehicleRepository repository;
  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;
  bool _isLoading = false;

  VehicleProvider(this.repository);

  List<Vehicle> get vehicles => _vehicles;
  Vehicle? get selectedVehicle => _selectedVehicle;
  bool get isLoading => _isLoading;

  Future<void> loadVehicles(int customerId, String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _vehicles = await repository.fetchVehicles(customerId, token);

      // Set selected vehicle if we have vehicles and no vehicle is currently selected
      if (_vehicles.isNotEmpty && _selectedVehicle == null) {
        _selectedVehicle = _vehicles.first;
      }
      // If we have vehicles but the current selected vehicle is not in the list, select the first one
      else if (_vehicles.isNotEmpty && _selectedVehicle != null) {
        final vehicleExists =
            _vehicles.any((v) => v.vehicleId == _selectedVehicle!.vehicleId);
        if (!vehicleExists) {
          _selectedVehicle = _vehicles.first;
        }
      }
      // If no vehicles, clear selected vehicle
      else if (_vehicles.isEmpty) {
        _selectedVehicle = null;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading vehicles: $e');
      _vehicles = [];
      _selectedVehicle = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectVehicle(Vehicle vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  Future<void> addVehicle(
      int customerId, Map<String, dynamic> vehicleData, String token) async {
    final newVehicle =
        await repository.addVehicle(customerId, vehicleData, token);
    _vehicles.add(newVehicle);
    _selectedVehicle = newVehicle;
    notifyListeners();
  }

  Future<void> updateVehicle(int customerId, int vehicleId,
      Map<String, dynamic> vehicleData, String token) async {
    await repository.updateVehicle(customerId, vehicleId, vehicleData, token);
    final idx = _vehicles.indexWhere((v) => v.vehicleId == vehicleId);
    if (idx != -1) {
      _vehicles[idx] = Vehicle.fromJson(vehicleData..['vehicleId'] = vehicleId);
      notifyListeners();
    }
  }

  Future<void> deleteVehicle(
      int customerId, int vehicleId, String token) async {
    await repository.deleteVehicle(customerId, vehicleId, token);
    _vehicles.removeWhere((v) => v.vehicleId == vehicleId);
    if (_selectedVehicle?.vehicleId == vehicleId) {
      _selectedVehicle = _vehicles.isNotEmpty ? _vehicles.first : null;
    }
    notifyListeners();
  }
}
