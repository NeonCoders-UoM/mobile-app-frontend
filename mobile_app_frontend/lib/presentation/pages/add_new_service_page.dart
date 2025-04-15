import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';

class AddNewServicePage extends StatelessWidget {
  const AddNewServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.neutral500, // Dark background matching the image
      appBar: const CustomAppBar(
        title: 'Add New Service',
        showTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const InputFieldAtom(
              state: InputFieldState.defaultState,
              placeholder: 'Service Name',
            ),
            const SizedBox(height: 16.0),
            const InputFieldAtom(
              state: InputFieldState.defaultState,
              placeholder: 'Date',
            ),
            const SizedBox(height: 16.0),
            const InputFieldAtom(
              state: InputFieldState.defaultState,
              placeholder: 'Cost',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            const InputFieldAtom(
              state: InputFieldState.defaultState,
              placeholder: 'Service Center Name',
            ),
            const SizedBox(height: 16.0),
            const InputFieldAtom(
              state: InputFieldState.defaultState,
              placeholder: 'Description',
            ),
            const SizedBox(height: 32.0),
            Center(
              // Wrap the Row in a Center widget to center it
              child: Row(
                mainAxisSize:
                    MainAxisSize.min, // Use min to shrink-wrap the Row
                mainAxisAlignment: MainAxisAlignment
                    .center, // Center the buttons within the Row
                children: [
                  const SizedBox(width: 16.0), // Add spacing between buttons
                  CustomButton(
                    label: 'ADD NEW DOCUMENT',
                    type: ButtonType.primary,
                    size: ButtonSize.medium,
                    onTap: () {
                      // Handle document addition logic here
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
