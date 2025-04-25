import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/vehicle_header.dart';

class CarComponent extends StatelessWidget {
  const CarComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const VehicleHeader(
            vehicleName: "Mustang 1977",
            vehicleId: "AB899395",
          ),
          const SizedBox(height: 32.0),
          Container(
            height: 141,
            width: 360,
            child: Image.asset(
              'assets/images/mustang.png',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
