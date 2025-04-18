import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuccessfulMessage extends StatelessWidget {
  const SuccessfulMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Para 1'),
        SvgPicture.asset(
          'assets/icons/success_icon.svg',
          width: 200,
          height: 200,
        ),
        Text('Para 2'),
      ],
    );
  }
}
