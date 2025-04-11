import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';

class InputFieldAtom extends StatefulWidget {
  final InputFieldState state;
  final String? label;
  final String placeholder;
  final String? helperText;
  final bool showHelperText; // New parameter to toggle helper text visibility
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool showLeadingIcon;
  final bool showTrailingIcon;
  final VoidCallback? onLeadingIconTap;
  final VoidCallback? onTrailingIconTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;

  const InputFieldAtom({
    super.key,
    required this.state,
    this.label,
    required this.placeholder,
    this.helperText,
    this.showHelperText = true, // Default to true
    this.leadingIcon,
    this.trailingIcon,
    this.showLeadingIcon = true,
    this.showTrailingIcon = true,
    this.onLeadingIconTap,
    this.onTrailingIconTap,
    this.controller,
    this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<InputFieldAtom> createState() => _InputFieldAtomState();
}

class _InputFieldAtomState extends State<InputFieldAtom> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    switch (widget.state) {
      case InputFieldState.active:
        borderColor = AppColors.states['ok']!;
        break;
      case InputFieldState.error:
        borderColor = AppColors.states['error']!;
        break;
      case InputFieldState.disabled:
        borderColor = AppColors.neutral150;
        break;
      case InputFieldState.defaultState:
      default:
        borderColor = AppColors.neutral200;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.textSmRegular.copyWith(
              color: widget.state == InputFieldState.disabled
                  ? AppColors.neutral300
                  : Colors.white,
            ),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          enabled: widget.state != InputFieldState.disabled,
          focusNode: _focusNode,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            hintText: widget.placeholder,
            hintStyle: AppTextStyles.textSmSemibold.copyWith(
              color: widget.state == InputFieldState.disabled
                  ? AppColors.neutral300
                  : AppColors.neutral200,
            ),
            prefixIcon: widget.showLeadingIcon && widget.leadingIcon != null
                ? IconButton(
                    icon: Icon(
                      widget.leadingIcon,
                      color: widget.state == InputFieldState.disabled
                          ? AppColors.neutral300
                          : borderColor,
                    ),
                    onPressed: widget.state == InputFieldState.disabled
                        ? null
                        : () {
                            if (_focusNode.hasFocus) {
                              _focusNode.requestFocus();
                            }
                            widget.onLeadingIconTap?.call();
                          },
                  )
                : null,
            suffixIcon: widget.showTrailingIcon && widget.trailingIcon != null
                ? IconButton(
                    icon: Icon(
                      widget.trailingIcon,
                      color: widget.state == InputFieldState.disabled
                          ? AppColors.neutral300
                          : Colors.white,
                    ),
                    onPressed: widget.state == InputFieldState.disabled
                        ? null
                        : () {
                            if (_focusNode.hasFocus) {
                              _focusNode.requestFocus();
                            }
                            widget.onTrailingIconTap?.call();
                          },
                  )
                : null,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor),
              borderRadius: BorderRadius.circular(4),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor),
              borderRadius: BorderRadius.circular(4),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderColor, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.neutral150),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          style: AppTextStyles.textSmRegular.copyWith(
            color: widget.state == InputFieldState.disabled
                ? AppColors.neutral300
                : Colors.white,
          ),
        ),
        if (widget.helperText != null && widget.showHelperText) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: AppTextStyles.textXsmRegular.copyWith(
              color: widget.state == InputFieldState.error
                  ? AppColors.states['error']
                  : AppColors.neutral300,
            ),
          ),
        ],
      ],
    );
  }
}
