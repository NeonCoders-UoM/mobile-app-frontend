import 'dart:ui';
import 'package:flutter/widgets.dart';

class CustomButton extends StatefulWidget {
  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool isPressed = false;
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) => setState(() => isPressed = false),
      onTapCancel: () => setState(() => isPressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: CustomPaint(
          size: Size(150, 50),
          painter: ButtonPainter(isPressed, isHovered),
        ),
      ),
    );
  }
}

class ButtonPainter extends CustomPainter {
  final bool isPressed;
  final bool isHovered;

  ButtonPainter(this.isPressed, this.isHovered);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = isPressed
          ? Color(0xFF004080) // Darker blue when pressed
          : (isHovered
              ? Color(0xFF007BFF)
              : Color(0xFF0056B3)); // Hover & normal states

    final RRect buttonRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(10),
    );

    canvas.drawRRect(buttonRect, paint);

    final textStyle = TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    final textSpan = TextSpan(
      text: 'Custom Button',
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(size.width / 2 - textPainter.width / 2,
          size.height / 2 - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
