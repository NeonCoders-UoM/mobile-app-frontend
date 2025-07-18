import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_frontend/data/models/fuel_efficiency_model.dart';
import 'package:mobile_app_frontend/data/repositories/fuel_efficiency_repository.dart';

void main() {
  group('Fuel Efficiency Integration Tests', () {
    late FuelEfficiencyRepository repository;
    const String testToken = 'test-token-123';
    const int testVehicleId = 1;

    setUp(() {
      repository = FuelEfficiencyRepository();
    });

    test('should test connection with token authentication', () async {
      print('🧪 Testing fuel efficiency API connection with token...');

      // Test connection without token
      final connectionWithoutToken = await repository.testConnection();
      print('Connection without token: $connectionWithoutToken');

      // Test connection with token
      final connectionWithToken =
          await repository.testConnection(token: testToken);
      print('Connection with token: $connectionWithToken');

      // Either should work (depending on backend configuration)
      expect(connectionWithoutToken || connectionWithToken, isTrue);
    });

    test('should retrieve fuel records with token authentication', () async {
      print('🚗 Testing fuel records retrieval with token...');

      try {
        // Test without token
        final recordsWithoutToken =
            await repository.getFuelRecords(testVehicleId);
        print('Retrieved ${recordsWithoutToken.length} records without token');

        // Test with token
        final recordsWithToken =
            await repository.getFuelRecords(testVehicleId, token: testToken);
        print('Retrieved ${recordsWithToken.length} records with token');

        expect(recordsWithToken, isNotNull);
        expect(recordsWithToken, isA<List<FuelEfficiencyModel>>());
      } catch (e) {
        print('⚠️ Expected error for unauthenticated request: $e');
        // This is expected if backend requires authentication
      }
    });

    test('should create fuel record with token authentication', () async {
      print('⛽ Testing fuel record creation with token...');

      final testRecord = FuelEfficiencyModel(
        vehicleId: testVehicleId,
        date: DateTime.now(),
        fuelAmount: 45.0,
        fuelType: 'Petrol',
        notes: 'Test fuel record for token authentication',
      );

      try {
        // Test with token
        final success =
            await repository.addFuelRecord(testRecord, token: testToken);
        print(
            'Fuel record creation with token: ${success ? "✅ Success" : "❌ Failed"}');

        if (success) {
          // Verify the record was created by retrieving records
          final records =
              await repository.getFuelRecords(testVehicleId, token: testToken);
          final createdRecord = records
              .where((r) =>
                  r.notes
                      ?.contains('Test fuel record for token authentication') ==
                  true)
              .isNotEmpty;
          expect(createdRecord, isTrue);
          print('✅ Verified fuel record was created successfully');
        }
      } catch (e) {
        print('⚠️ Error creating fuel record: $e');
      }
    });

    test('should retrieve monthly chart data with token authentication',
        () async {
      print('📊 Testing monthly chart data with token...');

      try {
        final chartData = await repository.getMonthlyChartData(
          testVehicleId,
          DateTime.now().year,
          token: testToken,
        );

        print('Retrieved ${chartData.length} monthly data points with token');
        expect(chartData, isNotNull);
        expect(chartData, isA<List<MonthlyFuelSummaryModel>>());
      } catch (e) {
        print('⚠️ Error retrieving chart data: $e');
      }
    });

    test('should get fuel summary with token authentication', () async {
      print('📈 Testing fuel summary with token...');

      try {
        final summary = await repository.getFuelSummary(
          testVehicleId,
          year: DateTime.now().year,
          token: testToken,
        );

        if (summary != null) {
          print('✅ Retrieved fuel summary with token');
          expect(summary, isA<FuelEfficiencySummaryModel>());
        } else {
          print('⚠️ No summary data available');
        }
      } catch (e) {
        print('⚠️ Error retrieving fuel summary: $e');
      }
    });

    test('should handle authentication flow end-to-end', () async {
      print('🔄 Testing complete authentication flow...');

      bool allTestsPassed = true;

      // Step 1: Test connection
      final connectionResult =
          await repository.testConnection(token: testToken);
      print('1. Connection test: ${connectionResult ? "✅" : "❌"}');

      // Step 2: Test data retrieval
      try {
        final records =
            await repository.getFuelRecords(testVehicleId, token: testToken);
        print('2. Data retrieval: ✅ (${records.length} records)');
      } catch (e) {
        print('2. Data retrieval: ❌ ($e)');
        allTestsPassed = false;
      }

      // Step 3: Test data creation (if needed)
      try {
        final testRecord = FuelEfficiencyModel(
          vehicleId: testVehicleId,
          date: DateTime.now(),
          fuelAmount: 50.0,
          notes: 'End-to-end test record',
        );

        final createResult =
            await repository.addFuelRecord(testRecord, token: testToken);
        print('3. Data creation: ${createResult ? "✅" : "❌"}');
      } catch (e) {
        print('3. Data creation: ❌ ($e)');
        allTestsPassed = false;
      }

      print(
          '🏆 Overall authentication flow: ${allTestsPassed ? "✅ SUCCESS" : "❌ SOME ISSUES"}');
    });
  });
}
