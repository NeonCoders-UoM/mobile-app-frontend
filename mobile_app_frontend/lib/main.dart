import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/pages/start_page.dart';
import 'package:mobile_app_frontend/presentation/pages/login_page.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';
import 'package:mobile_app_frontend/presentation/pages/payment_successful_message_page.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app_frontend/state/providers/vehicle_provider.dart';
import 'package:mobile_app_frontend/data/repositories/vehicle_repository.dart';
import 'package:mobile_app_frontend/core/services/local_storage.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => VehicleProvider(
            VehicleRepository(
                'http://localhost:5039'), // TODO: Replace with actual base URL
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  Map<String, dynamic>? _authData;
  Map<String, dynamic>? _paymentContext;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      // Check if user is authenticated
      final isAuth = await LocalStorageService.isAuthenticated();
      final authData = await LocalStorageService.getAuthData();
      final paymentContext = await LocalStorageService.getPaymentContext();

      print('🔍 Auth check: isAuthenticated=$isAuth');
      print('🔍 Auth data: ${authData != null ? "✅" : "❌"}');
      print('🔍 Payment context: ${paymentContext != null ? "✅" : "❌"}');

      setState(() {
        _isAuthenticated = isAuth;
        _authData = authData;
        _paymentContext = paymentContext;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error checking authentication: $e');
      setState(() {
        _isLoading = false;
        _isAuthenticated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    // If there's payment context, user is returning from payment
    if (_paymentContext != null && _authData != null) {
      print(
          '🔄 User returning from payment, navigating to PaymentSuccessfulMessagePage');
      return PaymentSuccessfulMessagePage(
        vehicleId: _paymentContext!['vehicleId'],
        token: _authData!['token'],
        customerId: _authData!['customerId'],
      );
    }

    // If user is authenticated, go to home page
    if (_isAuthenticated && _authData != null) {
      print('✅ User is authenticated, navigating to VehicleDetailsHomePage');
      return VehicleDetailsHomePage(
        customerId: _authData!['customerId'],
        token: _authData!['token'],
      );
    }

    // Otherwise, show start page
    print('❌ User not authenticated, showing StartPage');
    return StartPage();
  }
}
