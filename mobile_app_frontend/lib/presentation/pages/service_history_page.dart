import 'package:flutter/material.dart';

class ServiceHistoryPage extends StatelessWidget {
  final int customerId;
  final int vehicleId;

  const ServiceHistoryPage({
    Key? key,
    required this.customerId,
    required this.vehicleId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Service History')),
      body: Center(
        child: Text('Service History for Customer $customerId, Vehicle $vehicleId'),
      ),
    );
  }
}