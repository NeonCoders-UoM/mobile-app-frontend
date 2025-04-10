import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/car_component.dart';

class DocumentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Document Page'),
      ),
      body: Center(
        child: CarComponent(
          carName: "Mustang 1977",
          carNumber: "AB899395",
          imagePath: "assets/images/Mustang.svg",
        ),
      ),
    );
  }
}
