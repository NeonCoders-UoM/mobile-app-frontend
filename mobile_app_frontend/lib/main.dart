import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/pages/change_password_page.dart';

void main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChangePasswordPage(),
    );
  }
}
