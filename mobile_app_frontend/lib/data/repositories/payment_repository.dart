import 'package:dio/dio.dart';
import '../models/advance_payment_model.dart';
import '../../core/config/api_config.dart';

class PaymentRepository {
  final Dio dio;

  PaymentRepository(this.dio);

  Future<AdvancePaymentCalculation> calculateAdvancePayment({
    required int appointmentId,
    required int customerId,
    required int vehicleId,
    required String token,
  }) async {
    final response = await dio.get(
      '${ApiConfig.currentBaseUrl}/AppointmentPayment/calculate/$appointmentId?customerId=$customerId&vehicleId=$vehicleId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return AdvancePaymentCalculation.fromJson(response.data);
  }

  Future<Map<String, dynamic>> createPayHereSession({
    required int appointmentId,
    required int customerId,
    required int vehicleId,
    required double amount,
    required String userEmail,
    required String userName,
    required String token,
  }) async {
    final response = await dio.post(
      '${ApiConfig.currentBaseUrl}/payhere/create-session',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
      data: {
        'appointmentId': appointmentId,
        'customerId': customerId,
        'vehicleId': vehicleId,
        'userEmail': userEmail,
        'userName': userName,
        'amount': amount,
      },
    );

    return response.data;
  }

  Future<Map<String, dynamic>> getPaymentStatus({
    required int appointmentId,
    required String token,
  }) async {
    final response = await dio.get(
      '${ApiConfig.currentBaseUrl}/AppointmentPayment/status/$appointmentId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return response.data;
  }
}
