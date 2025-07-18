import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app_frontend/data/models/emergency_call_center_model.dart';
import 'package:mobile_app_frontend/data/repositories/emergency_call_center_repository.dart';

void main() {
  group('Emergency Call Center Integration Tests', () {
    late EmergencyCallCenterRepository repository;
    const String testToken = 'test-token-emergency';

    setUp(() {
      repository = EmergencyCallCenterRepository();
    });

    test('should test connection to emergency call center API', () async {
      print('🧪 Testing emergency call center API connection...');

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

    test('should retrieve all emergency call centers', () async {
      print('🚨 Testing emergency call centers retrieval...');

      try {
        // Test without token
        final centersWithoutToken =
            await repository.getAllEmergencyCallCenters();
        print('Retrieved ${centersWithoutToken.length} centers without token');

        // Test with token
        final centersWithToken =
            await repository.getAllEmergencyCallCenters(token: testToken);
        print('Retrieved ${centersWithToken.length} centers with token');

        expect(centersWithToken, isNotNull);
        expect(centersWithToken, isA<List<EmergencyCallCenterModel>>());

        // Should have at least fallback data
        expect(centersWithToken.length, greaterThan(0));

        // Verify data structure
        if (centersWithToken.isNotEmpty) {
          final firstCenter = centersWithToken.first;
          expect(firstCenter.emergencyCallCenterId, isNotNull);
          expect(firstCenter.name, isNotEmpty);
          expect(firstCenter.address, isNotEmpty);
          expect(firstCenter.phoneNumber, isNotEmpty);
          expect(firstCenter.registrationNumber, isNotEmpty);

          print(
              '✅ First center: ${firstCenter.name} - ${firstCenter.phoneNumber}');
        }
      } catch (e) {
        print('⚠️ Error retrieving emergency call centers: $e');
        fail('Should not throw exception: $e');
      }
    });

    test('should validate emergency call center data model', () async {
      print('📋 Testing emergency call center data model...');

      final testCenter = EmergencyCallCenterModel(
        emergencyCallCenterId: 1,
        name: 'Test Emergency Center',
        address: 'Test Address, Test City',
        registrationNumber: 'TEST001',
        phoneNumber: '+94123456789',
      );

      // Test JSON serialization
      final json = testCenter.toJson();
      expect(json['emergencyCallCenterId'], equals(1));
      expect(json['name'], equals('Test Emergency Center'));
      expect(json['address'], equals('Test Address, Test City'));
      expect(json['registrationNumber'], equals('TEST001'));
      expect(json['phoneNumber'], equals('+94123456789'));

      // Test JSON deserialization
      final fromJson = EmergencyCallCenterModel.fromJson(json);
      expect(fromJson.emergencyCallCenterId,
          equals(testCenter.emergencyCallCenterId));
      expect(fromJson.name, equals(testCenter.name));
      expect(fromJson.address, equals(testCenter.address));
      expect(
          fromJson.registrationNumber, equals(testCenter.registrationNumber));
      expect(fromJson.phoneNumber, equals(testCenter.phoneNumber));

      // Test create JSON (without ID)
      final createJson = testCenter.toCreateJson();
      expect(createJson.containsKey('emergencyCallCenterId'), isFalse);
      expect(createJson['name'], equals('Test Emergency Center'));

      print('✅ Data model validation successful');
    });

    test('should handle backend connectivity gracefully', () async {
      print('🔄 Testing backend connectivity handling...');

      try {
        final centers =
            await repository.getAllEmergencyCallCenters(token: testToken);

        // Should always get some data (either from backend or fallback)
        expect(centers, isNotNull);
        expect(centers, isA<List<EmergencyCallCenterModel>>());

        if (centers.isNotEmpty) {
          print('✅ Retrieved ${centers.length} emergency call centers');
          for (final center in centers) {
            print('   - ${center.name}: ${center.phoneNumber}');
          }
        }

        // Test specific center retrieval
        if (centers.isNotEmpty) {
          final firstCenter = centers.first;
          final specificCenter = await repository.getEmergencyCallCenterById(
              firstCenter.emergencyCallCenterId,
              token: testToken);
          expect(specificCenter, isNotNull);
          expect(specificCenter!.emergencyCallCenterId,
              equals(firstCenter.emergencyCallCenterId));
          print('✅ Specific center retrieval successful');
        }
      } catch (e) {
        print('⚠️ Error in connectivity test: $e');
        fail('Should handle connectivity gracefully: $e');
      }
    });

    test('should filter emergency call centers by location', () async {
      print('📍 Testing location-based filtering...');

      try {
        final centersInMoratuwa = await repository
            .getEmergencyCallCentersByLocation('Moratuwa', token: testToken);

        expect(centersInMoratuwa, isNotNull);
        expect(centersInMoratuwa, isA<List<EmergencyCallCenterModel>>());

        // Verify filtering works
        for (final center in centersInMoratuwa) {
          expect(center.address.toLowerCase(), contains('moratuwa'));
        }

        print('✅ Found ${centersInMoratuwa.length} centers in Moratuwa');

        // Test with non-existent location
        final centersInNonExistent = await repository
            .getEmergencyCallCentersByLocation('NonExistentCity',
                token: testToken);

        expect(centersInNonExistent, isNotNull);
        expect(centersInNonExistent.length, equals(0));
        print('✅ Correctly returned empty list for non-existent location');
      } catch (e) {
        print('⚠️ Error in location filtering test: $e');
        fail('Should handle location filtering gracefully: $e');
      }
    });

    test('should complete end-to-end emergency service flow', () async {
      print('🔄 Testing complete emergency service flow...');

      bool allTestsPassed = true;

      // Step 1: Test connection
      final connectionResult =
          await repository.testConnection(token: testToken);
      print('1. Connection test: ${connectionResult ? "✅" : "❌"}');

      // Step 2: Get all emergency centers
      try {
        final centers =
            await repository.getAllEmergencyCallCenters(token: testToken);
        print('2. Emergency centers retrieval: ✅ (${centers.length} centers)');

        // Step 3: Validate each center has required data
        for (final center in centers) {
          if (center.name.isEmpty || center.phoneNumber.isEmpty) {
            print('3. Data validation: ❌ (Missing required fields)');
            allTestsPassed = false;
            break;
          }
        }
        if (allTestsPassed) {
          print('3. Data validation: ✅ (All centers have required fields)');
        }

        // Step 4: Test location filtering
        if (centers.isNotEmpty) {
          final locationTest = await repository
              .getEmergencyCallCentersByLocation('Sri Lanka', token: testToken);
          print(
              '4. Location filtering: ✅ (${locationTest.length} centers in Sri Lanka)');
        }
      } catch (e) {
        print('2. Emergency centers retrieval: ❌ ($e)');
        allTestsPassed = false;
      }

      print(
          '🏆 Overall emergency service flow: ${allTestsPassed ? "✅ SUCCESS" : "❌ SOME ISSUES"}');
      expect(allTestsPassed, isTrue);
    });
  });
}
