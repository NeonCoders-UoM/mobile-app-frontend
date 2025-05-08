import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vehicle Registration App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VehicleDetailsPage(), // Set the home page directly here
    );
  }
}
