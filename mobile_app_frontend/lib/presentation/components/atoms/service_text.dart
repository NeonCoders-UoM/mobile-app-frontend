import 'package:flutter/material.dart';

class ServiceText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  const ServiceText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
    );
  }
}
