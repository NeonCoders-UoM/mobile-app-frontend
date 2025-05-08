import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VehicleRegistrationPage extends StatefulWidget {
  @override
  _VehicleRegistrationPageState createState() =>
      _VehicleRegistrationPageState();
}

class _VehicleRegistrationPageState extends State<VehicleRegistrationPage> {
  final TextEditingController _regNoController = TextEditingController();
  final TextEditingController _fuelTypeController = TextEditingController();
  final TextEditingController _chassiNoController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();

  String _responseMessage = '';

  Future<void> submitVehicle() async {
    final url = Uri.parse('http://localhost:5285/api/vehicles'); // Updated URL

    final vehicleData = {
      'registrationNumber': _regNoController.text,
      'fuelType': _fuelTypeController.text,
      'chassiNumber': _chassiNoController.text,
      'brand': _brandController.text,
      'model': _modelController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(vehicleData),
      );

      if (response.statusCode == 201) {
        setState(() {
          _responseMessage = 'Vehicle submitted successfully!';
        });
      } else {
        setState(() {
          _responseMessage = 'Failed: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = 'Error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Registration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              decoration: InputDecoration(labelText: 'Chassi Number'),
            ),
            TextField(
              controller: _brandController,
              decoration: InputDecoration(labelText: 'Brand'),
            ),
            TextField(
              controller: _modelController,
              decoration: InputDecoration(labelText: 'Model'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitVehicle,
              child: Text('Submit Vehicle'),
            ),
            SizedBox(height: 20),
            Text(_responseMessage),
          ],
        ),
      ),
    );
  }
}