import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/star_rating.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/cost_estimate_description.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/button.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_type.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/enums/button_size.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/data/repositories/feedback_repository.dart';
import 'package:mobile_app_frontend/data/repositories/appointment_repository.dart';
import 'package:mobile_app_frontend/data/repositories/service_center_repository.dart';
import 'package:mobile_app_frontend/data/models/feedback_model.dart';
import 'package:mobile_app_frontend/data/models/service_center_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FeedbackPage extends StatefulWidget {
  final int vehicleId;
  final int? customerId;
  final String? token;
  final int? serviceCenterId;
  final DateTime? serviceDate;
  final int?
      appointmentId; // Add appointment ID to get specific appointment details

  const FeedbackPage({
    Key? key,
    required this.vehicleId,
    this.customerId,
    this.token,
    this.serviceCenterId,
    this.serviceDate,
    this.appointmentId,
  }) : super(key: key);

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int rating = 0;
  final TextEditingController feedbackController = TextEditingController();

  bool isSubmitting = false;

  final FeedbackRepository _feedbackRepository = FeedbackRepository();
  final AppointmentRepository _appointmentRepository = AppointmentRepository();
  final ServiceCenterRepository _serviceCenterRepository =
      ServiceCenterRepository();

  String? serviceCenterName;
  DateTime? actualServiceDate;
  int?
      _actualServiceCenterId; // Store the actual service center ID from appointment

  // Service center dropdown variables
  List<ServiceCenterDTO> _serviceCenters = [];
  ServiceCenterDTO? _selectedServiceCenter;
  bool _isLoadingServiceCenters = false;

  @override
  void initState() {
    super.initState();
    _loadServiceCenterInfo();
    _loadServiceCenters();
  }

  Future<void> _loadServiceCenterInfo() async {
    // If service center ID is provided, use it; otherwise try to get from recent appointment
    if (widget.serviceCenterId != null) {
      try {
        // You might want to create a service center repository to get the name
        // For now, we'll use a placeholder
        setState(() {
          serviceCenterName = 'Service Center ${widget.serviceCenterId}';
          _actualServiceCenterId = widget.serviceCenterId;
        });
      } catch (e) {
        debugPrint('Error loading service center info: $e');
      }
    }

    // If service date is provided, use it; otherwise try to get from appointment details
    if (widget.serviceDate != null) {
      actualServiceDate = widget.serviceDate;
    } else if (widget.customerId != null && widget.token != null) {
      try {
        Map<String, dynamic>? appointmentDetails;

        // If appointment ID is provided, get specific appointment details
        if (widget.appointmentId != null) {
          appointmentDetails =
              await _appointmentRepository.getAppointmentDetails(
            widget.customerId!,
            widget.vehicleId,
            widget.appointmentId!,
            widget.token!,
          );
        } else {
          // Otherwise get the most recent appointment
          appointmentDetails =
              await _appointmentRepository.getMostRecentAppointment(
            widget.customerId!,
            widget.vehicleId,
            widget.token!,
          );
        }

        if (appointmentDetails != null) {
          if (appointmentDetails['appointmentDate'] != null) {
            actualServiceDate =
                DateTime.parse(appointmentDetails['appointmentDate']);
          }

          // Extract service center ID from appointment details
          if (appointmentDetails['stationId'] != null) {
            final stationId = appointmentDetails['stationId'] as int;
            setState(() {
              serviceCenterName = 'Service Center $stationId';
              _actualServiceCenterId = stationId;
            });
          } else if (appointmentDetails['serviceCenterId'] != null) {
            // Alternative field name
            final serviceCenterId =
                appointmentDetails['serviceCenterId'] as int;
            setState(() {
              serviceCenterName = 'Service Center $serviceCenterId';
              _actualServiceCenterId = serviceCenterId;
            });
          }
        }
      } catch (e) {
        debugPrint('Error loading appointment details: $e');
      }
    }
  }

  Future<void> _loadServiceCenters() async {
    setState(() {
      _isLoadingServiceCenters = true;
    });

    try {
      // Get active service centers
      final serviceCenters =
          await _serviceCenterRepository.getServiceCentersByStatus('active');
      setState(() {
        _serviceCenters = serviceCenters;
        _isLoadingServiceCenters = false;
      });

      // If we have an actual service center ID from appointment, try to select it
      if (_actualServiceCenterId != null && serviceCenters.isNotEmpty) {
        try {
          final matchingCenter = serviceCenters.firstWhere(
            (center) => center.stationId == _actualServiceCenterId,
          );
          setState(() {
            _selectedServiceCenter = matchingCenter;
          });
        } catch (e) {
          // If no matching center found, select the first one
          setState(() {
            _selectedServiceCenter = serviceCenters.first;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading service centers: $e');
      setState(() {
        _isLoadingServiceCenters = false;
      });
    }
  }

  Future<void> _handleSubmitFeedback() async {
    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please provide a rating"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedServiceCenter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a service center"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.customerId == null || widget.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Missing customer information"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // Use the selected service center ID, fallback to actual service center ID from appointment details, then to widget's serviceCenterId, then to 1
      final serviceCenterId = _selectedServiceCenter?.stationId ??
          _actualServiceCenterId ??
          widget.serviceCenterId ??
          1;

      final feedback = CreateFeedbackDTO(
        customerId: widget.customerId!,
        serviceCenterId: serviceCenterId,
        vehicleId: widget.vehicleId,
        rating: rating,
        comments: feedbackController.text.trim(),
        serviceDate: actualServiceDate ?? DateTime.now(),
      );

      await _feedbackRepository.createFeedback(feedback);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Thank you for your feedback!"),
          backgroundColor: Colors.green,
        ),
      );

      // Reset form
      setState(() {
        rating = 0;
        feedbackController.clear();
      });

      // Navigate back
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error submitting feedback: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Rate Your Experience',
        showTitle: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: AppColors.neutral400,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Service is Complete! 🚗✅",
              style: AppTextStyles.textLgSemibold.copyWith(
                color: AppColors.neutral100,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your vehicle service is now complete. Thank you for choosing us!",
              style: AppTextStyles.textMdRegular.copyWith(
                color: AppColors.neutral150,
              ),
            ),
            const SizedBox(height: 12),
            CostEstimateDescription(
              servicecenterName: serviceCenterName ?? 'Service Center',
              vehicleRegNo: '', // Empty string since we're not showing it
              appointmentDate: actualServiceDate?.toString() ?? '',
              serviceCenterId: widget.serviceCenterId?.toString() ?? '',
              services: const [''],
            ),
            const SizedBox(height: 20),
            // Service Center Selection Dropdown
            Text(
              "Select Service Center",
              style: AppTextStyles.textLgMedium.copyWith(
                color: AppColors.neutral100,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please select the service center where you received your service:",
              style: AppTextStyles.textMdRegular.copyWith(
                color: AppColors.neutral150,
              ),
            ),
            const SizedBox(height: 12),
            _isLoadingServiceCenters
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.neutral200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<ServiceCenterDTO>(
                      value: _selectedServiceCenter,
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: InputBorder.none,
                      ),
                      hint: Text(
                        'Select a service center',
                        style: AppTextStyles.textMdRegular.copyWith(
                          color: AppColors.neutral150,
                        ),
                      ),
                      items: _serviceCenters.map((ServiceCenterDTO center) {
                        return DropdownMenuItem<ServiceCenterDTO>(
                          value: center,
                          child: Text(
                            center.stationName ??
                                'Service Center ${center.stationId}',
                            style: AppTextStyles.textMdMedium.copyWith(
                              color: AppColors.neutral100,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (ServiceCenterDTO? newValue) {
                        setState(() {
                          _selectedServiceCenter = newValue;
                        });
                      },
                      dropdownColor: AppColors.neutral450,
                      style: AppTextStyles.textMdRegular.copyWith(
                        color: AppColors.neutral100,
                      ),
                    ),
                  ),
            // Show selected service center address if available
            if (_selectedServiceCenter != null &&
                _selectedServiceCenter!.address != null &&
                _selectedServiceCenter!.address!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Address: ${_selectedServiceCenter!.address}',
                  style: AppTextStyles.textSmRegular.copyWith(
                    color: AppColors.neutral150,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              "We hope you had a great experience! Your feedback helps us improve our service.",
              style: AppTextStyles.textMdRegular.copyWith(
                color: AppColors.neutral150,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Rate Your Experience",
              style: AppTextStyles.textLgMedium.copyWith(
                color: AppColors.neutral100,
              ),
            ),
            const SizedBox(height: 8),
            StarRating(
              onRatingChanged: (value) {
                setState(() {
                  rating = value;
                });
              },
            ),
            const SizedBox(height: 32),
            Text(
              "Tell us more about your experience...",
              style: AppTextStyles.textMdRegular.copyWith(
                color: AppColors.neutral150,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.neutral200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: feedbackController,
                maxLines: 5,
                style: TextStyle(color: AppColors.neutral100),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(8),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                label: isSubmitting ? 'Submitting...' : 'Submit Your Feedback',
                type: ButtonType.primary,
                size: ButtonSize.medium,
                onTap: isSubmitting ? null : _handleSubmitFeedback,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
