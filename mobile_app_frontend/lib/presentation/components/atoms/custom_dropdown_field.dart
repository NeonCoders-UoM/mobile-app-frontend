import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class CustomDropdownField extends StatefulWidget {
  final List<String> items;
  final ValueChanged<String> onChanged;

  const CustomDropdownField({
    super.key,
    required this.items,
    required this.onChanged,
  });

  @override
  _CustomDropdownFieldState createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  String? selectedValue;
  final TextEditingController customController = TextEditingController();

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.neutral500,
        title: const Text(
          "Add New Service Type",
          style: AppTextStyles.displaySmBold,
        ),
        content: TextField(
          controller: customController,
          style:
              AppTextStyles.textMdRegular.copyWith(color: AppColors.neutral100),
          decoration: InputDecoration(
            hintText: "Enter service type",
            hintStyle: AppTextStyles.textSmRegular
                .copyWith(color: AppColors.neutral200),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.neutral300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary200),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: AppTextStyles.textMdBold,
            ),
          ),
          TextButton(
            onPressed: () {
              if (customController.text.isNotEmpty) {
                setState(() {
                  selectedValue = customController.text;
                  widget.items.add(customController.text);
                  widget.onChanged(selectedValue!);
                });
              }
              Navigator.pop(context);
            },
            child: const Text(
              "Add",
              style: AppTextStyles.textMdBold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Service Type",
          style: AppTextStyles.textLgBold,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          items: widget.items.map((String value) {
            return DropdownMenuItem(
              value: value,
              child: Text(
                value,
                style: AppTextStyles.textMdRegular,
              ),
            );
          }).toList()
            ..add(
              DropdownMenuItem(
                value: "Add New",
                child: Text(
                  "+ Add New Service Type",
                  style: AppTextStyles.textMdBold
                      .copyWith(color: AppColors.primary200),
                ),
              ),
            ),
          onChanged: (String? newValue) {
            if (newValue == "Add New") {
              _showAddServiceDialog();
            } else {
              setState(() {
                selectedValue = newValue;
                widget.onChanged(selectedValue!);
              });
            }
          },
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.neutral300),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary200),
            ),
            filled: true,
            fillColor: AppColors.neutral500,
          ),
          dropdownColor: AppColors.neutral500,
          style:
              AppTextStyles.textMdRegular.copyWith(color: AppColors.neutral100),
        ),
      ],
    );
  }
}
