import 'dart:convert';
import 'lib/data/models/fuel_efficiency_model.dart';

void main() {
  print('🕐 Testing Date Formatting Fix');
  print('=' * 40);

  // Test different date scenarios
  testDateScenarios();
}

void testDateScenarios() {
  print('\n1️⃣ Testing Date Formatting...');

  final testDates = [
    DateTime.now(), // Current local time
    DateTime(2024, 7, 13), // Date picker result (midnight)
    DateTime(2024, 7, 13, 14, 30), // Specific time
    DateTime.utc(2024, 7, 13, 10, 15), // UTC time
  ];

  for (int i = 0; i < testDates.length; i++) {
    final testDate = testDates[i];
    print('\n   Test ${i + 1}: ${_getDateDescription(i)}');
    print('   Original: $testDate (UTC: ${testDate.isUtc})');

    try {
      final model = FuelEfficiencyModel(
        vehicleId: 1,
        fuelDate: testDate,
        fuelAmount: 40.0,
        notes: 'Test ${i + 1}',
      );

      final createJson = model.toCreateJson();
      print('   ✅ Formatted for backend: ${createJson['fuelDate']}');

      // Verify it's valid JSON
      final jsonString = json.encode(createJson);
      print('   📄 Valid JSON: ${jsonString.length} chars');
    } catch (e) {
      print('   ❌ Error: $e');
    }
  }
}

String _getDateDescription(int index) {
  switch (index) {
    case 0:
      return 'Current local time';
    case 1:
      return 'Date picker result (midnight)';
    case 2:
      return 'Specific time';
    case 3:
      return 'UTC time';
    default:
      return 'Unknown';
  }
}
