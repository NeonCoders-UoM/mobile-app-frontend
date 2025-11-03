class AppointmentSummary {
  final int appointmentId;
  final String stationName;
  final DateTime appointmentDate;

  AppointmentSummary({
    required this.appointmentId,
    required this.stationName,
    required this.appointmentDate,
  });

  factory AppointmentSummary.fromJson(Map<String, dynamic> json) {
    return AppointmentSummary(
      appointmentId: json['appointmentId'],
      stationName: json['stationName'],
      appointmentDate: DateTime.parse(json['appointmentDate']),
    );
  }
}

class AppointmentCreate {
  final int customerId;
  final int vehicleId;
  final int stationId;
  final DateTime appointmentDate;
  final List<int> serviceIds;

  AppointmentCreate({
    required this.customerId,
    required this.vehicleId,
    required this.stationId,
    required this.appointmentDate,
    required this.serviceIds,
  });

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'vehicleId': vehicleId,
        'station_id': stationId,
        'appointmentDate': appointmentDate.toIso8601String(),
        'serviceIds': serviceIds,
      };
}
