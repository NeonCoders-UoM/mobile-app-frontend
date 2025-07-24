import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/service_center_card.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/pages/appointmentconfirmation_page.dart';
import 'package:mobile_app_frontend/presentation/pages/costestimate_page.dart';
import 'package:mobile_app_frontend/data/models/service_model.dart';
import 'package:mobile_app_frontend/data/models/service_center_model.dart';
import 'package:mobile_app_frontend/data/repositories/service_center_repository.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_app_frontend/data/models/appointment_model.dart';
import 'package:mobile_app_frontend/data/repositories/appointment_repository.dart';
import 'dart:math';

class ServiceCenterPage extends StatefulWidget {
  final List<Service> selectedServices;
  final DateTime selectedDate;
  final int customerId;
  final int vehicleId;
  final String token;

  const ServiceCenterPage({
    Key? key,
    required this.selectedServices,
    required this.selectedDate,
    required this.customerId,
    required this.vehicleId,
    required this.token,
  }) : super(key: key);

  @override
  State<ServiceCenterPage> createState() => _ServiceCenterPageState();
}

class _ServiceCenterPageState extends State<ServiceCenterPage> {
  List<ServiceCenterModel> centers = [];
  Map<int, double> costEstimates = {};
  bool isLoading = true;
  String? errorMessage;
  double? userLat;
  double? userLng;
  Map<int, int> loyaltyPointsMap = {};

  @override
  void initState() {
    super.initState();
    _fetchNearbyCentersAndCosts();
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Earth's radius in km
    final dLat = (lat2 - lat1) * (pi / 180.0);
    final dLon = (lon2 - lon1) * (pi / 180.0);
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1 * (pi / 180.0)) *
            cos(lat2 * (pi / 180.0)) *
            (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  Future<void> _fetchNearbyCentersAndCosts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // Step 1: Get current location
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception("Location services are disabled.");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception("Location permission denied.");
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permission permanently denied.");
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

    final lat = position.latitude;
    final lng = position.longitude;
    print('lat: $lat, lng: $lng');
print('serviceIds: ${widget.selectedServices.map((s) => s.serviceId).toList()}');

    // Step 2: Call nearby API using Dio
    final dio = Dio();
    final response = await dio.get(
      'http://192.168.1.11:5039/api/servicecenters/nearby',
      queryParameters: {
        'lat': lat,
        'lng': lng,
        'serviceIds': widget.selectedServices.map((s) => s.serviceId).toList(),
      },
      options: Options(headers: {
        'Authorization': 'Bearer ${widget.token}',
      }),
    );

      // Step 2: Call nearby API using Dio
      final dio = Dio();
      final response = await dio.get(
        'http://localhost:5039/api/servicecenters/nearby',
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'serviceIds':
              widget.selectedServices.map((s) => s.serviceId).toList(),
        },
        options: Options(headers: {
          'Authorization': 'Bearer ${widget.token}',
        }),
      );

      final List<dynamic> responseData = response.data;
      final List<ServiceCenterModel> data = responseData
          .map((json) => ServiceCenterModel.fromJson(json))
          .toList();

      print('Received ${data.length} centers');
      for (var c in data) {
        print(
            'Center: ${c.stationName}, lat: ${c.latitude}, lng: ${c.longitude}');
      }

      // Step 3: For each center, create a temp appointment and fetch cost estimation
      final appointmentRepo = AppointmentRepository(dio);
      final Map<int, double> costs = {};
      final Map<int, int> points = {};
      for (final center in data) {
        try {
          final serviceIds =
              widget.selectedServices.map((s) => s.serviceId).toList();
          final appointment = AppointmentCreate(
            customerId: widget.customerId,
            vehicleId: widget.vehicleId,
            stationId: center.stationId,
            appointmentDate: widget.selectedDate,
            serviceIds: serviceIds,
          );
          // Create appointment and get appointmentId
          final appointmentId = await appointmentRepo
              .createAppointmentAndReturnId(appointment, widget.token);
          // Fetch appointment details (cost estimation)
          final detailsResponse = await dio.get(
            'http://localhost:5039/api/Appointment/customer/${widget.customerId}/vehicle/${widget.vehicleId}/details/$appointmentId',
            options:
                Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
          );
          final detailsData = detailsResponse.data;
          final double cost =
              (detailsData['totalCost'] as num?)?.toDouble() ?? 0.0;
          costs[center.stationId] = cost;
          final int pointsForCenter =
              (detailsData['loyaltyPoints'] as num?)?.toInt() ?? 0;
          points[center.stationId] = pointsForCenter;
        } catch (e) {
          costs[center.stationId] = 0.0;
          points[center.stationId] = 0;
          print(
              'Error fetching cost for center ${center.stationId}: ${e.toString()}');
        }
      }

      setState(() {
        centers = data;
        costEstimates = costs;
        loyaltyPointsMap = points;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Select Service Center',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral400,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text('Error: $errorMessage'))
                : ListView.separated(
                    itemCount: centers.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final center = centers[index];
                      final cost = costEstimates[center.stationId] ?? 0.0;
                      String distanceStr = '';
                      if (userLat != null && userLng != null) {
                        final dist = _calculateDistance(userLat!, userLng!,
                            center.latitude, center.longitude);
                        distanceStr = '${dist.toStringAsFixed(2)} km';
                      }
                      return ServiceCenterCard(
                        servicecenterName: center.stationName,
                        address: center.address,
                        distance: distanceStr,
                        loyaltyPoints:
                            loyaltyPointsMap[center.stationId]?.toString() ??
                                '',
                        estimatedCost: 'Rs. ${cost.toStringAsFixed(2)}',
                        onTap: () async {
                          try {
                            // Create appointment for this center and get appointmentId
                            final dio = Dio();
                            final appointmentRepo = AppointmentRepository(dio);
                            final serviceIds = widget.selectedServices
                                .map((s) => s.serviceId)
                                .toList();
                            final appointment = AppointmentCreate(
                              customerId: widget.customerId,
                              vehicleId: widget.vehicleId,
                              stationId: center.stationId,
                              appointmentDate: widget.selectedDate,
                              serviceIds: serviceIds,
                            );
                            final appointmentId = await appointmentRepo
                                .createAppointmentAndReturnId(
                                    appointment, widget.token);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CostEstimatePage(
                                  customerId: widget.customerId,
                                  vehicleId: widget.vehicleId,
                                  token: widget.token,
                                  appointmentId: appointmentId,
                                  distance: distanceStr,
                                ),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Failed to create appointment: $e')),
                            );
                          }
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
