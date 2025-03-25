import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'enums/button_type.dart';
import 'enums/button_size.dart';
import 'enums/button_state.dart';

class CustomButton extends StatefulWidget {
  final String label; // Button text
  final ButtonType type; // Primary, Secondary, or Text
  final ButtonSize size; // Small, Medium, or Large
  final VoidCallback onTap; // Callback for when the button is tapped
  final double? customWidth; // Optional custom width
  final double? customHeight; // Optional custom height
  final IconData? leadingIcon; // Optional leading icon
  final IconData? trailingIcon; // Optional trailing icon
  final bool showLeadingIcon; // Toggle for leading icon visibility
  final bool showTrailingIcon; // Toggle for trailing icon visibility

  const CustomButton({
    Key? key,
    required this.label,
    required this.type,
    required this.size,
    required this.onTap,
    this.customWidth,
    this.customHeight,
    this.leadingIcon,
    this.trailingIcon,
    this.showLeadingIcon = false,
    this.showTrailingIcon = false,
  }) : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  ButtonState _currentState = ButtonState.defaultState;

  // Determine button dimensions based on size
  double _getWidth() {
    if (widget.customWidth != null) return widget.customWidth!;
    switch (widget.size) {
      case ButtonSize.small:
        return 123.0;
      case ButtonSize.medium:
        return 154.0;
      case ButtonSize.large:
        return 192.0;
    }
  }

  double _getHeight() {
    if (widget.customHeight != null) return widget.customHeight!;
    switch (widget.size) {
      case ButtonSize.small:
        return 40.0;
      case ButtonSize.medium:
        return 48.0;
      case ButtonSize.large:
        return 56.0;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return 16.0;
      case ButtonSize.medium:
        return 20.0;
      case ButtonSize.large:
        return 24.0;
    }
  }

  // Determine text style based on size
  TextStyle _getTextStyle() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppTextStyles.textSmSemibold.copyWith(color: _getTextColor());
      case ButtonSize.medium:
        return AppTextStyles.textMdSemibold.copyWith(color: _getTextColor());
      case ButtonSize.large:
        return AppTextStyles.textLgSemibold.copyWith(color: _getTextColor());
    }
  }

  // Determine button styles based on type and state
  Color _getBackgroundColor() {
    switch (widget.type) {
      case ButtonType.primary:
        if (_currentState == ButtonState.active) return AppColors.primary100;
        if (_currentState == ButtonState.hover) return AppColors.primary300;
        return AppColors.primary200;
      case ButtonType.secondary:
        if (_currentState == ButtonState.active) return AppColors.neutral100;
        if (_currentState == ButtonState.hover) return AppColors.neutral100;
        return AppColors.neutral100;
      case ButtonType.text:
        return Colors.transparent;
    }
  }

  Color _getBorderColor() {
    switch (widget.type) {
      case ButtonType.primary:
        return AppColors.primary200;
      case ButtonType.secondary:
        return AppColors.primary200;
      case ButtonType.text:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    switch (widget.type) {
      case ButtonType.primary:
        return AppColors.neutral100; // Same for all states
      case ButtonType.secondary:
        if (_currentState == ButtonState.active) return AppColors.primary100;
        if (_currentState == ButtonState.hover) return AppColors.primary300;
        return AppColors.primary200;
      case ButtonType.text:
        if (_currentState == ButtonState.active) return AppColors.primary100;
        if (_currentState == ButtonState.hover) return AppColors.primary300;
        return AppColors.primary200;
    }
  }

  Color _getIconColor() {
    return _getTextColor(); // Icons use the same color as the text for consistency
  }

  // Ripple effect color for InkWell
  Color _getSplashColor() {
    switch (widget.type) {
      case ButtonType.primary:
        return AppColors.primary200.withOpacity(0.3);
      case ButtonType.secondary:
        return AppColors.neutral300.withOpacity(0.3);
      case ButtonType.text:
        return AppColors.neutral300.withOpacity(0.3);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Required for InkWell to work properly
      child: InkWell(
        onTapDown: (details) {
          setState(() {
            _currentState = ButtonState.hover; // Simulate hover on press down
          });
        },
        onTapUp: (details) {
          setState(() {
            _currentState =
                ButtonState.defaultState; // Back to default on release
          });
        },
        onTapCancel: () {
          setState(() {
            _currentState =
                ButtonState.defaultState; // Back to default if tap is canceled
          });
        },
        onTap: () {
          setState(() {
            _currentState = ButtonState.active; // Active state on tap
          });
          widget.onTap(); // Trigger the callback
        },
        splashColor: _getSplashColor(), // Ripple effect color
        borderRadius:
            BorderRadius.circular(8.0), // Match the button's border radius
        child: Container(
          width: _getWidth(),
          height: _getHeight(),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            border: Border.all(color: _getBorderColor(), width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Leading Icon (if enabled and provided)
              if (widget.showLeadingIcon && widget.leadingIcon != null) ...[
                Icon(
                  widget.leadingIcon,
                  size: _getIconSize(),
                  color: _getIconColor(),
                ),
                const SizedBox(width: 8.0), // Space between icon and text
              ],
              // Button Label
              Text(
                widget.label,
                style: _getTextStyle(),
              ),
              // Trailing Icon (if enabled and provided)
              if (widget.showTrailingIcon && widget.trailingIcon != null) ...[
                const SizedBox(width: 8.0), // Space between text and icon
                Icon(
                  widget.trailingIcon,
                  size: _getIconSize(),
                  color: _getIconColor(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
