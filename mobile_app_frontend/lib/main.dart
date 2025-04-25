import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/pages/profile_options_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Options Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ProfileOptionPage(), // 👈 Set your page here
    );
  }
}
