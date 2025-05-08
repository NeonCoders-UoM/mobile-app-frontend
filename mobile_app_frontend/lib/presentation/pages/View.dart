import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VehicleDetailsPage extends StatefulWidget {
  @override
  _VehicleDetailsPageState createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  final TextEditingController _vehicleIdController = TextEditingController();
  Map<String, dynamic>? vehicle;
  String errorMessage = '';

  // Function to load vehicle by ID
  Future<void> loadVehicleById() async {
    final String vehicleId = _vehicleIdController.text.trim();
    if (vehicleId.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a valid vehicle ID';
      });
      return;
    }

    final url = Uri.parse(
        'http://localhost:5285/api/vehicles/$vehicleId'); // Change to your API endpoint

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          vehicle = json.decode(response.body);
          errorMessage = ''; // Clear any previous error message
        });
      } else {
        setState(() {
          errorMessage =
              'Failed to load vehicle. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input field to enter vehicle ID
            TextField(
              controller: _vehicleIdController,
              decoration: InputDecoration(labelText: 'Enter Vehicle ID'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 10),
            // Button to trigger API call
            ElevatedButton(
              onPressed: loadVehicleById,
              child: Text('Fetch Vehicle Details'),
            ),
            SizedBox(height: 20),
            // Show error message if any
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
            // Display vehicle data if available
            if (vehicle != null) ...[
              Text('Registration Number: ${vehicle!['registrationNumber']}'),
              Text('Fuel Type: ${vehicle!['fuelType']}'),
              Text('Brand: ${vehicle!['brand']}'),
              Text('Model: ${vehicle!['model']}'),
              Text('Chassi Number: ${vehicle!['chassiNumber']}'),
              Text('Customer ID: ${vehicle!['customerID']}'),
            ],
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Vehicle Registration',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: VehicleDetailsPage(), // Set the VehicleDetailsPage as the home page
  ));
}
