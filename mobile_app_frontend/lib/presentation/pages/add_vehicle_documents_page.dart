import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/text_field.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/input_field_state.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/add_photo_button.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/added_document_card.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/car_component.dart'; // Import the CarComponent

class AddVehicleDocumentsPage extends StatefulWidget {
  const AddVehicleDocumentsPage({Key? key}) : super(key: key);

  @override
  _AddVehicleDocumentsPageState createState() =>
      _AddVehicleDocumentsPageState();
}

class _AddVehicleDocumentsPageState extends State<AddVehicleDocumentsPage> {
  // Mock list of documents (you can replace this with actual file picker logic)
  final List<Map<String, String>> _documents = [];

  void _addDocument() {
    // Mock adding a document (replace with actual file picker logic)
    setState(() {
      _documents.add({
        'name': 'Insurance Documents',
        'size': '30 MB / 77.4 MB',
      });
    });
  }

  void _removeDocument(int index) {
    setState(() {
      _documents.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral500,
      appBar: const CustomAppBar(
        title: 'Documents',
        showTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use CarComponent instead of manual implementation
              Center(
                child: CarComponent(),
              ),
              const SizedBox(height: 16.0),
              // Expiry Date Input
              InputFieldAtom(
                state: InputFieldState.defaultState,
                placeholder: '25/02/2024',
                label: 'Expire Date',
                trailingIcon: Icons.calendar_today_outlined,
                showTrailingIcon: true,
                onTrailingIconTap: () {
                  // Implement date picker logic here
                },
              ),
              const SizedBox(height: 16.0),
              // Attach Photo Button
              AddPhotoButton(
                onTap: _addDocument, // Mock adding a document
              ),
              const SizedBox(height: 16.0),
              // List of Added Documents
              if (_documents.isNotEmpty) ...[
                ..._documents.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, String> doc = entry.value;
                  return AddedDocumentCard(
                    documentName: doc['name']!,
                    documentSize: doc['size']!,
                    onRemove: () => _removeDocument(index),
                  );
                }).toList(),
                const SizedBox(height: 16.0),
              ],
              // Done Button
              Center(
                child: CustomButton(
                  label: 'DONE',
                  type: ButtonType.primary,
                  size: ButtonSize.medium,
                  onTap: () {
                    Navigator.pop(context); // Return to previous page
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
