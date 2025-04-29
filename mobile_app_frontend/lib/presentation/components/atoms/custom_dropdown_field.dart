import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';

class CustomDropdownField extends StatefulWidget {
  final List<String> items;
  final ValueChanged<String> onChanged;
  final String? label;
  final String? hintText;
  final bool allowAddNew;

  const CustomDropdownField({
    super.key,
    required this.items,
    required this.onChanged,
    this.label,
    this.hintText,
    this.allowAddNew = false,
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
        title: Text(
          "Add New",
          style: AppTextStyles.displaySmBold,
        ),
        content: TextField(
          controller: customController,
          style:
              AppTextStyles.textMdRegular.copyWith(color: AppColors.neutral100),
          decoration: InputDecoration(
            hintText: "Enter new item",
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
            child: Text(
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
            child: Text(
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
    final List<DropdownMenuItem<String>> dropdownItems = widget.items
        .map(
          (value) => DropdownMenuItem(
            value: value,
            child: Text(
              value,
              style: AppTextStyles.textMdRegular
                  .copyWith(color: AppColors.neutral100),
            ),
          ),
        )
        .toList();

    if (widget.allowAddNew) {
      dropdownItems.add(
        DropdownMenuItem(
          value: "Add New",
          child: Text(
            "+ Add New",
            style:
                AppTextStyles.textMdBold.copyWith(color: AppColors.neutral200),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.textSmRegular.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<String>(
          value: selectedValue,
          items: dropdownItems,
          onChanged: (String? newValue) {
            if (newValue == "Add New" && widget.allowAddNew) {
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
              borderSide: BorderSide(color: AppColors.neutral150),
            ),
            filled: true,
            fillColor: AppColors.neutral400,
          ),
          hint: Text(
            widget.hintText ?? "Select an item",
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.neutral200,
            ),
          ),
          dropdownColor: AppColors.neutral300,
          style: AppTextStyles.textMdRegular.copyWith(
            color: AppColors.neutral100,
          ),
        ),
      ],
    );
  }
}
