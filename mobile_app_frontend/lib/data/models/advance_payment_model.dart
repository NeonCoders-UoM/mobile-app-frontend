class AdvancePaymentCalculation {
  final int appointmentId;
  final double totalCost;
  final double advancePaymentAmount;
  final double remainingAmount;
  final String paymentType;
  final String serviceCenterName;
  final String vehicleRegistration;
  final DateTime appointmentDate;
  final List<AppointmentServiceDetail> services;

  AdvancePaymentCalculation({
    required this.appointmentId,
    required this.totalCost,
    required this.advancePaymentAmount,
    required this.remainingAmount,
    required this.paymentType,
    required this.serviceCenterName,
    required this.vehicleRegistration,
    required this.appointmentDate,
    required this.services,
  });

  factory AdvancePaymentCalculation.fromJson(Map<String, dynamic> json) {
    return AdvancePaymentCalculation(
      appointmentId: json['appointmentId'] ?? 0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
      advancePaymentAmount:
          (json['advancePaymentAmount'] as num?)?.toDouble() ?? 0.0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0.0,
      paymentType: json['paymentType'] ?? '',
      serviceCenterName: json['serviceCenterName'] ?? '',
      vehicleRegistration: json['vehicleRegistration'] ?? '',
      appointmentDate: DateTime.parse(
          json['appointmentDate'] ?? DateTime.now().toIso8601String()),
      services: (json['services'] as List<dynamic>?)
              ?.map((service) => AppointmentServiceDetail.fromJson(service))
              .toList() ??
          [],
    );
  }
}

class AppointmentServiceDetail {
  final String serviceName;
  final double estimatedCost;

  AppointmentServiceDetail({
    required this.serviceName,
    required this.estimatedCost,
  });

  factory AppointmentServiceDetail.fromJson(Map<String, dynamic> json) {
    return AppointmentServiceDetail(
      serviceName: json['serviceName'] ?? '',
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class AdvancePaymentRequest {
  final int appointmentId;
  final int customerId;
  final int vehicleId;
  final String userEmail;
  final String userName;
  final String paymentMethod;

  AdvancePaymentRequest({
    required this.appointmentId,
    required this.customerId,
    required this.vehicleId,
    required this.userEmail,
    required this.userName,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'appointmentId': appointmentId,
      'customerId': customerId,
      'vehicleId': vehicleId,
      'userEmail': userEmail,
      'userName': userName,
      'paymentMethod': paymentMethod,
    };
  }
}
