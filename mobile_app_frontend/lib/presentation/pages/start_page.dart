import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/pages/login_page.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  void _handleLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Set a fixed-size container for the image instead of expanding
          Container(
            height: 861, // adjust this height as needed
            width: 440,
            child: Image.asset(
              'assets/images/start_car_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Overlay content at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      label: 'Start',
                      type: ButtonType.primary,
                      size: ButtonSize.medium,
                      onTap: () => _handleLogin(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
