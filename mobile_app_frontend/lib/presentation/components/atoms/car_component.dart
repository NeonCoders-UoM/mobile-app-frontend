import 'package:flutter/material.dart';

class CarComponent extends StatelessWidget {
  final String carName;
  final String carNumber;
  final String imagePath;

  const CarComponent({
    Key? key,
    required this.carName,
    required this.carNumber,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      width: 300,
      height: 350,
      decoration: BoxDecoration(
        color: Color(0xFF2B1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            carName,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            carNumber,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white54,
            ),
          ),
          SizedBox(height: 16),
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
