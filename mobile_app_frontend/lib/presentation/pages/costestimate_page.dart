import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/cost_estimate_table.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/cost_estimate_description.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/pages/advanced_payment_required_page.dart';
import 'package:mobile_app_frontend/presentation/pages/appointment_page.dart';
import 'package:mobile_app_frontend/presentation/pages/servicecenter_page.dart';
import 'package:mobile_app_frontend/presentation/pages/vehicledetailshome_page.dart';
import 'package:mobile_app_frontend/data/repositories/service_center_repository.dart';
import 'package:mobile_app_frontend/data/models/service_model.dart';
import 'package:dio/dio.dart';
import 'package:mobile_app_frontend/data/repositories/appointment_repository.dart';
import 'package:mobile_app_frontend/data/models/appointment_model.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class CostEstimatePage extends StatefulWidget {
  final int customerId;
  final int vehicleId;
  final String token;
  final int appointmentId;
  final String? distance;

  const CostEstimatePage({
    Key? key,
    required this.customerId,
    required this.vehicleId,
    required this.token,
    required this.appointmentId,
    this.distance,
  }) : super(key: key);

  @override
  State<CostEstimatePage> createState() => _CostEstimatePageState();
}

class _CostEstimatePageState extends State<CostEstimatePage> {
  double totalCost = 0.0;
  bool isLoading = true;
  String? errorMessage;
  List<String> serviceNames = [];
  List<int> serviceCosts = [];
  String serviceCenterName = '';
  String serviceCenterId = '';
  String vehicleRegNo = '';
  String appointmentDate = '';
  String address = '';
  String loyaltyPoints = '';
  String distance = '';
  double? serviceCenterLat;
  double? serviceCenterLng;
  double? userLat;
  double? userLng;
  String computedDistance = '';
  List<Map<String, dynamic>> detailedServices = [];

  @override
  void initState() {
    super.initState();
    _fetchCostEstimateFromBackend();
  }

  Future<String?> fetchVehicleRegistrationNo(
      int customerId, int vehicleId, String token) async {
    final dio = Dio();
    final response = await dio.get(
      'http://10.10.13.168:5039/api/Customers/$customerId/vehicles/$vehicleId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.statusCode == 200 && response.data != null) {
      return response.data['registrationNumber'] as String?;
    }
    return null;
  }

  Future<void> _fetchCostEstimateFromBackend() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final dio = Dio();
      final response = await dio.get(
        'http://10.10.13.168:5039/api/Appointment/customer/${widget.customerId}/vehicle/${widget.vehicleId}/details/${widget.appointmentId}',
        options: Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
      );
      final data = response.data;
      serviceCenterId = (data['stationId']?.toString() ??
          data['serviceCenterId']?.toString() ??
          '');
      serviceCenterName = data['stationName'] ?? '';
      vehicleRegNo = data['vehicleRegistrationNumber'] ?? '';
      appointmentDate = data['appointmentDate'] ?? '';
      address = data['stationAddress'] ?? data['address'] ?? '';
      loyaltyPoints = data['loyaltyPoints']?.toString() ?? '';
      distance = data['distance']?.toString() ?? '';
      // Parse services and costs
      final List<dynamic> services = (data['services'] ?? []) as List<dynamic>;
      serviceNames = [];
      serviceCosts = [];
      detailedServices = [];
      double runningTotal = 0.0;
      for (final s in services) {
        final name = s['serviceName'] as String? ?? '';
        final cost = (s['estimatedCost'] as num?)?.toInt() ?? 0;
        serviceNames.add(name);
        serviceCosts.add(cost);
        runningTotal += cost;
        detailedServices.add(Map<String, dynamic>.from(s));
      }
      totalCost = (data['totalCost'] as num?)?.toDouble() ?? runningTotal;
      // Fetch service center details if stationId is available
      if (serviceCenterId.isNotEmpty) {
        try {
          final scResponse = await dio.get(
            'http://10.10.13.168:5039/api/ServiceCenters/$serviceCenterId',
            options:
                Options(headers: {'Authorization': 'Bearer ${widget.token}'}),
          );
          final scData = scResponse.data;
          address = scData['address'] ?? address;
          serviceCenterName = scData['station_name'] ?? serviceCenterName;
          serviceCenterLat = (scData['latitude'] as num?)?.toDouble();
          serviceCenterLng = (scData['longitude'] as num?)?.toDouble();
        } catch (e) {
          // If fetching service center fails, keep previous address/name
        }
      }
      // Fetch vehicle registration number from CustomersController
      final regNo = await fetchVehicleRegistrationNo(
          widget.customerId, widget.vehicleId, widget.token);
      if (regNo != null && regNo.isNotEmpty) {
        vehicleRegNo = regNo;
      }
      // Get user location and compute distance
      await _getUserLocationAndComputeDistance();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _getUserLocationAndComputeDistance() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      userLat = position.latitude;
      userLng = position.longitude;
      if (serviceCenterLat != null && serviceCenterLng != null) {
        final dist = _calculateDistance(
            userLat!, userLng!, serviceCenterLat!, serviceCenterLng!);
        computedDistance = '${dist.toStringAsFixed(2)} km';
      }
    } catch (e) {
      // Ignore location errors
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Earth's radius in km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double deg) => deg * pi / 180;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Cost Estimation',
        showTitle: true,
        onBackPressed: () => {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceCenterPage(
                selectedServices: [],
                selectedDate: DateTime.now(),
                customerId: widget.customerId,
                vehicleId: widget.vehicleId,
                token: widget.token,
              ),
            ),
          ),
        },
      ),
      backgroundColor: AppColors.neutral400,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(child: Text('Error: $errorMessage'))
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CostEstimateDescription(
                            servicecenterName: serviceCenterName,
                            vehicleRegNo: vehicleRegNo,
                            appointmentDate: appointmentDate,
                            loyaltyPoints: loyaltyPoints,
                            serviceCenterId: serviceCenterId,
                            address: address,
                            distance: widget.distance ?? computedDistance,
                          ),
                          const SizedBox(height: 48),
                          CostEstimateTable(
                            services: serviceNames,
                            costs: serviceCosts,
                            total: totalCost.toInt(),
                            detailedServices: detailedServices,
                          ),
                          const SizedBox(height: 80),
                          SizedBox(
                            width: double.infinity,
                            child: CustomButton(
                              label: 'Book an Appointment',
                              type: ButtonType.primary,
                              size: ButtonSize.medium,
                              onTap: () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AppointmentPage(
                                      customerId: widget.customerId,
                                      vehicleId: widget.vehicleId,
                                      token: widget.token,
                                    ),
                                  ),
                                )
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
