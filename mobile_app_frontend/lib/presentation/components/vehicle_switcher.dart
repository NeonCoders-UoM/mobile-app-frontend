import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/vehicle.dart';
import '../../state/providers/vehicle_provider.dart';

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
              // Add Vehicle selected
              await showDialog(
                context: context,
                builder: (context) => AddVehicleDialog(customerId: customerId, token: token),
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

class AddVehicleDialog extends StatefulWidget {
  final int customerId;
  final String token;
  const AddVehicleDialog({Key? key, required this.customerId, required this.token}) : super(key: key);

  @override
  State<AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<AddVehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'registrationNumber': '',
    'brand': '',
    'model': '',
    'chassisNumber': '',
    'mileage': 0,
    'fuel': '',
    'year': 0,
  };
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Vehicle'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Registration Number'),
                onSaved: (v) => _formData['registrationNumber'] = v ?? '',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Brand'),
                onSaved: (v) => _formData['brand'] = v ?? '',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Model'),
                onSaved: (v) => _formData['model'] = v ?? '',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Chassis Number'),
                onSaved: (v) => _formData['chassisNumber'] = v ?? '',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mileage'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _formData['mileage'] = int.tryParse(v ?? '0') ?? 0,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Fuel'),
                onSaved: (v) => _formData['fuel'] = v ?? '',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Year'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _formData['year'] = int.tryParse(v ?? '0') ?? 0,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ]
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _loading
              ? null
              : () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    setState(() {
                      _loading = true;
                      _error = null;
                    });
                    try {
                      await Provider.of<VehicleProvider>(context, listen: false)
                          .addVehicle(widget.customerId, _formData, widget.token);
                      Navigator.of(context).pop();
                    } catch (e) {
                      setState(() {
                        _error = e.toString();
                        _loading = false;
                      });
                    }
                  }
                },
          child: _loading ? const CircularProgressIndicator() : const Text('Add'),
        ),
      ],
    );
  }
} 