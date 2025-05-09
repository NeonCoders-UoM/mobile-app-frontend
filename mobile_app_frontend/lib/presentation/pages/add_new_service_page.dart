import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/pages/add_service_documents_page.dart';

class AddNewServicePage extends StatelessWidget {
  const AddNewServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral500,
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 16.0),
                  CustomButton(
                    label: 'EDIT',
                    type: ButtonType.primary,
                    size: ButtonSize.small,
                    onTap: () async {
                      // Navigate to EditReminderPage and wait for the result
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddServiceDocumentsPage(),
                        ),
                      );

                      // If a result is returned, pass it back to the RemindersPage
                      if (result != null) {
                        Navigator.pop(context, result);
                      } else {
                        Navigator.pop(context);
                      }
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
