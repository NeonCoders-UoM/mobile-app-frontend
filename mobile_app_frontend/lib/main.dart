import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/pages/start_page.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app_frontend/state/providers/vehicle_provider.dart';
import 'package:mobile_app_frontend/data/repositories/vehicle_repository.dart';
import 'package:mobile_app_frontend/services/admob_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AdMob
  await AdMobService.initialize();
  
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
                'http://192.168.8.161:5039'), // Base URL for actual devices
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: StartPage(),
      ),
    );
  }
}
