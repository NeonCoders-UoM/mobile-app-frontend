import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:mobile_app_frontend/data/repositories/service_history_repository.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/pages/enter_payment_details_page.dart';
import 'dart:io';

class PdfContentPage extends StatefulWidget {
  final int vehicleId;
  final String? token;
  final int? customerId;

  const PdfContentPage({
    Key? key,
    required this.vehicleId,
    this.token,
    this.customerId,
  }) : super(key: key);

  @override
  State<PdfContentPage> createState() => _PdfContentPageState();
}

class _PdfContentPageState extends State<PdfContentPage> {
  bool _hasPaid = false;
  bool _isLoading = false;
  String? _localPdfPath;
  bool _pdfLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    setState(() {
      _pdfLoading = true;
      _errorMessage = null;
    });
    try {
      final url = ServiceHistoryRepository().getServiceHistoryPdfPreviewUrl(widget.vehicleId);
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/service_history_${widget.vehicleId}.pdf');
        await file.writeAsBytes(bytes);
        setState(() {
          _localPdfPath = file.path;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load PDF: Server returned ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading PDF: $e';
      });
    } finally {
      setState(() {
        _pdfLoading = false;
      });
    }
  }

  Future<void> _handleDownload(BuildContext context) async {
    if (!_hasPaid) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EnterPaymentDetailsPage(
            customerId: widget.customerId ?? 0,
            vehicleId: widget.vehicleId,
            token: widget.token ?? '',
          ),
        ),
      );
      if (result == true) { // Assuming payment page returns true on success
        setState(() {
          _hasPaid = true;
        });
      }
      return;
    }
    // Trigger download for mobile
    if (context.findAncestorStateOfType<_PdfViewPageState>() != null) {
      context.findAncestorStateOfType<_PdfViewPageState>()!._downloadPdf();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final previewWidth = screenWidth * 0.95;
    final previewHeight = screenHeight * 0.4;

    return Scaffold(
      backgroundColor: AppColors.neutral500,
      appBar: AppBar(
        backgroundColor: AppColors.neutral500,
        elevation: 0,
        title: const Text('View Service History PDF'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: _pdfLoading
                    ? const CircularProgressIndicator(color: AppColors.primary200)
                    : _errorMessage != null
                        ? Container(
                            width: previewWidth,
                            height: previewHeight,
                            decoration: BoxDecoration(
                              color: AppColors.neutral400,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                _errorMessage!,
                                style: AppTextStyles.textMdSemibold.copyWith(color: AppColors.primary200),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : _localPdfPath != null
                            ? Container(
                                width: previewWidth,
                                height: previewHeight,
                                decoration: BoxDecoration(
                                  color: AppColors.neutral400,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: PDFView(
                                  filePath: _localPdfPath!,
                                  enableSwipe: true,
                                  swipeHorizontal: false,
                                  autoSpacing: true,
                                  pageFling: true,
                                  onError: (error) {
                                    setState(() {
                                      _errorMessage = 'Error rendering PDF: $error';
                                    });
                                  },
                                  onPageError: (page, error) {
                                    setState(() {
                                      _errorMessage = 'Error on page $page: $error';
                                    });
                                  },
                                ),
                              )
                            : Container(
                                width: previewWidth,
                                height: previewHeight,
                                decoration: BoxDecoration(
                                  color: AppColors.neutral400,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    'Failed to load PDF preview.',
                                    style: AppTextStyles.textMdSemibold.copyWith(color: AppColors.primary200),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.neutral400,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock, color: AppColors.primary200),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'To download this PDF, you must pay Rs.500.',
                      style: AppTextStyles.textMdSemibold.copyWith(color: AppColors.primary200),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _handleDownload(context),
                icon: Icon(_hasPaid ? Icons.download : Icons.lock_open, color: Colors.white),
                label: Text(
                  _hasPaid ? 'Download PDF' : 'Pay & Download',
                  style: AppTextStyles.textMdSemibold.copyWith(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary200,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PdfViewPage extends StatefulWidget {
  final int vehicleId;
  final String? token;

  const PdfViewPage({
    Key? key,
    required this.vehicleId,
    this.token,
  }) : super(key: key);

  @override
  State<PdfViewPage> createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  final ServiceHistoryRepository _repository = ServiceHistoryRepository();
  bool _isLoading = false;

  Future<void> _downloadPdf() async {
    setState(() => _isLoading = true);
    try {
      final pdfBytes = await _repository.downloadServiceHistoryPdf(
        widget.vehicleId,
        token: widget.token,
      );
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/service_history_${widget.vehicleId}.pdf');
      await file.writeAsBytes(pdfBytes);
      // TODO: Use a package like `open_file` or `share_plus` to open or share the file
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF saved to ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download PDF: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral500,
      appBar: AppBar(
        backgroundColor: AppColors.neutral500,
        elevation: 0,
        title: const Text('Service History PDF'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: Image.asset(
                    'assets/images/mustang.png',
                    height: 210,
                    width: 280,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  color: AppColors.neutral400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      children: [
                        Text(
                          'Vehicle Service History Report',
                          style: AppTextStyles.textLgBold.copyWith(color: AppColors.primary200),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Download the complete service history of your vehicle as a PDF report. This document is suitable for sharing, printing, or record-keeping.',
                          style: AppTextStyles.textSmRegular.copyWith(color: AppColors.neutral150),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? const CircularProgressIndicator(color: AppColors.primary200)
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PdfContentPage(
                                          vehicleId: widget.vehicleId,
                                          token: widget.token,
                                          customerId: 0, // Pass customerId if available
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                                  label: Text(
                                    'View PDF',
                                    style: AppTextStyles.textMdSemibold.copyWith(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary200,
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Tip: You can print the PDF or share it with your service provider for a complete maintenance record.',
                  style: AppTextStyles.textXsmRegular.copyWith(color: AppColors.neutral200),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}