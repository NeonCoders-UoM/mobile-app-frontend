import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import '../../../core/models/fuel_usage.dart';
import '../atoms/button.dart';
import '../atoms/enums/button_type.dart';
import '../atoms/enums/button_size.dart';
import '../atoms/enums/input_field_state.dart';

class FuelInputForm extends StatefulWidget {
  final Function(FuelUsage) onSubmit;

  const FuelInputForm({required this.onSubmit, super.key});

  @override
  FuelInputFormState createState() => FuelInputFormState();
}

class FuelInputFormState extends State<FuelInputForm> {
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  InputFieldState _amountFieldState = InputFieldState.defaultState;

  void _submitForm() {
    final amount = double.tryParse(_amountController.text);
    if (amount != null && amount > 0) {
      widget.onSubmit(FuelUsage(date: _selectedDate, amount: amount));
      _amountController.clear();
      setState(() {
        _selectedDate = DateTime.now();
        _amountFieldState = InputFieldState.active;
      });
    } else {
      setState(() {
        _amountFieldState = InputFieldState.error;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid fuel amount')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary200,
              onPrimary: AppColors.neutral100,
              surface: AppColors.neutral450,
              onSurface: AppColors.neutral100,
              background: AppColors.neutral500,
              onBackground: AppColors.neutral100,
            ),
            dialogBackgroundColor: AppColors.neutral450,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary200,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: AppColors.neutral450,
              headerBackgroundColor: AppColors.primary200,
              headerForegroundColor: AppColors.neutral100,
              dayForegroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return AppColors.neutral100;
                }
                return AppColors.neutral200;
              }),
              dayBackgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return AppColors.primary200;
                }
                return Colors.transparent;
              }),
              todayBackgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return AppColors.primary200;
                }
                return AppColors.primary300.withOpacity(0.3);
              }),
              todayForegroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return AppColors.neutral100;
                }
                return AppColors.primary200;
              }),
              yearForegroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return AppColors.neutral100;
                }
                return AppColors.neutral200;
              }),
              yearBackgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return AppColors.primary200;
                }
                return Colors.transparent;
              }),
              dayOverlayColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.hovered)) {
                  return AppColors.primary300.withOpacity(0.1);
                }
                if (states.contains(MaterialState.pressed)) {
                  return AppColors.primary300.withOpacity(0.2);
                }
                return null;
              }),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        // Ensure the selected date has a proper time component
        // Set to current time to avoid midnight timezone issues
        final now = DateTime.now();
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          now.hour,
          now.minute,
          now.second,
        );
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.neutral500,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputFieldAtom(
              state: _amountFieldState,
              label: 'Fuel Amount (Liters)',
              placeholder: 'e.g., 50.5',
              controller: _amountController,
              keyboardType: TextInputType.number,
              helperText: _amountFieldState == InputFieldState.error
                  ? 'Enter a valid number'
                  : 'Enter the amount of fuel added',
              showHelperText: true,
              leadingIcon: Icons.local_gas_station,
              showLeadingIcon: true,
            ),
            const SizedBox(height: 16),
            Text(
              'Date',
              style: AppTextStyles.textSmRegular
                  .copyWith(color: AppColors.neutral100),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.neutral200),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: AppColors.neutral200, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('yyyy-MM-dd').format(_selectedDate),
                      style: AppTextStyles.textSmRegular
                          .copyWith(color: AppColors.neutral100),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                label: 'Add Fuel',
                type: ButtonType.primary,
                size: ButtonSize.medium,
                onTap: _submitForm,
                leadingIcon: Icons.add,
                showLeadingIcon: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
