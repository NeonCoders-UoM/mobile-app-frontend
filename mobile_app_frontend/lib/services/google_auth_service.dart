import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleAuthService {
  final String _baseUrl = 'http://192.168.1.4:5039/api';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Web Client ID - used to get ID tokens for backend authentication
    serverClientId:
        '480576785725-7gpns733ivm4g52oe54nu0r4bnl7f6oo.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  /// Sign in with Google and authenticate with backend
  /// Returns {token, customerId, isNewUser} on success, null on failure
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        print('❌ Google Sign-In cancelled by user');
        return null;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        print('❌ Failed to get Google ID token');
        return null;
      }

      print('✅ Google Sign-In successful: ${googleUser.email}');
      print('🔑 Got ID token: ${idToken.substring(0, 20)}...');

      // Send the ID token to the backend for verification
      final response = await http.post(
        Uri.parse('$_baseUrl/Auth/google-login-customer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Backend authentication successful');
        return {
          'token': data['token'],
          'customerId': data['customerId'],
          'isNewUser': data['isNewUser'] ?? false,
        };
      } else {
        print('❌ Backend auth failed: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      return null;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    print('✅ Signed out from Google');
  }

  /// Check if user is currently signed in with Google
  Future<bool> isSignedIn() async {
    return _googleSignIn.isSignedIn();
  }
}
