import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class CustomTextField extends StatefulWidget {
  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  bool _isFocused = false;
  bool _isHovered = false;
  bool _showCursor = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });

      if (_isFocused) {
        _startCursorBlink();
      }
    });
  }

  void _startCursorBlink() {
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (!_isFocused) {
        timer.cancel();
      }
      setState(() {
        _showCursor = !_showCursor;
      });
    });
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.character != null) {
      setState(() {
        _controller.text += event.character!;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _controller.text.isNotEmpty) {
      setState(() {
        _controller.text =
            _controller.text.substring(0, _controller.text.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(_focusNode);
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: RawKeyboardListener(
          focusNode: _focusNode,
          onKey: _handleKeyPress,
          child: CustomPaint(
            size: Size(200, 50),
            painter: TextFieldPainter(
                _controller.text, _isFocused, _isHovered, _showCursor),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}

class TextFieldPainter extends CustomPainter {
  final String text;
  final bool isFocused;
  final bool isHovered;
  final bool showCursor;

  TextFieldPainter(this.text, this.isFocused, this.isHovered, this.showCursor);

  @override
  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the background fill
    final Paint backgroundPaint = Paint()
      ..color = isFocused
          ? Color.fromARGB(255, 231, 232, 233) // Focused state color
          : (isHovered
              ? Color.fromARGB(255, 236, 237, 238) // Hover color
              : Color.fromARGB(255, 255, 255, 255)); // Default color

    final RRect textFieldRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(8),
    );

    // Draw filled background
    canvas.drawRRect(textFieldRect, backgroundPaint);

    // Paint for the stroke/border
    final Paint strokePaint = Paint()
      ..color = Color.fromARGB(255, 123, 123, 123) // Border color (Black)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2; // Border thickness

    // Draw the stroke
    canvas.drawRRect(textFieldRect, strokePaint);

    // Text style
    final textStyle = TextStyle(
      color: Color(0xFFFFFFFF),
      fontSize: 18,
    );

    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final double textX = 10;
    final double textY = size.height / 2 - textPainter.height / 2;

    textPainter.paint(canvas, Offset(textX, textY));

    // Draw cursor
    if (isFocused && showCursor) {
      final Paint cursorPaint = Paint()
        ..color = Color(0xFFFFFFFF)
        ..strokeWidth = 2;

      final double cursorX = textX + textPainter.width + 2;
      final double cursorY1 = textY;
      final double cursorY2 = textY + textPainter.height;

      canvas.drawLine(
          Offset(cursorX, cursorY1), Offset(cursorX, cursorY2), cursorPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
