import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/service_history_card.dart';

class ServiceHistoryPage extends StatelessWidget {
  const ServiceHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> serviceRecords = [
      {
        'title': 'Oil Change',
        'description': 'Janaka Motors, Kalutara\nCompleted',
        'date': '14, Feb, 2025',
      },
      {
        'title': 'Air Filter Replacement',
        'description': 'Service Station\nStatus',
        'date': '23, Jan, 2023',
      },
      {
        'title': 'Wheel Alignment',
        'description': 'Service Station\nStatus',
        'date': '15, Dec, 2024',
      },
      {
        'title': 'Coolant Flush',
        'description': 'Service Station\nStatus',
        'date': '26, Jun, 2025',
      },
      {
        'title': 'Transmission Service',
        'description': 'Service Station\nStatus',
        'date': '14, Feb, 2025',
      },
      {
        'title': 'Air Filter Replacement',
        'description': 'Service Station\nStatus',
        'date': '15, Dec, 2024',
      },
      {
        'title': 'Wheel Alignment',
        'description': 'Service Station\nStatus',
        'date': '15, Dec, 2024',
      },
      {
        'title': 'Air Filter Replacement',
        'description': 'Service Station\nStatus',
        'date': '15, Dec, 2024',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: const CustomAppBar(title: 'Service History'),
      body: ListView.builder(
        itemCount: serviceRecords.length,
        itemBuilder: (context, index) {
          final record = serviceRecords[index];
          return ServiceHistoryCard(
            title: record['title'] as String,
            description: record['description'] as String,
            date: record['date'] as String,
          );
        },
      ),
    );
  }
}
