// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_html/flutter_html.dart';
import 'package:mobile_app_frontend/utils/platform/web_utils.dart';

class Document {
  final int documentId;
  final String fileName;
  final String fileUrl;
  final int documentType;
  final String? displayName;

  Document({
    required this.documentId,
    required this.fileName,
    required this.fileUrl,
    required this.documentType,
    required this.displayName,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      documentId: json['documentId'],
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
      documentType: json['documentType'],
      displayName: json['displayName'],
    );
  }
}

class DocumentsPage extends StatefulWidget {
  final int customerId;
  final int vehicleId;

  const DocumentsPage({
    Key? key,
    required this.customerId,
    required this.vehicleId,
  }) : super(key: key);

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  List<Document> documents = [];
  String searchQuery = '';
  bool isLoading = true;
  String? vehicleModel;
  String? chassisNumber;

  final documentTypes = [
    {'name': 'Vehicle Registration Certificate', 'value': 0},
    {'name': 'Driver\'s License', 'value': 1},
    {'name': 'Insurance Certificate', 'value': 2},
    {'name': 'Emission Test Report', 'value': 3},
    {'name': 'Tax Report', 'value': 4},
    {'name': 'Warranty Document', 'value': 5},
  ];

  // Controller for expiration date input
  final TextEditingController expirationDateController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchVehicleDetails(); // fetch model and chassis number
    fetchDocuments();
  }

  @override
  void dispose() {
    expirationDateController.dispose();
    super.dispose();
  }

  Future<void> fetchVehicleDetails() async {
    final url =
        'http://192.168.8.161:5039/api/vehicles/info/${widget.customerId}/${widget.vehicleId}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final vehicleInfo = VehicleInfo.fromJson(data);
        setState(() {
          vehicleModel = vehicleInfo.model;
          chassisNumber = vehicleInfo.chassisNumber;
        });
      } else {
        print('Failed to load vehicle data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching vehicle data: $e');
    }
  }

  Future<void> fetchDocuments() async {
    final url =
        'http://192.168.8.161:5039/api/documents/listByVehicle/${widget.customerId}/${widget.vehicleId}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          documents = data.map((json) => Document.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load documents: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading documents: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading documents: $e')),
      );
    }
  }

  Future<void> downloadFile(String downloadUrl, String fileName) async {
    try {
      final response = await http.get(Uri.parse(downloadUrl));
      if (response.statusCode == 200) {
        if (kIsWeb) {
          WebUtils.downloadFile(response.bodyBytes, fileName);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Download not supported on mobile yet')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to download file: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e')),
      );
    }
  }

  Future<void> deleteDocument(
      int documentId, String fileName, String title) async {
    final url =
        'http://192.168.8.161:5039/api/documents/delete?documentId=$documentId';
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          documents.removeWhere((doc) => doc.documentId == documentId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document "$title" deleted successfully')),
        );
      } else {
        final responseBody =
            response.body.isNotEmpty ? response.body : 'Unknown server error';
        print('Delete failed for document $documentId ($title): $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete "$title": $responseBody')),
        );
      }
    } catch (e) {
      print('Error deleting document $documentId ($title): $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting "$title": $e')),
      );
    }
  }

  Future<void> uploadDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'txt'],
    );

    if (result == null || result.files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
      return;
    }

    final file = result.files.single;
    final fileName = file.name;
    final fileBytes = file.bytes;

    if (fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to read file')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => UploadDocumentDialog(
        customerId: widget.customerId,
        vehicleId: widget.vehicleId,
        fileName: fileName,
        fileBytes: fileBytes,
        onUploadSuccess: fetchDocuments,
      ),
    );
  }

  void previewDocument(
      String fileUrl, String title, String fileName, int documentId) {
    final previewUrl =
        'http://192.168.8.161:5039/api/documents/download?fileUrl=${Uri.encodeComponent(fileUrl)}&mode=inline';
    final downloadUrl =
        'http://192.168.8.161:5039/api/documents/download?fileUrl=${Uri.encodeComponent(fileUrl)}&mode=attachment';

    final fileExtension = fileName.toLowerCase().split('.').last;
    final isSupportedType =
        ['pdf', 'jpg', 'jpeg', 'png', 'txt'].contains(fileExtension);

    if (!isSupportedType) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsupported File Type'),
          content: Text(
              'The file type (.$fileExtension) is not supported for preview.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                downloadFile(downloadUrl, fileName);
                Navigator.of(context).pop();
              },
              child: const Text('Download'),
            ),
          ],
        ),
      );
      return;
    }

    // Show full-screen dialog for supported file types
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullScreenDocumentPreview(
          previewUrl: previewUrl,
          downloadUrl: downloadUrl,
          fileName: fileName,
          title: title,
          documentId: documentId,
          onDownload: () => downloadFile(downloadUrl, fileName),
          onDelete: () async {
            await deleteDocument(documentId, fileName, title);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  String getDocumentTitle(Document doc) {
    if (doc.documentType == 5) {
      // WarrantyDocument
      return (doc.displayName != null && doc.displayName!.isNotEmpty)
          ? doc.displayName!
          : doc.fileName;
    } else {
      final type = documentTypes.firstWhere(
        (type) => type['value'] == doc.documentType,
        orElse: () => {'name': doc.fileName},
      );
      return type['name'] as String;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDocuments = documents.where((doc) {
      final title = getDocumentTitle(doc).toLowerCase();
      return title.contains(searchQuery);
    }).toList();

    // Update expiration date controller text on build
    // (only if dialog is open; this is safe here because controller is in state)
    // Note: This is just to keep the expiration date text synced when needed.

    return Scaffold(
      appBar: CustomAppBar(title: 'Documents', showTitle: true),
      backgroundColor: AppColors.neutral400,
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            if (vehicleModel != null && chassisNumber != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Model: $vehicleModel',
                      style: AppTextStyles.displaySmSemibold
                          .copyWith(color: AppColors.neutral100),
                    ),
                    Text('Chassis Number: $chassisNumber',
                        style: AppTextStyles.textMdRegular
                            .copyWith(color: AppColors.neutral100)),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search documents...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: AppColors.neutral450,
                hintStyle: TextStyle(color: AppColors.neutral200),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: AppColors.neutral100),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 16),
            // Show loading, empty message, or list
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: filteredDocuments.isEmpty
                        ? const Center(
                            child: Text(
                              'No documents found matching your search.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredDocuments.length,
                            itemBuilder: (context, index) {
                              final doc = filteredDocuments[index];
                              final title = getDocumentTitle(doc);

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 40),
                                  tileColor: AppColors.neutral450,
                                  title: Text(
                                    title,
                                    style: AppTextStyles.textSmSemibold
                                        .copyWith(color: AppColors.neutral100),
                                  ),
                                  leading: SvgPicture.asset(
                                    'assets/icons/document_card_icon.svg',
                                    height: 24,
                                    width: 24,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.neutral100,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  onTap: () => previewDocument(
                                    doc.fileUrl,
                                    title,
                                    doc.fileName,
                                    doc.documentId,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(40, 40, 40, 80),
        child: CustomButton(
          label: 'Add New Document',
          type: ButtonType.primary,
          size: ButtonSize.medium,
          onTap: uploadDocument,
        ),
      ),
    );
  }
}

class FullScreenDocumentPreview extends StatelessWidget {
  final String previewUrl;
  final String downloadUrl;
  final String fileName;
  final String title;
  final int documentId;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const FullScreenDocumentPreview({
    Key? key,
    required this.previewUrl,
    required this.downloadUrl,
    required this.fileName,
    required this.title,
    required this.documentId,
    required this.onDownload,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fileExtension = fileName.toLowerCase().split('.').last;
    final isImage = ['jpg', 'jpeg', 'png'].contains(fileExtension);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(icon: Icon(Icons.download), onPressed: onDownload),
          IconButton(icon: Icon(Icons.delete), onPressed: onDelete),
        ],
      ),
      body: isImage
          ? Image.network(previewUrl)
          : Html(
              data:
                  '<iframe src="$previewUrl" width="100%" height="600px" style="border:none;"></iframe>',
            ),
    );
  }
}

class UploadDocumentDialog extends StatefulWidget {
  final int customerId;
  final int vehicleId;
  final String fileName;
  final Uint8List fileBytes;
  final VoidCallback onUploadSuccess;

  const UploadDocumentDialog({
    Key? key,
    required this.customerId,
    required this.vehicleId,
    required this.fileName,
    required this.fileBytes,
    required this.onUploadSuccess,
  }) : super(key: key);

  @override
  State<UploadDocumentDialog> createState() => _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends State<UploadDocumentDialog> {
  final _formKey = GlobalKey<FormState>();
  int? documentType;
  DateTime? expirationDate;
  String? displayName;
  bool isUploading = false;

  final documentTypes = [
    {'name': 'Vehicle Registration Certificate', 'value': 0},
    {'name': 'Driver\'s License', 'value': 1},
    {'name': 'Insurance Certificate', 'value': 2},
    {'name': 'Emission Test Report', 'value': 3},
    {'name': 'Tax Report', 'value': 4},
    {'name': 'Warranty Document', 'value': 5},
  ];

  bool requiresExpiration(int documentType) {
    return [1, 2, 3, 4, 5].contains(documentType);
  }

  // Controller for expiration date input
  final TextEditingController expirationDateController =
      TextEditingController();

  @override
  void dispose() {
    expirationDateController.dispose();
    super.dispose();
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isUploading = true);

    final url = 'http://192.168.8.161:5039/api/documents/upload';
    final request = http.MultipartRequest('POST', Uri.parse(url));

    request.fields['customerId'] = widget.customerId.toString();
    request.fields['documentType'] = documentType.toString();
    request.fields['vehicleId'] = widget.vehicleId.toString();
    if (expirationDate != null) {
      request.fields['expirationDate'] = expirationDate!.toIso8601String();
    }
    if (displayName != null && displayName!.isNotEmpty) {
      request.fields['displayName'] = displayName!;
    }

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      widget.fileBytes,
      filename: widget.fileName,
    ));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        widget.onUploadSuccess();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Document "${widget.fileName}" uploaded successfully')),
        );
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Upload failed for ${widget.fileName}: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to upload document: ${response.statusCode} $responseBody')),
        );
      }
    } catch (e) {
      print('Error uploading document ${widget.fileName}: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading document: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final requiresExp =
        documentType != null && requiresExpiration(documentType!);

    if (requiresExp && expirationDate != null) {
      expirationDateController.text =
          DateFormat('yyyy-MM-dd').format(expirationDate!);
    } else if (!requiresExp) {
      expirationDateController.text = '';
      expirationDate = null;
    }

    return AlertDialog(
      backgroundColor: AppColors.neutral400,
      title: const Text('Upload Document',
          style: TextStyle(color: AppColors.neutral150)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                    labelText: 'Document Type',
                    labelStyle: TextStyle(color: AppColors.neutral200)),
                dropdownColor: AppColors.neutral450,
                items: documentTypes
                    .map((type) => DropdownMenuItem(
                          value: type['value'] as int,
                          child: Text(type['name'] as String,
                              style: TextStyle(color: AppColors.neutral200)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    documentType = value;
                    // Clear expiration date when document type changes
                    expirationDate = null;
                    expirationDateController.text = '';
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a document type' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Display Name (Optional)',
                ),
                onChanged: (value) => displayName = value,
              ),
              if (requiresExp) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: expirationDateController,
                  decoration: const InputDecoration(
                    labelText: 'Expiration Date',
                    hintText: 'Select expiration date',
                    labelStyle: const TextStyle(color: AppColors.neutral200),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: expirationDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        expirationDate = selectedDate;
                        expirationDateController.text =
                            DateFormat('yyyy-MM-dd').format(selectedDate);
                      });
                    }
                  },
                  validator: (value) {
                    if (requiresExp && (value == null || value.isEmpty)) {
                      return 'Expiration date is required';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 16),
              isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: submitForm,
                      child: const Text('Upload'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class VehicleInfo {
  final String model;
  final String chassisNumber;

  VehicleInfo({required this.model, required this.chassisNumber});

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      model: json['model'] ?? '',
      chassisNumber: json['chassisNumber'] ?? '',
    );
  }
}
