class VehicleTransfer {
  final int transferId;
  final int vehicleId;
  final String? vehicleName;
  final String? registrationNumber;
  final int fromOwnerId;
  final String? fromOwnerName;
  final String? fromOwnerEmail;
  final int toOwnerId;
  final String? toOwnerName;
  final String? toOwnerEmail;
  final DateTime initiatedAt;
  final DateTime? completedAt;
  final String status;
  final int? mileageAtTransfer;
  final double? salePrice;
  final String? notes;
  final DateTime expiresAt;

  VehicleTransfer({
    required this.transferId,
    required this.vehicleId,
    this.vehicleName,
    this.registrationNumber,
    required this.fromOwnerId,
    this.fromOwnerName,
    this.fromOwnerEmail,
    required this.toOwnerId,
    this.toOwnerName,
    this.toOwnerEmail,
    required this.initiatedAt,
    this.completedAt,
    required this.status,
    this.mileageAtTransfer,
    this.salePrice,
    this.notes,
    required this.expiresAt,
  });

  factory VehicleTransfer.fromJson(Map<String, dynamic> json) {
    return VehicleTransfer(
      transferId: json['transferId'],
      vehicleId: json['vehicleId'],
      vehicleName: json['vehicleName'],
      registrationNumber: json['registrationNumber'],
      fromOwnerId: json['fromOwnerId'],
      fromOwnerName: json['fromOwnerName'],
      fromOwnerEmail: json['fromOwnerEmail'],
      toOwnerId: json['toOwnerId'],
      toOwnerName: json['toOwnerName'],
      toOwnerEmail: json['toOwnerEmail'],
      initiatedAt: DateTime.parse(json['initiatedAt']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      status: json['status'],
      mileageAtTransfer: json['mileageAtTransfer'],
      salePrice: json['salePrice'] != null ? double.parse(json['salePrice'].toString()) : null,
      notes: json['notes'],
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transferId': transferId,
      'vehicleId': vehicleId,
      'vehicleName': vehicleName,
      'registrationNumber': registrationNumber,
      'fromOwnerId': fromOwnerId,
      'fromOwnerName': fromOwnerName,
      'fromOwnerEmail': fromOwnerEmail,
      'toOwnerId': toOwnerId,
      'toOwnerName': toOwnerName,
      'toOwnerEmail': toOwnerEmail,
      'initiatedAt': initiatedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'status': status,
      'mileageAtTransfer': mileageAtTransfer,
      'salePrice': salePrice,
      'notes': notes,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'Pending';
  bool get isAccepted => status == 'Accepted';
  bool get isRejected => status == 'Rejected';
  bool get isCancelled => status == 'Cancelled';
  bool get isExpired => status == 'Expired' || expiresAt.isBefore(DateTime.now());
}
