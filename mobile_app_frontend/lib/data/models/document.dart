class Document {
  final int documentId;
  final String fileName;
  final String fileUrl;
  final int customerId;
  final int? vehicleId;
  final String documentType;
  final DateTime uploadedAt;

  Document({
    required this.documentId,
    required this.fileName,
    required this.fileUrl,
    required this.customerId,
    this.vehicleId,
    required this.documentType,
    required this.uploadedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      documentId: json['documentId'],
      fileName: json['fileName'],
      fileUrl: json['fileUrl'],
      customerId: json['customerId'],
      vehicleId: json['vehicleId'],
      documentType: json['documentType'],
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }
}
