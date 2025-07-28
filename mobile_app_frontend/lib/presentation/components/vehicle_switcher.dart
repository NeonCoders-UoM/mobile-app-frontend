import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/vehicle.dart';
import '../../state/providers/vehicle_provider.dart';
import '../pages/add_vehicledeails_page.dart';

class VehicleSwitcher extends StatelessWidget {
  final int customerId;
  final String token;
  const VehicleSwitcher({Key? key, required this.customerId, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProvider, child) {
        final vehicles = vehicleProvider.vehicles;
        final selectedVehicle = vehicleProvider.selectedVehicle;
        return DropdownButton<Vehicle?>(
          value: selectedVehicle,
          underline: Container(),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          items: [
            ...vehicles.map((vehicle) => DropdownMenuItem<Vehicle?>(
                  value: vehicle,
                  child: Text(vehicle.registrationNumber, style: const TextStyle(color: Colors.white)),
                )),
            const DropdownMenuItem<Vehicle?>(
              value: null,
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Add Vehicle', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
          onChanged: (vehicle) async {
            if (vehicle == null) {
              // Navigate to Add Vehicle page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddVehicledetailsPage(
                    customerId: customerId,
                    token: token,
                  ),
                ),
              );
            } else {
              vehicleProvider.selectVehicle(vehicle);
            }
          },
        );
      },
    );
  }
} 