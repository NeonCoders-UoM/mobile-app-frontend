import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';

class DatePicker extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDateChanged;

  const DatePicker({
    super.key,
    this.initialDate,
    this.onDateChanged,
  });

  @override
  _DatePickerState createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  DateTime? selectedDate;
  final TextEditingController _dateController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      if (widget.onDateChanged != null) {
        widget.onDateChanged!(picked);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
    _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: 360,
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.neutral450,
        border: Border.all(color: AppColors.neutral200, width: 1.0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Appointment Date',
            style: AppTextStyles.displayMdRegular.copyWith(
              color: AppColors.neutral100,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Row(
              children: [
                Expanded(
                  child: InputFieldAtom(
                    state: InputFieldState.defaultState,
                    placeholder: 'Select date',
                    controller: _dateController,
                    trailingIcon: Icons.calendar_today,
                    showTrailingIcon: true,
                    onTrailingIconTap: () => _selectDate(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
