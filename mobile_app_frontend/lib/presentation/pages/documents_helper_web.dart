import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Future<void> platformDownloadFile(BuildContext context, String downloadUrl, String fileName) async {
  final response = await html.HttpRequest.request(downloadUrl, responseType: 'arraybuffer');
  final blob = html.Blob([response.response]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}

Widget buildDocumentPreview(BuildContext context, bool isImage, String previewUrl, String fileName, String title, VoidCallback onDownload, VoidCallback onDelete) {
  if (!isImage) {
    final iframe = html.IFrameElement()
      ..src = previewUrl
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      'iframeElement-$previewUrl',
      (int viewId) => iframe,
    );
  }
  return Scaffold(
    backgroundColor: Colors.grey[200],
    appBar: AppBar(
      title: Text(title),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.download),
          onPressed: onDownload,
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ],
    ),
    body: isImage
        ? Image.network(
            previewUrl,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                  child: Text('Error loading image',
                      style: TextStyle(color: Colors.red)));
            },
          )
        : HtmlElementView(viewType: 'iframeElement-$previewUrl'),
  );
} 