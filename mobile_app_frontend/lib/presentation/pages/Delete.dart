import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeleteVehicle extends StatefulWidget {
  @override
  _DeleteVehiclePageState createState() => _DeleteVehiclePageState();
}

class _DeleteVehiclePageState extends State<DeleteVehicle> {
  String _responseMessage = '';
  final int vehicleId = 35; // Hardcoded VehicleID

  // Function to delete vehicle by ID = 35
  Future<void> deleteVehicle() async {
    final url = Uri.parse('http://localhost:5285/api/vehicles/$vehicleId'); // Adjust endpoint if needed

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _responseMessage = 'Vehicle with ID $vehicleId deleted successfully!';
        });
      } else {
        setState(() {
          _responseMessage =
              'Failed to delete vehicle. Status code: ${response.statusCode} - ${response.body}';
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
        title: Text('Delete Vehicle'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delete Vehicle ID: $vehicleId',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: deleteVehicle,
              child: Text('Delete Vehicle'),
            ),
            SizedBox(height: 20),
            Text(
              _responseMessage,
              style: TextStyle(
                color: _responseMessage.contains('success')
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Vehicle Deletion',
    theme: ThemeData(primarySwatch: Colors.blue),
    home: DeleteVehicle(),
  ));
}
