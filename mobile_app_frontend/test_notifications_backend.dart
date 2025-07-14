import 'dart:convert';
import 'package:http/http.dart' as http;

// Simple script to test notifications API connection and functionality
void main() async {
  const String baseUrl = 'http://localhost:5039/api';

  print('🔔 Testing Notifications API Integration');
  print('=' * 50);

  try {
    // Test 1: Get all notifications
    print('\n1. Testing GET /Notifications');
    final allNotificationsResponse = await http.get(
      Uri.parse('$baseUrl/Notifications'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    print('Status: ${allNotificationsResponse.statusCode}');
    if (allNotificationsResponse.statusCode == 200) {
      final data = json.decode(allNotificationsResponse.body);
      print('Response: ${data.length} notifications found');
      if (data.isNotEmpty) {
        print('First notification: ${data[0]}');
      }
    } else {
      print('Error: ${allNotificationsResponse.body}');
    }

    // Test 2: Get customer notifications
    print('\n2. Testing GET /Notifications/Customer/1');
    final customerNotificationsResponse = await http.get(
      Uri.parse('$baseUrl/Notifications/Customer/1'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    print('Status: ${customerNotificationsResponse.statusCode}');
    if (customerNotificationsResponse.statusCode == 200) {
      final data = json.decode(customerNotificationsResponse.body);
      print('Response: ${data.length} notifications found for customer 1');
      for (var notification in data) {
        print('  - ${notification['title']}: ${notification['message']}');
        print(
            '    Priority: ${notification['priority']}, Read: ${notification['isRead']}');
      }
    } else {
      print('Error: ${customerNotificationsResponse.body}');
    }

    // Test 3: Get unread notifications
    print('\n3. Testing GET /Notifications/Customer/1/Unread');
    final unreadNotificationsResponse = await http.get(
      Uri.parse('$baseUrl/Notifications/Customer/1/Unread'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    print('Status: ${unreadNotificationsResponse.statusCode}');
    if (unreadNotificationsResponse.statusCode == 200) {
      final data = json.decode(unreadNotificationsResponse.body);
      print('Response: ${data.length} unread notifications found');
    } else {
      print('Error: ${unreadNotificationsResponse.body}');
    }

    // Test 4: Get notification summary
    print('\n4. Testing GET /Notifications/Summary/1');
    final summaryResponse = await http.get(
      Uri.parse('$baseUrl/Notifications/Summary/1'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    print('Status: ${summaryResponse.statusCode}');
    if (summaryResponse.statusCode == 200) {
      final data = json.decode(summaryResponse.body);
      print('Summary:');
      print('  - Total: ${data['totalNotifications']}');
      print('  - Unread: ${data['unreadNotifications']}');
      print('  - Pending: ${data['pendingNotifications']}');
      print('  - Sent: ${data['sentNotifications']}');
    } else {
      print('Error: ${summaryResponse.body}');
    }

    // Test 5: Get pending notifications
    print('\n5. Testing GET /Notifications/Pending');
    final pendingResponse = await http.get(
      Uri.parse('$baseUrl/Notifications/Pending'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));

    print('Status: ${pendingResponse.statusCode}');
    if (pendingResponse.statusCode == 200) {
      final data = json.decode(pendingResponse.body);
      print('Response: ${data.length} pending notifications found');
      if (data.isNotEmpty) {
        print('First pending notification: ${data[0]['title']}');
      }
    } else {
      print('Error: ${pendingResponse.body}');
    }

    // Test 6: Create a test notification
    print('\n6. Testing POST /Notifications');
    final createData = {
      'customerId': 1,
      'serviceReminderId': 1, // Assuming a service reminder exists
      'title': 'Test Notification from Flutter',
      'message':
          'This is a test notification created from the Flutter app to verify API integration.',
      'type': 'test',
      'priority': 'Medium',
      'scheduledFor': null, // Send immediately
    };

    final createResponse = await http
        .post(
          Uri.parse('$baseUrl/Notifications'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: json.encode(createData),
        )
        .timeout(const Duration(seconds: 10));

    print('Status: ${createResponse.statusCode}');
    if (createResponse.statusCode == 201) {
      final data = json.decode(createResponse.body);
      print(
          'Created notification: ${data['title']} with ID ${data['notificationId']}');
      print('Message: ${data['message']}');

      // Test 7: Mark the created notification as read
      final notificationId = data['notificationId'];
      print('\n7. Testing PUT /Notifications/$notificationId/MarkAsRead');

      final markReadResponse = await http.put(
        Uri.parse('$baseUrl/Notifications/$notificationId/MarkAsRead'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('Mark as read status: ${markReadResponse.statusCode}');
      if (markReadResponse.statusCode == 204 ||
          markReadResponse.statusCode == 200) {
        print('✅ Successfully marked notification as read');
      } else {
        print('❌ Failed to mark as read: ${markReadResponse.body}');
      }

      // Test 8: Delete the test notification
      print('\n8. Testing DELETE /Notifications/$notificationId');

      final deleteResponse = await http.delete(
        Uri.parse('$baseUrl/Notifications/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('Delete status: ${deleteResponse.statusCode}');
      if (deleteResponse.statusCode == 204 ||
          deleteResponse.statusCode == 200) {
        print('✅ Successfully deleted test notification');
      } else {
        print('❌ Failed to delete: ${deleteResponse.body}');
      }
    } else {
      print('❌ Failed to create notification: ${createResponse.body}');
    }
  } catch (e) {
    print('❌ Connection test failed: $e');
    print(
        '\n💡 Make sure your .NET backend is running on http://localhost:5039');
    print(
        '💡 Check that the NotificationsController is implemented and accessible');
    return;
  }

  print('\n' + '=' * 50);
  print('🏁 Notifications API Test Complete');
  print('\n💡 Next Steps:');
  print('   1. If tests failed, ensure your .NET API is running');
  print('   2. Verify that CORS is configured to allow Flutter requests');
  print('   3. Test the notifications page in the Flutter app');
  print(
      '   4. Check that customer and service reminder data exists in your database');
  print('   5. Test real-time notification functionality');
}
