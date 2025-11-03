import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/pages/start_page.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app_frontend/state/providers/vehicle_provider.dart';
import 'package:mobile_app_frontend/data/repositories/vehicle_repository.dart';

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
        home: StartPage(),
      ),
    );
  }
}
