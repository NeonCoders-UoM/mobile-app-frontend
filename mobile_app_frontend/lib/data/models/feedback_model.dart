class CreateFeedbackDTO {
  final int customerId;
  final int serviceCenterId;
  final int vehicleId;
  final int rating;
  final String comments;
  final DateTime serviceDate;

  CreateFeedbackDTO({
    required this.customerId,
    required this.serviceCenterId,
    required this.vehicleId,
    required this.rating,
    required this.comments,
    required this.serviceDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'serviceCenterId': serviceCenterId,
      'vehicleId': vehicleId,
      'rating': rating,
      'comments': comments,
      'serviceDate': serviceDate.toIso8601String(),
    };
  }
}

class FeedbackDTO {
  final int feedbackId;
  final int customerId;
  final int serviceCenterId;
  final int vehicleId;
  final int rating;
  final String comments;
  final DateTime serviceDate;
  final DateTime feedbackDate;
  final String customerName;
  final String serviceCenterName;
  final String vehicleRegistrationNumber;

  FeedbackDTO({
    required this.feedbackId,
    required this.customerId,
    required this.serviceCenterId,
    required this.vehicleId,
    required this.rating,
    required this.comments,
    required this.serviceDate,
    required this.feedbackDate,
    required this.customerName,
    required this.serviceCenterName,
    required this.vehicleRegistrationNumber,
  });

  factory FeedbackDTO.fromJson(Map<String, dynamic> json) {
    return FeedbackDTO(
      feedbackId: json['feedbackId'],
      customerId: json['customerId'],
      serviceCenterId: json['serviceCenterId'],
      vehicleId: json['vehicleId'],
      rating: json['rating'],
      comments: json['comments'],
      serviceDate: DateTime.parse(json['serviceDate']),
      feedbackDate: DateTime.parse(json['feedbackDate']),
      customerName: json['customerName'],
      serviceCenterName: json['serviceCenterName'],
      vehicleRegistrationNumber: json['vehicleRegistrationNumber'],
    );
  }
}

class UpdateFeedbackDTO {
  final int? rating;
  final String? comments;
  final DateTime? serviceDate;

  UpdateFeedbackDTO({
    this.rating,
    this.comments,
    this.serviceDate,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (rating != null) data['rating'] = rating;
    if (comments != null) data['comments'] = comments;
    if (serviceDate != null)
      data['serviceDate'] = serviceDate!.toIso8601String();
    return data;
  }
}

class FeedbackStatsDTO {
  final double averageRating;
  final int totalFeedbacks;
  final Map<String, int> ratingCounts;

  FeedbackStatsDTO({
    required this.averageRating,
    required this.totalFeedbacks,
    required this.ratingCounts,
  });

  factory FeedbackStatsDTO.fromJson(Map<String, dynamic> json) {
    return FeedbackStatsDTO(
      averageRating: json['averageRating'].toDouble(),
      totalFeedbacks: json['totalFeedbacks'],
      ratingCounts: Map<String, int>.from(json['ratingCounts']),
    );
  }
}
