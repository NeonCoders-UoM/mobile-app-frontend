import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app_frontend/core/config/api_config.dart';
import 'package:mobile_app_frontend/data/models/feedback_model.dart';

class FeedbackRepository {
  final String baseUrl = ApiConfig.baseUrl;

  // Create new feedback
  Future<FeedbackDTO> createFeedback(CreateFeedbackDTO feedback) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.getFeedbackUrl()),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(feedback.toJson()),
      );

      if (response.statusCode == 201) {
        return FeedbackDTO.fromJson(jsonDecode(response.body));
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to create feedback');
      }
    } catch (e) {
      throw Exception('Failed to create feedback: $e');
    }
  }

  // Get all feedbacks (for admin/service center)
  Future<List<FeedbackDTO>> getAllFeedbacks({
    int page = 1,
    int pageSize = 10,
    int? serviceCenterId,
    int? minRating,
    int? maxRating,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      if (serviceCenterId != null) {
        queryParams['serviceCenterId'] = serviceCenterId.toString();
      }
      if (minRating != null) {
        queryParams['minRating'] = minRating.toString();
      }
      if (maxRating != null) {
        queryParams['maxRating'] = maxRating.toString();
      }

      final uri = Uri.parse(ApiConfig.getFeedbackUrl())
          .replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => FeedbackDTO.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch feedbacks');
      }
    } catch (e) {
      throw Exception('Failed to fetch feedbacks: $e');
    }
  }

  // Get feedback by ID
  Future<FeedbackDTO> getFeedbackById(int id) async {
    try {
      final response =
          await http.get(Uri.parse(ApiConfig.getFeedbackByIdUrl(id)));

      if (response.statusCode == 200) {
        return FeedbackDTO.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Feedback not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch feedback: $e');
    }
  }

  // Get customer feedbacks
  Future<List<FeedbackDTO>> getCustomerFeedbacks(int customerId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getFeedbackByCustomerUrl(customerId)),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => FeedbackDTO.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch customer feedbacks');
      }
    } catch (e) {
      throw Exception('Failed to fetch customer feedbacks: $e');
    }
  }

  // Get service center feedbacks
  Future<List<FeedbackDTO>> getServiceCenterFeedbacks(
      int serviceCenterId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getFeedbackByServiceCenterUrl(serviceCenterId)),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => FeedbackDTO.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch service center feedbacks');
      }
    } catch (e) {
      throw Exception('Failed to fetch service center feedbacks: $e');
    }
  }

  // Get feedback statistics
  Future<FeedbackStatsDTO> getFeedbackStats({int? serviceCenterId}) async {
    try {
      final queryParams = <String, String>{};
      if (serviceCenterId != null) {
        queryParams['serviceCenterId'] = serviceCenterId.toString();
      }

      final uri = Uri.parse(
              ApiConfig.getFeedbackStatsUrl(serviceCenterId: serviceCenterId))
          .replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return FeedbackStatsDTO.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch feedback statistics');
      }
    } catch (e) {
      throw Exception('Failed to fetch feedback statistics: $e');
    }
  }

  // Update feedback
  Future<void> updateFeedback(int id, UpdateFeedbackDTO feedback) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.getFeedbackByIdUrl(id)),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(feedback.toJson()),
      );

      if (response.statusCode != 204) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to update feedback');
      }
    } catch (e) {
      throw Exception('Failed to update feedback: $e');
    }
  }

  // Delete feedback (admin only)
  Future<void> deleteFeedback(int id) async {
    try {
      final response =
          await http.delete(Uri.parse(ApiConfig.getFeedbackByIdUrl(id)));

      if (response.statusCode != 204) {
        throw Exception('Failed to delete feedback');
      }
    } catch (e) {
      throw Exception('Failed to delete feedback: $e');
    }
  }
}
