import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/successful-message.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';
import 'package:mobile_app_frontend/presentation/pages/login_page.dart'; // or next step

class PaymentSuccessfulMessagePage extends StatelessWidget {
  final int customerId;
  final int vehicleId;
  final String token;

  const PaymentSuccessfulMessagePage({
    Key? key,
    required this.customerId,
    required this.vehicleId,
    required this.token,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral400,
      body: Column(
        children: [
          SizedBox(
            height: 116,
          ),
          SuccessfulMessage(
              para1: 'Thank you', para2: 'Payment done successfully'),
          SizedBox(
            height: 404,
          ),
          CustomButton(
            label: 'Home',
            type: ButtonType.primary,
            size: ButtonSize.large,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VehicleDetailsHomePage(
                          customerId: customerId, token: token)));
            },
            customWidth: 360.0,
            customHeight: 56.0,
          ),
        ],
      ),
    );
  }
}
