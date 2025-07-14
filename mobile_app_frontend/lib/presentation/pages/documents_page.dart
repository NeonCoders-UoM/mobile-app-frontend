import 'dart:convert';
import 'dart:html' as html;
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
  bool isLoading = true;

  final documentTypes = [
    {'name': 'Vehicle Registration Certificate', 'value': 0},
    {'name': 'Driver\'s License', 'value': 1},
    {'name': 'Insurance Certificate', 'value': 2},
    {'name': 'Emission Test Report', 'value': 3},
    {'name': 'Tax Report', 'value': 4},
    {'name': 'Warranty Document', 'value': 5},
  ];

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    final url =
        'http://localhost:5039/api/documents/listByVehicle/${widget.customerId}/${widget.vehicleId}';

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
        final blob = html.Blob([response.bodyBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
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
        'http://localhost:5039/api/documents/delete?documentId=$documentId';
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
        'http://localhost:5039/api/documents/download?fileUrl=${Uri.encodeComponent(fileUrl)}&mode=inline';
    final downloadUrl =
        'http://localhost:5039/api/documents/download?fileUrl=${Uri.encodeComponent(fileUrl)}&mode=attachment';

    final fileExtension = fileName.toLowerCase().split('.').last;
    final isImage = ['jpg', 'jpeg', 'png'].contains(fileExtension);
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

    if (isImage) {
      // Display image using Image.network
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Image.network(
              previewUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                    child: Text('Error loading image',
                        style: TextStyle(color: Colors.red)));
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                downloadFile(downloadUrl, fileName);
              },
              child: const Text('Download'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await deleteDocument(documentId, fileName, title);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } else {
      // Existing logic for non-image files (pdf, txt) using iframe
      final iframe = html.IFrameElement()
        ..src = previewUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';

      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(
        'iframeElement-$fileUrl',
        (int viewId) => iframe,
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: HtmlElementView(viewType: 'iframeElement-$fileUrl'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                downloadFile(downloadUrl, fileName);
              },
              child: const Text('Download'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await deleteDocument(documentId, fileName, title);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }
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
    return Scaffold(
      appBar: CustomAppBar(title: 'Documents', showTitle: true),
      backgroundColor: AppColors.neutral400,
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : documents.isEmpty
                    ? const Center(child: Text('No documents found.'))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            final doc = documents[index];
                            final title = getDocumentTitle(doc);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 40),
                                tileColor: AppColors.neutral450,
                                title: Text(title,
                                    style: AppTextStyles.textSmSemibold
                                        .copyWith(color: AppColors.neutral100)),
                                leading: SvgPicture.asset(
                                  'assets/icons/document_card_icon.svg',
                                  height: 24,
                                  width: 24,
                                  colorFilter: const ColorFilter.mode(
                                    AppColors.neutral100,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                onTap: () => previewDocument(doc.fileUrl, title,
                                    doc.fileName, doc.documentId),
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
    return [1, 2, 3, 4, 5].contains(documentType); // Updated to match backend
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isUploading = true);

    final url = 'http://localhost:5039/api/documents/upload';
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
          SnackBar(content: Text('Failed to upload document: $responseBody')),
        );
      }
    } catch (e) {
      print('Error uploading document ${widget.fileName}: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading document: $e')),
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Upload Document'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'File: ${widget.fileName}',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Document Type'),
                items: documentTypes
                    .map((type) => DropdownMenuItem(
                          value: type['value'] as int,
                          child: Text(type['name'] as String),
                        ))
                    .toList(),
                value: documentType,
                onChanged: (value) {
                  setState(() {
                    documentType = value;
                    if (!requiresExpiration(value!)) {
                      expirationDate = null;
                    }
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a document type' : null,
              ),
              const SizedBox(height: 16),
              if (documentType != null && requiresExpiration(documentType!))
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Expiration Date'),
                  readOnly: true,
                  controller: TextEditingController(
                    text: expirationDate != null
                        ? DateFormat('yyyy-MM-dd').format(expirationDate!)
                        : '',
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: expirationDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => expirationDate = picked);
                    }
                  },
                  validator: (value) => expirationDate == null
                      ? 'Expiration date is required'
                      : null,
                ),
              const SizedBox(height: 16),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Display Name (Optional)'),
                onChanged: (value) => displayName = value,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: isUploading ? null : submitForm,
          child: isUploading
              ? const CircularProgressIndicator()
              : const Text('Upload'),
        ),
      ],
    );
  }
}
