import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/pages/account_deleted_page.dart'; // adjust path if needed

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AccountDeletedPage(), // 👈 this runs your page
    );
  }
}
