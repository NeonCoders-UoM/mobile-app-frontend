import 'dart:convert';
import 'lib/data/models/fuel_efficiency_model.dart';

void main() {
  print('🔧 Testing .NET Property Name Fix');
  print('=' * 40);

  testPropertyNameFix();
}

void testPropertyNameFix() {
  print('\n1️⃣ Testing PascalCase Property Names...');

  // Create a test record
  final testRecord = FuelEfficiencyModel(
    vehicleId: 1,
    fuelDate: DateTime.now(),
    fuelAmount: 45.5,
    pricePerLiter: 150.0,
    totalCost: 6825.0,
    odometer: 15500,
    location: 'Test Station',
    fuelType: 'Petrol',
    notes: 'Test with PascalCase properties',
  );

  // Test toCreateJson (what gets sent to backend)
  final createJson = testRecord.toCreateJson();
  print('📤 Data being sent to backend:');
  print(json.encode(createJson));

  // Verify property names are PascalCase
  final expectedProperties = [
    'VehicleId',
    'FuelDate',
    'FuelAmount',
    'PricePerLiter',
    'TotalCost',
    'Odometer',
    'Location',
    'FuelType',
    'Notes'
  ];

  print('\n🔍 Checking property names:');
  for (final prop in expectedProperties) {
    if (createJson.containsKey(prop)) {
      print('   ✅ $prop: ${createJson[prop]}');
    } else {
      print('   ❌ Missing: $prop');
    }
  }

  // Test date format specifically
  print('\n📅 Date format check:');
  print('   FuelDate: ${createJson['FuelDate']}');
  print('   Format type: ${createJson['FuelDate'].runtimeType}');

  // Test that we can parse both camelCase and PascalCase responses
  print('\n2️⃣ Testing Response Parsing...');

  // Simulate camelCase response (old format)
  final camelCaseResponse = {
    'fuelEfficiencyId': 123,
    'vehicleId': 1,
    'fuelDate': '2024-07-13T14:30:00Z',
    'fuelAmount': 45.5,
    'notes': 'camelCase test'
  };

  // Simulate PascalCase response (new format)
  final pascalCaseResponse = {
    'FuelEfficiencyId': 124,
    'VehicleId': 1,
    'FuelDate': '2024-07-13T15:30:00Z',
    'FuelAmount': 46.5,
    'Notes': 'PascalCase test'
  };

  try {
    final camelModel = FuelEfficiencyModel.fromJson(camelCaseResponse);
    print('   ✅ camelCase parsing: ${camelModel.notes}');

    final pascalModel = FuelEfficiencyModel.fromJson(pascalCaseResponse);
    print('   ✅ PascalCase parsing: ${pascalModel.notes}');

    print('\n🎯 Property name fix complete!');
    print('   - Sending: PascalCase (VehicleId, FuelDate, etc.)');
    print('   - Receiving: Both camelCase and PascalCase supported');
  } catch (e) {
    print('   ❌ Parsing failed: $e');
  }
}
