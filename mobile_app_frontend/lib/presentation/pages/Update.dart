import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateVehiclePage extends StatefulWidget {
  @override
  _UpdateVehiclePageState createState() => _UpdateVehiclePageState();
}

class _UpdateVehiclePageState extends State<UpdateVehiclePage> {
  final TextEditingController _vehicleIdController = TextEditingController();
  final TextEditingController _regNoController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();
  final TextEditingController _chassiNoController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();

  String _responseMessage = '';

  Future<void> updateVehicle() async {
    final id = _vehicleIdController.text.trim();

    if (id.isEmpty ||
        _regNoController.text.isEmpty ||
        _fuelTypeController.text.isEmpty ||
        _chassiNoController.text.isEmpty ||
        _brandController.text.isEmpty ||
        _modelController.text.isEmpty) {
      setState(() {
        _responseMessage = 'Please fill all fields.';
      });
      return;
    }

    final url = Uri.parse('http://localhost:5285/api/vehicles/$id'); // Adjust your endpoint

    final body = jsonEncode({
      'vehicleID': int.parse(id),
      'registrationNumber': _regNoController.text.trim(),
      'fuelType': _fuelTypeController.text.trim(),
      'chassiNumber': _chassiNoController.text.trim(),
      'brand': _brandController.text.trim(),
      'model': _modelController.text.trim(),
    });

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _responseMessage = 'Vehicle updated successfully!';
        });
      } else {
        setState(() {
          _responseMessage = 'Failed to update. Status: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Vehicle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _vehicleIdController,
              decoration: InputDecoration(labelText: 'Vehicle ID'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _regNoController,
              decoration: InputDecoration(labelText: 'Registration Number'),
            ),
            TextField(
              controller: _fuelTypeController,
              decoration: InputDecoration(labelText: 'Fuel Type'),
            ),
            TextField(
              controller: _chassiNoController,
              decoration: InputDecoration(labelText: 'Chassis Number'),
            ),
            TextField(
              controller: _brandController,
              decoration: InputDecoration(labelText: 'Brand'),
            ),
            TextField(
              controller: _modelController,
              decoration: InputDecoration(labelText: 'Model'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: updateVehicle,
              child: Text('Update Vehicle'),
            ),
            SizedBox(height: 16),
            Text(
              _responseMessage,
              style: TextStyle(
                color: _responseMessage.contains('success') ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
