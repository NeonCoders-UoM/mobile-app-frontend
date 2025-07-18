import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Quick Fuel API Test');
  print('=' * 40);

  // Test both ports to see which one works
  await testPort(5000);
  await testPort(5039);

  print('\n🔍 Direct database check...');
  await testDirectApiCall();
}

Future<void> testPort(int port) async {
  print('\n📡 Testing port $port...');

  try {
    final url = 'http://localhost:$port/api/FuelEfficiency/vehicle/1';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    ).timeout(Duration(seconds: 5));

    print('   Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('   ✅ Success! Records: ${data.length}');

      if (data.isNotEmpty) {
        final latest = data.last;
        print(
            '   📋 Latest: ${latest['notes'] ?? 'No notes'} (${latest['fuelDate']})');
      }
    } else {
      print('   ❌ Failed: ${response.body}');
    }
  } catch (e) {
    print('   ❌ Error: ${e.toString().split(':').first}');
  }
}

Future<void> testDirectApiCall() async {
  try {
    // Test with the URL that should work
    final response = await http.get(
      Uri.parse('http://localhost:5000/api/FuelEfficiency'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('📊 Total records in database: ${data.length}');

      // Find records with recent timestamps
      final recent = data.where((record) {
        final createdAt = DateTime.parse(record['createdAt']);
        final now = DateTime.now();
        return now.difference(createdAt).inMinutes < 60; // Last hour
      }).toList();

      print('🕐 Records from last hour: ${recent.length}');

      for (final record in recent) {
        print('   - ${record['notes']} (${record['createdAt']})');
      }
    }
  } catch (e) {
    print('❌ Database check failed: $e');
  }
}
