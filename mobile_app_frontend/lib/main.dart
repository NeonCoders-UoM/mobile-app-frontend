import 'package:flutter/material.dart';
//import 'presentation/components/atoms/custom_button.dart';
import 'presentation/components/atoms/custom_text_field.dart'; // Import the custom button

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Form Styling Demo';
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(title: const Text(appTitle)),
        body: const MyCustomForm(),
      ),
    );
  }
}
