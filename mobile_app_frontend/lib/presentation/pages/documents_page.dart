import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app_frontend/core/config/api_config.dart';

class DocumentActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;

  const DocumentActionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.backgroundColor = AppColors.neutral450,
    this.textColor = AppColors.neutral100,
    this.iconColor = AppColors.neutral100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.textSmMedium.copyWith(
              color: textColor,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class Document {
  final int documentId;
  final String fileName;
  final String fileUrl;
  final int documentType;
  final String? displayName;
  final DateTime? expirationDate;

  Document({
    required this.documentId,
    required this.fileName,
    required this.fileUrl,
    required this.documentType,
    required this.displayName,
    this.expirationDate,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      documentId: json['documentId'],
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
      documentType: json['documentType'],
      displayName: json['displayName'],
      expirationDate: json['expirationDate'] != null 
          ? DateTime.parse(json['expirationDate']) 
          : null,
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
  bool _isDownloading = false;
  final TextEditingController expirationDateController = TextEditingController();
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

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
    fetchVehicleDetails();
    fetchDocuments();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameraStatus = await Permission.camera.request();
      print('Camera permission status: $cameraStatus');
      if (cameraStatus.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Camera permission is permanently denied. Please enable it in settings.',
              textAlign: TextAlign.center,
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
        return;
      } else if (cameraStatus != PermissionStatus.granted) {
        print('Camera permission not granted');
        return;
      }

      print('Fetching available cameras...');
      _cameras = await availableCameras();
      print('Available cameras: ${_cameras?.length ?? 0}');
      if (_cameras != null && _cameras!.isNotEmpty) {
        print('Initializing camera controller...');
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        print('Camera initialized: ${_cameraController!.value.isInitialized}');
        if (mounted) {
          setState(() {});
        }
      } else {
        print('No cameras available');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No cameras available on this device.', textAlign: TextAlign.center)),
        );
      }
    } catch (e) {
      print('Error initializing camera: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing camera: $e', textAlign: TextAlign.center)),
      );
    }
  }

  @override
  void dispose() {
    expirationDateController.dispose();
    _cameraController?.dispose();
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
        SnackBar(content: Text('Error loading documents: $e', textAlign: TextAlign.center)),
      );
    }
  }

  Future<Directory?> getDownloadPath() async {
    Directory? directory = await getDownloadsDirectory();
    print('Downloads directory: $directory');
    return directory;
  }

  Future<void> downloadFile(String downloadUrl, String fileName) async {
    if (_isDownloading) return;
    _isDownloading = true;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        print('Android SDK: ${androidInfo.version.sdkInt}');

        var status;
        if (androidInfo.version.sdkInt >= 33) {
          status = await Permission.photos.request();
          print('Photo permission status: $status');
        } else {
          status = await Permission.storage.request();
          print('Storage permission status: $status');
        }

        if (status != PermissionStatus.granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                  'Permission denied. Please enable it in settings to download files.',
                  textAlign: TextAlign.center,
              ),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: () => openAppSettings(),
              ),
            ),
          );
          return;
        }
      }

      print('Downloading from: $downloadUrl');
      final response = await http.get(Uri.parse(downloadUrl));
      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      if (response.statusCode == 200) {
        final directory = await getDownloadPath();
        print('Downloads directory: $directory');
        if (directory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to access downloads directory', textAlign: TextAlign.center)),
          );
          return;
        }

        final filePath = '${directory.path}/$fileName';
        print('Saving file to: $filePath');
        final file = File(filePath);
        print('File exists before writing: ${await file.exists()}');
        await file.writeAsBytes(response.bodyBytes);
        print('File exists after writing: ${await file.exists()}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded to $filePath', textAlign: TextAlign.center)),
        );
      } else {
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to download file: ${response.statusCode}', textAlign: TextAlign.center)),
        );
      }
    } catch (e) {
      print('Error downloading file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e', textAlign: TextAlign.center)),
      );
    } finally {
      _isDownloading = false;
    }
  }

  Future<void> deleteDocument(
      int documentId, String fileName, String title) async {
    // Show confirmation dialog
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.neutral400,
          title: const Text(
            'Delete Document',
            style: TextStyle(color: AppColors.neutral150),
          ),
          content: Text(
            'Are you sure you want to delete "$title"? This action cannot be undone.',
            style: const TextStyle(color: AppColors.neutral100),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.neutral200),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    // If user cancels, return early
    if (confirmDelete != true) {
      return;
    }

    final url =
        'http://192.168.8.161:5039/api/documents/delete?documentId=$documentId';
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          documents.removeWhere((doc) => doc.documentId == documentId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document "$title" deleted successfully', textAlign: TextAlign.center)),
        );
      } else {
        final responseBody =
            response.body.isNotEmpty ? response.body : 'Unknown server error';
        print('Delete failed for document $documentId ($title): $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete "$title": $responseBody', textAlign: TextAlign.center)),
        );
      }
    } catch (e) {
      print('Error deleting document $documentId ($title): $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting "$title": $e', textAlign: TextAlign.center)),
      );
    }
  }

  Future<void> uploadDocument({bool fromCamera = false}) async {
    if (fromCamera) {
      await _uploadFromCamera();
    } else {
      await _uploadFromFilePicker();
    }
  }

  Future<void> _uploadFromCamera() async {
    final cameraStatus = await Permission.camera.request();
    print('Camera permission status: $cameraStatus');

    if (cameraStatus.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Camera permission is permanently denied. Please enable it in settings.',
            textAlign: TextAlign.center,
          ),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
      return;
    } else if (cameraStatus != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission denied', textAlign: TextAlign.center)),
      );
      return;
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera not available', textAlign: TextAlign.center)),
      );
      return;
    }

    final XFile? image = await Navigator.of(context).push<XFile>(
      MaterialPageRoute(
        builder: (context) => CameraPreviewScreen(
          controller: _cameraController!,
          onPictureTaken: (XFile image) {
            Navigator.of(context).pop(image);
          },
        ),
      ),
    );

    if (image != null) {
      // Show preview dialog to verify the captured image
      final bool? shouldUpload = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: AppColors.neutral400,
            title: const Text(
              'Review Captured Document',
              style: TextStyle(color: AppColors.neutral150),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Please review your captured document:',
                  style: TextStyle(color: AppColors.neutral100),
                ),
                const SizedBox(height: 16),
                Container(
                  constraints: const BoxConstraints(
                    maxHeight: 400,
                    maxWidth: double.infinity,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.neutral300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(image.path),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Is this image clear and suitable for upload?',
                  style: TextStyle(color: AppColors.neutral100),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Retake',
                  style: TextStyle(color: AppColors.neutral200),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Upload',
                  style: TextStyle(color: AppColors.primary200),
                ),
              ),
            ],
          );
        },
      );

      // If user wants to retake, return early
      if (shouldUpload != true) {
        return;
      }

      final fileBytes = await File(image.path).readAsBytes();
      final fileName = 'scanned_document_${DateTime.now().millisecondsSinceEpoch}.jpg';

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
  }

  Future<void> _uploadFromFilePicker() async {
    if (Platform.isAndroid) {
      var photoStatus = await Permission.photos.request();
      print('Photo permission status: $photoStatus');
      if (photoStatus != PermissionStatus.granted) {
        var storageStatus = await Permission.storage.request();
        print('Storage permission status: $storageStatus');
        if (storageStatus != PermissionStatus.granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage or photo permission denied', textAlign: TextAlign.center)),
          );
          return;
        }
      }
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'txt'],
    );

    if (result == null || result.files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected', textAlign: TextAlign.center)),
      );
      return;
    }

    final file = result.files.single;
    print('File name: ${file.name}');
    print('File path: ${file.path}');
    print('File bytes: ${file.bytes != null ? "Available" : "Null"}');
    print('File size: ${file.size} bytes');

    if (file.size > 10 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File size exceeds 10MB limit', textAlign: TextAlign.center)),
      );
      return;
    }

    Uint8List fileBytes;
    if (file.path != null) {
      try {
        final fileFromPath = File(file.path!);
        if (await fileFromPath.exists()) {
          fileBytes = await fileFromPath.readAsBytes();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selected file does not exist', textAlign: TextAlign.center)),
          );
          return;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to read file: $e', textAlign: TextAlign.center)),
        );
        return;
      }
    } else if (file.bytes != null) {
      fileBytes = file.bytes!;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to read file', textAlign: TextAlign.center)),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => UploadDocumentDialog(
        customerId: widget.customerId,
        vehicleId: widget.vehicleId,
        fileName: file.name,
        fileBytes: fileBytes,
        onUploadSuccess: fetchDocuments,
      ),
    );
  }

  void previewDocument(
      String fileUrl, String title, String fileName, int documentId, Document document) {
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

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => FullScreenDocumentPreview(
          previewUrl: previewUrl,
          downloadUrl: downloadUrl,
          fileName: fileName,
          title: title,
          documentId: documentId,
          documentType: document.documentType,
          displayName: document.displayName,
          expirationDate: document.expirationDate,
          onDownload: () => downloadFile(downloadUrl, fileName),
          onDelete: () async {
            await deleteDocument(documentId, fileName, title);
            Navigator.of(context).pop();
          },
          onUpdate: (displayName, expirationDate) async {
            try {
              print('Updating document with ID: $documentId');
              print('Display name: $displayName');
              print('Expiration date: $expirationDate');
              
              final url = '${ApiConfig.baseUrl}/documents/edit/${documentId}';
              final requestBody = {
                'documentType': document.documentType,
                'displayName': displayName,
                'expirationDate': expirationDate?.toIso8601String(),
                'vehicleId': widget.vehicleId,
              };
              
              print('Request body: ${jsonEncode(requestBody)}');
              
              // Try with different content type and additional headers
              final response = await http.put(
                Uri.parse(url),
                headers: {
                  'Content-Type': 'application/json; charset=UTF-8',
                  'Accept': 'application/json',
                },
                body: jsonEncode(requestBody),
              );

              print('Response status code: ${response.statusCode}');
              print('Response body: ${response.body}');
              
              if (response.statusCode == 200 || response.statusCode == 204) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Document updated successfully',
                      textAlign: TextAlign.center,
                    ),
                    backgroundColor: AppColors.neutral450,
                  ),
                );
                // Refresh the documents list
                                    fetchDocuments();
              } else {
                final responseBody = response.body.isNotEmpty ? response.body : 'Unknown server error';
                print('Update failed with status: ${response.statusCode}, body: $responseBody');
                
                // Try POST method as fallback if PUT fails
                if (response.statusCode == 405) { // Method Not Allowed
                  print('PUT method not allowed, trying POST...');
                  final postResponse = await http.post(
                    Uri.parse(url),
                    headers: {
                      'Content-Type': 'application/json; charset=UTF-8',
                      'Accept': 'application/json',
                    },
                    body: jsonEncode(requestBody),
                  );
                  
                  print('POST response status: ${postResponse.statusCode}');
                  print('POST response body: ${postResponse.body}');
                  
                  if (postResponse.statusCode == 200 || postResponse.statusCode == 204) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Document updated successfully',
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    fetchDocuments();
                    return;
                  } else {
                    final postResponseBody = postResponse.body.isNotEmpty ? postResponse.body : 'Unknown server error';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to update document: $postResponseBody',
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else if (response.statusCode == 404) {
                  // Try using the upload endpoint with update flag
                  print('Update endpoint not found, trying upload endpoint with update flag...');
                  final uploadUrl = '${ApiConfig.baseUrl}/documents/upload';
                  final updateRequestBody = {
                    ...requestBody,
                    'isUpdate': true,
                  };
                  
                  final uploadResponse = await http.post(
                    Uri.parse(uploadUrl),
                    headers: {
                      'Content-Type': 'application/json; charset=UTF-8',
                      'Accept': 'application/json',
                    },
                    body: jsonEncode(updateRequestBody),
                  );
                  
                  print('Upload endpoint response status: ${uploadResponse.statusCode}');
                  print('Upload endpoint response body: ${uploadResponse.body}');
                  
                  if (uploadResponse.statusCode == 200 || uploadResponse.statusCode == 204) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Document updated successfully',
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: AppColors.neutral450,
                      ),
                    );
                    fetchDocuments();
                    return;
                  } else {
                    final uploadResponseBody = uploadResponse.body.isNotEmpty ? uploadResponse.body : 'Unknown server error';
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Failed to update document: $uploadResponseBody',
                          textAlign: TextAlign.center,
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to update document: $responseBody',
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Error updating document: $e',
                    textAlign: TextAlign.center,
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  String getDocumentTitle(Document doc) {
    if (doc.documentType == 5) {
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
      return searchQuery.isEmpty || title.contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: CustomAppBar(title: 'Documents', showTitle: true),
      backgroundColor: AppColors.neutral400,
      body: Column(
        children: [
          // Fixed header section
          Container(
            padding: const EdgeInsets.all(20.0),
            color: AppColors.neutral400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (vehicleModel != null && chassisNumber != null)
                  Column(
                    children: [
                      Text(
                        'Model: $vehicleModel',
                        style: AppTextStyles.displaySmSemibold
                            .copyWith(color: AppColors.neutral100),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Chassis Number: $chassisNumber',
                        style: AppTextStyles.textMdRegular
                            .copyWith(color: AppColors.neutral100),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search documents...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.neutral450,
                    hintStyle: const TextStyle(color: AppColors.neutral200),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: AppColors.neutral100),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Scrollable document list
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(40.0, 0, 40.0, 80.0),
                  sliver: isLoading
                      ? const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : filteredDocuments.isEmpty
                          ? const SliverToBoxAdapter(
                              child: Center(
                                child: Text(
                                  'No documents found matching your search.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final doc = filteredDocuments[index];
                                  final title = getDocumentTitle(doc);

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                          vertical: 4, horizontal: 24),
                                      tileColor: AppColors.neutral450,
                                      title: Text(
                                        title,
                                        style: AppTextStyles.textSmSemibold
                                            .copyWith(
                                                color: AppColors.neutral100),
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
                                        doc,
                                      ),
                                    ),
                                  );
                                },
                                childCount: filteredDocuments.length,
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
          decoration: BoxDecoration(
            color: AppColors.neutral400,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DocumentActionButton(
                label: 'Smart Scan',
                icon: Icons.document_scanner_outlined,
                onTap: (_cameraController != null &&
                        _cameraController!.value.isInitialized)
                    ? () => uploadDocument(fromCamera: true)
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Camera not available. Please check permissions or device capabilities.', textAlign: TextAlign.center),
                          ),
                        );
                      },
                backgroundColor: AppColors.neutral450,
                textColor: AppColors.neutral100,
                iconColor: AppColors.neutral100,
              ),
              DocumentActionButton(
                label: 'Import Files',
                icon: Icons.folder_open,
                onTap: () => uploadDocument(fromCamera: false),
                backgroundColor: AppColors.neutral450,
                textColor: AppColors.neutral100,
                iconColor: AppColors.neutral100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CameraPreviewScreen extends StatefulWidget {
  final CameraController controller;
  final Function(XFile) onPictureTaken;

  const CameraPreviewScreen({
    Key? key,
    required this.controller,
    required this.onPictureTaken,
  }) : super(key: key);

  @override
  _CameraPreviewScreenState createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Document'),
        backgroundColor: AppColors.neutral450,
      ),
      body: widget.controller.value.isInitialized
          ? Stack(
              children: [
                CameraPreview(widget.controller),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FloatingActionButton(
                      onPressed: () async {
                        try {
                          final image = await widget.controller.takePicture();
                          widget.onPictureTaken(image);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error capturing image: $e')),
                          );
                        }
                      },
                      child: const Icon(Icons.camera),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class FullScreenDocumentPreview extends StatefulWidget {
  final String previewUrl;
  final String downloadUrl;
  final String fileName;
  final String title;
  final int documentId;
  final int documentType;
  final String? displayName;
  final DateTime? expirationDate;
  final VoidCallback onDownload;
  final VoidCallback onDelete;
  final Function(String? displayName, DateTime? expirationDate) onUpdate;

  const FullScreenDocumentPreview({
    Key? key,
    required this.previewUrl,
    required this.downloadUrl,
    required this.fileName,
    required this.title,
    required this.documentId,
    required this.documentType,
    this.displayName,
    this.expirationDate,
    required this.onDownload,
    required this.onDelete,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _FullScreenDocumentPreviewState createState() =>
      _FullScreenDocumentPreviewState();
}

class _FullScreenDocumentPreviewState extends State<FullScreenDocumentPreview> {
  String? _localFilePath;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    final fileExtension = widget.fileName.toLowerCase().split('.').last;
    final isPdf = fileExtension == 'pdf';

    if (!isPdf) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      print('Fetching PDF from: ${widget.previewUrl}');
      final response = await http.get(Uri.parse(widget.previewUrl));
      print('Response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/${widget.fileName}';
        print('Saving PDF to: $filePath');
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        print('File saved: ${await file.exists()}');
        setState(() {
          _localFilePath = filePath;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load PDF: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading PDF: $e');
      setState(() {
        _error = 'Error loading PDF: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _shareFile() async {
    try {
      final fileExtension = widget.fileName.toLowerCase().split('.').last;
      final isSupportedType =
          ['pdf', 'jpg', 'jpeg', 'png', 'txt'].contains(fileExtension);

      if (!isSupportedType) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('File type (.$fileExtension) is not supported for sharing')),
        );
        return;
      }

      String filePath;
      if (_localFilePath != null && await File(_localFilePath!).exists()) {
        filePath = _localFilePath!;
      } else {
        final response = await http.get(Uri.parse(widget.previewUrl));
        if (response.statusCode == 200) {
          final tempDir = await getTemporaryDirectory();
          filePath = '${tempDir.path}/${widget.fileName}';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Failed to download file for sharing: ${response.statusCode}')),
          );
          return;
        }
      }

      final file = XFile(filePath, mimeType: _getMimeType(fileExtension));
      await Share.shareXFiles(
        [file],
        text: 'Sharing document: ${widget.title}',
        subject: 'Document: ${widget.title}',
      );
    } catch (e) {
      print('Error sharing file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing file: $e')),
      );
    }
  }

  void _showEditDialog() {
    String? newDisplayName = widget.displayName;
    DateTime? newExpirationDate = widget.expirationDate;
    final TextEditingController displayNameController = TextEditingController(text: widget.displayName ?? '');
    final TextEditingController expirationDateController = TextEditingController();
    
    if (newExpirationDate != null) {
      expirationDateController.text = DateFormat('yyyy-MM-dd').format(newExpirationDate);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.neutral400,
          title: const Text(
            'Edit Document',
            style: TextStyle(color: AppColors.neutral150),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display Name field (only for Warranty Document)
              if (widget.documentType == 5) ...[
                TextFormField(
                  controller: displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    labelStyle: TextStyle(color: AppColors.neutral200),
                  ),
                  style: const TextStyle(color: AppColors.neutral200),
                  onChanged: (value) => newDisplayName = value.isEmpty ? null : value,
                ),
                const SizedBox(height: 16),
              ],
              // Expiration Date field (for documents that require it)
              if ([1, 2, 3, 4, 5].contains(widget.documentType)) ...[
                TextFormField(
                  controller: expirationDateController,
                  decoration: const InputDecoration(
                    labelText: 'Expiration Date',
                    hintText: 'Select expiration date',
                    labelStyle: TextStyle(color: AppColors.neutral200),
                  ),
                  style: const TextStyle(color: AppColors.neutral200),
                  readOnly: true,
                  onTap: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: newExpirationDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppColors.primary200,
                              onPrimary: Colors.white,
                              surface: AppColors.neutral450,
                              onSurface: AppColors.neutral100,
                              onSecondary: AppColors.neutral100,
                              secondary: AppColors.neutral300,
                            ),
                            dialogBackgroundColor: AppColors.neutral400,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (selectedDate != null) {
                      if (selectedDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Expired documents can not add', textAlign: TextAlign.center),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      setState(() {
                        newExpirationDate = selectedDate;
                        expirationDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
                      });
                    }
                  },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.neutral200),
              ),
            ),
            TextButton(
              onPressed: () {
                // Validate that expiration date is provided for documents that require it
                if ([1, 2, 3, 4, 5].contains(widget.documentType) && newExpirationDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Expiration date is required for this document type',
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                widget.onUpdate(newDisplayName, newExpirationDate);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Save',
                style: TextStyle(color: AppColors.primary200),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getMimeType(String extension) {
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileExtension = widget.fileName.toLowerCase().split('.').last;
    final isImage = ['jpg', 'jpeg', 'png'].contains(fileExtension);
    final isPdf = fileExtension == 'pdf';

    return Scaffold(
      backgroundColor: AppColors.neutral400,
      appBar: AppBar(
        backgroundColor: AppColors.neutral450,
        title: Text(
          widget.title,
          style: AppTextStyles.textSmSemibold.copyWith(color: AppColors.neutral100),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.neutral100),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Show edit icon for documents that have expiration dates (types 1,2,3,4,5) or warranty documents with display names
          if ([1, 2, 3, 4, 5].contains(widget.documentType))
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.neutral100),
              onPressed: _showEditDialog,
            ),
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.neutral100),
            onPressed: _shareFile,
          ),
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.neutral100),
            onPressed: widget.onDownload,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.neutral100),
            onPressed: widget.onDelete,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                )
              : isImage
                  ? Image.network(
                      widget.previewUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Text(
                            'Error loading image',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        );
                      },
                    )
                  : isPdf && _localFilePath != null
                      ? PDFView(
                          filePath: _localFilePath!,
                          onError: (error) {
                            setState(() {
                              _error = 'Error loading PDF: $error';
                            });
                          },
                          onPageError: (page, error) {
                            setState(() {
                              _error = 'Error on page $page: $error';
                            });
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Preview not available for ${fileExtension.toUpperCase()} files on mobile.',
                                style: const TextStyle(
                                  color: AppColors.neutral100,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: widget.onDownload,
                                child: const Text('Download File'),
                              ),
                            ],
                          ),
                        ),
    );
  }

  @override
  void dispose() {
    if (_localFilePath != null) {
      File(_localFilePath!).delete().catchError((e) {
        print('Error deleting temporary file: $e');
      });
    }
    super.dispose();
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

  final TextEditingController expirationDateController = TextEditingController();

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
                  Text('Document "${widget.fileName}" uploaded successfully', textAlign: TextAlign.center)),
        );
      } else {
        final responseBody = await response.stream.bytesToString();
        print('Upload failed for ${widget.fileName}: $responseBody');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to upload document:  {response.statusCode} $responseBody', textAlign: TextAlign.center)),
        );
      }
    } catch (e) {
      print('Error uploading document ${widget.fileName}: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading document: $e', textAlign: TextAlign.center)),
      );
    } finally {
      if (mounted) {
        setState(() => isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final requiresExp = documentType != null && requiresExpiration(documentType!);

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
                              style: const TextStyle(color: AppColors.neutral200)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    documentType = value;
                    expirationDate = null;
                    expirationDateController.text = '';
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a document type' : null,
              ),
                             if (documentType == 5) ...[
                 const SizedBox(height: 16),
                 TextFormField(
                   decoration: const InputDecoration(
                     labelText: 'Display Name (Optional)',
                     labelStyle: TextStyle(color: AppColors.neutral200),
                   ),
                   style: const TextStyle(color: AppColors.neutral200),
                   onChanged: (value) => displayName = value,
                 ),
               ],
              if (requiresExp) ...[
                const SizedBox(height: 16),
                                 TextFormField(
                   controller: expirationDateController,
                   decoration: const InputDecoration(
                     labelText: 'Expiration Date',
                     hintText: 'Select expiration date',
                     labelStyle: TextStyle(color: AppColors.neutral200),
                   ),
                   style: const TextStyle(color: AppColors.neutral200),
                   readOnly: true,
                                                        onTap: () async {
                     final selectedDate = await showDatePicker(
                       context: context,
                       initialDate: expirationDate ?? DateTime.now(),
                       firstDate: DateTime.now(),
                       lastDate: DateTime(2100),
                       builder: (context, child) {
                         return Theme(
                           data: Theme.of(context).copyWith(
                             colorScheme: const ColorScheme.dark(
                               primary: AppColors.primary200,
                               onPrimary: Colors.white,
                               surface: AppColors.neutral450,
                               onSurface: AppColors.neutral100,
                               onSecondary: AppColors.neutral100,
                               secondary: AppColors.neutral300,
                             ),
                             dialogBackgroundColor: AppColors.neutral400,
                           ),
                           child: child!,
                         );
                       },
                     );
                     if (selectedDate != null) {
                       // Check if selected date is in the past
                       if (selectedDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
                         ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(
                             content: Text('Expired documents can not add'),
                             backgroundColor: Colors.red,
                           ),
                         );
                         return;
                       }
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
                       style: ElevatedButton.styleFrom(
                         backgroundColor: AppColors.primary200,
                         foregroundColor: Colors.white,
                       ),
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