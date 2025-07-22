import 'package:flutter/material.dart';

Future<void> platformDownloadFile(BuildContext context, String downloadUrl, String fileName) async {
  // Implement mobile download logic or show a message
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('File download is only supported on web in this version.')),
  );
}

Widget buildDocumentPreview(BuildContext context, bool isImage, String previewUrl, String fileName, String title, VoidCallback onDownload, VoidCallback onDelete) {
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
        : const Center(child: Text('Document preview is only supported for images on mobile.')),
  );
} 