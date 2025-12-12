import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app_frontend/core/theme/app_colors.dart';
import 'package:mobile_app_frontend/core/theme/app_text_styles.dart';
import 'package:mobile_app_frontend/presentation/pages/emergencyservice_page.dart';
import 'package:mobile_app_frontend/services/auth_service.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/vehicle_header.dart';
import 'package:mobile_app_frontend/presentation/components/atoms/vehicle_detail_row.dart';
import 'package:mobile_app_frontend/presentation/pages/appointment_page.dart';
import 'package:mobile_app_frontend/presentation/pages/delete_vehicle_page.dart';
import 'package:mobile_app_frontend/presentation/pages/fuel_summary_page.dart';
import 'package:mobile_app_frontend/presentation/pages/scheduled_reminders.dart';
import 'package:mobile_app_frontend/presentation/pages/service_history_page.dart';
import 'package:mobile_app_frontend/presentation/pages/edit_vehicledetails_page.dart';
import 'package:mobile_app_frontend/presentation/pages/documents_page.dart';
import 'package:mobile_app_frontend/presentation/pages/login_page.dart';
import 'package:mobile_app_frontend/presentation/pages/personal_details_page.dart';
import 'package:mobile_app_frontend/presentation/pages/notifications_page.dart';
import 'package:mobile_app_frontend/presentation/components/vehicle_switcher.dart';
import 'package:mobile_app_frontend/state/providers/vehicle_provider.dart';
import 'package:mobile_app_frontend/data/repositories/vehicle_repository.dart';
import 'package:mobile_app_frontend/core/models/vehicle.dart';
import 'package:mobile_app_frontend/core/services/local_storage.dart';

class VehicleDetailsHomePage extends StatefulWidget {
  final int customerId;
  final String token;

  const VehicleDetailsHomePage({
    Key? key,
    required this.customerId,
    required this.token,
  }) : super(key: key);

  @override
  State<VehicleDetailsHomePage> createState() => _VehicleDetailsHomePageState();
}

class _VehicleDetailsHomePageState extends State<VehicleDetailsHomePage> {
  final _authService = AuthService();
  String _customerName = '';

  @override
  void initState() {
    super.initState();
    _loadCustomerName();
    // Load vehicles using provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VehicleProvider>(context, listen: false)
          .loadVehicles(widget.customerId, widget.token);
    });
  }

  Future<void> _loadCustomerName() async {
    try {
      print('🔍 Loading customer name for ID: ${widget.customerId}');
      final customerData = await _authService.getCustomerDetails(
        customerId: widget.customerId,
        token: widget.token,
      );
      print('📦 Customer data received: $customerData');
      if (customerData != null) {
        final firstName = customerData['firstName'] ?? '';
        final lastName = customerData['lastName'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        print('👤 Full name: $fullName');
        if (mounted) {
          setState(() {
            _customerName = fullName.isNotEmpty ? fullName : 'User';
          });
          print('✅ Customer name set: $_customerName');
        }
      } else {
        print('⚠️ Customer data is null');
        if (mounted) {
          setState(() {
            _customerName = 'User';
          });
        }
      }
    } catch (e) {
      print('❌ Error loading customer name: $e');
      if (mounted) {
        setState(() {
          _customerName = 'User';
        });
      }
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.neutral300,
          title: Text(
            'Logout',
            style: AppTextStyles.textSmSemibold.copyWith(
              color: AppColors.neutral100,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: AppTextStyles.textSmRegular.copyWith(
              color: AppColors.neutral100,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: AppTextStyles.textSmMedium.copyWith(
                  color: AppColors.neutral100,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout();
              },
              child: Text(
                'Logout',
                style: AppTextStyles.textSmMedium.copyWith(
                  color: AppColors.primary300,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _performLogout() async {
    // Clear stored tokens and session data
    await LocalStorageService.clearAuthData();
    print('🗑️ Authentication data cleared during logout');

    // Navigate to login page and clear navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProvider, child) {
        final selectedVehicle = vehicleProvider.selectedVehicle;
        final isLoading = vehicleProvider.isLoading;
        final vehicles = vehicleProvider.vehicles;

        // Show loading screen while vehicles are being loaded
        if (isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.neutral400,
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
        }

        // Show message if no vehicles are available
        if (vehicles.isEmpty) {
          return Scaffold(
            backgroundColor: AppColors.neutral400,
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.directions_car_outlined,
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No vehicles found',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please add a vehicle to get started',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Show add vehicle dialog
                        showDialog(
                          context: context,
                          builder: (context) => AddVehicleDialog(
                            customerId: widget.customerId,
                            token: widget.token,
                          ),
                        );
                      },
                      child: const Text('Add Vehicle'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Show error if no vehicle is selected (shouldn't happen with our logic)
        if (selectedVehicle == null) {
          return const Scaffold(
            backgroundColor: AppColors.neutral400,
            body: Center(
              child: Text(
                'Error: No vehicle selected',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.neutral400,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // --- Modern Header Section ---
                  Container(
                    color: AppColors.neutral400,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Top Bar with Icons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Logout icon
                              _buildSquareIconButton(
                                icon: Icons.logout,
                                onTap: _showLogoutDialog,
                              ),
                              // Vehicle Switcher
                              VehicleSwitcher(
                                customerId: widget.customerId,
                                token: widget.token,
                              ),
                              Row(
                                children: [
                                  // Notification bell icon
                                  _buildSquareIconButton(
                                    icon: Icons.notifications_outlined,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              NotificationsPage(
                                            customerId: widget.customerId,
                                            token: widget.token,
                                            vehicleId:
                                                selectedVehicle.vehicleId,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  // Profile icon
                                  _buildSquareIconButton(
                                    icon: Icons.person_outline,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PersonalDetailsPage(
                                            customerId: widget.customerId,
                                            token: widget.token,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Vehicle Card
                          Container(
                            padding: const EdgeInsets.all(16),
                            // decoration: BoxDecoration(
                            //   color: AppColors.neutral300.withOpacity(0.4),
                            //   borderRadius: BorderRadius.circular(24),
                            //   border: Border.all(
                            //     color: AppColors.neutral200.withOpacity(0.2),
                            //     width: 1.5,
                            //   ),
                            //   boxShadow: [
                            //     BoxShadow(
                            //       color: Colors.black.withOpacity(0.1),
                            //       blurRadius: 20,
                            //       offset: const Offset(0, 10),
                            //     ),
                            //   ],
                            // ),
                            child: Column(
                              children: [
                                // Customer Name - Always show with fallback
                                Text(
                                  _customerName.isEmpty
                                      ? 'Hello, User!'
                                      : 'Hello, $_customerName!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.neutral200,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Vehicle Name Header
                                Text(
                                  selectedVehicle.registrationNumber,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.neutral100,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                // const SizedBox(height: 4),
                                // Vehicle Image
                                ClipRect(
                                  child: Align(
                                    alignment: Alignment.center,
                                    heightFactor: 0.75,
                                    child: SizedBox(
                                      height: 250,
                                      child: Image.asset(
                                        'assets/images/homenew2.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                                // const SizedBox(height: 8),
                                // Vehicle Details Grid
                                _buildDetailGrid(selectedVehicle),

                                // Quick Actions Section
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.neutral300
                                            .withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColors.neutral200
                                              .withOpacity(0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.dashboard_customize_rounded,
                                        color: AppColors.neutral100,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Quick Actions',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.neutral100,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          'Manage your vehicle',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.neutral200,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Grid of Feature Cards
                                GridView.count(
                                  crossAxisCount: 4,
                                  mainAxisSpacing: 6,
                                  crossAxisSpacing: 6,
                                  childAspectRatio: 0.95,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  children: [
                                    _buildFeatureCard(
                                      context,
                                      "assets/icons/documents.svg",
                                      "Documents",
                                      DocumentsPage(
                                        customerId: widget.customerId,
                                        vehicleId: selectedVehicle.vehicleId,
                                      ),
                                    ),
                                    _buildFeatureCard(
                                      context,
                                      "assets/icons/appointments.svg",
                                      "Appointment",
                                      AppointmentPage(
                                        customerId: widget.customerId,
                                        vehicleId: selectedVehicle.vehicleId,
                                        token: widget.token,
                                      ),
                                    ),
                                    _buildFeatureCard(
                                      context,
                                      "assets/icons/fuel_efficiency.svg",
                                      "Fuel",
                                      FuelSummaryPage(
                                        vehicleId: selectedVehicle.vehicleId,
                                        token: widget.token,
                                      ),
                                    ),
                                    _buildFeatureCard(
                                      context,
                                      "assets/icons/service_history.svg",
                                      "Service",
                                      ServiceHistoryPage(
                                        vehicleId: selectedVehicle.vehicleId,
                                        vehicleName: selectedVehicle.model,
                                        vehicleRegistration:
                                            selectedVehicle.registrationNumber,
                                        token: widget.token,
                                        customerId: widget.customerId,
                                      ),
                                    ),
                                    _buildFeatureCard(
                                      context,
                                      "assets/icons/set_reminders.svg",
                                      "Reminders",
                                      RemindersPage(
                                        vehicleId: selectedVehicle.vehicleId,
                                        token: widget.token,
                                        customerId: widget.customerId,
                                      ),
                                    ),
                                    _buildFeatureCard(
                                      context,
                                      "assets/icons/emergency.svg",
                                      "Emergency",
                                      EmergencyservicePage(token: widget.token),
                                    ),
                                    _buildFeatureCard(
                                      context,
                                      "assets/icons/edit.svg",
                                      "Edit",
                                      EditVehicledetailsPage(
                                        customerId: widget.customerId,
                                        vehicleId: selectedVehicle.vehicleId,
                                        token: widget.token,
                                      ),
                                    ),
                                    _buildFeatureCard(
                                      context,
                                      "assets/icons/delete.svg",
                                      "Delete",
                                      DeleteVehiclePage(
                                        customerId: widget.customerId,
                                        vehicleId: selectedVehicle.vehicleId,
                                        token: widget.token,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSquareIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.neutral300.withOpacity(0.6),
              AppColors.neutral300.withOpacity(0.35),
            ],
          ),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.neutral200.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: AppColors.neutral100,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildDetailGrid(vehicle) {
    final details = [
      {
        'label': 'Brand',
        'value': vehicle.brand,
        'icon': Icons.business_outlined
      },
      {
        'label': 'Model',
        'value': vehicle.model,
        'icon': Icons.directions_car_outlined
      },
      {
        'label': 'Year',
        'value': vehicle.year.toString(),
        'icon': Icons.calendar_today_outlined
      },
      {
        'label': 'Fuel',
        'value': vehicle.fuel,
        'icon': Icons.local_gas_station_outlined
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary200,
            AppColors.primary300,
          ],
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.neutral200.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < details.length; i++) ...[
            Expanded(
              child: _buildDetailItem(
                details[i]['label'] as String,
                details[i]['value'] as String,
                details[i]['icon'] as IconData,
              ),
            ),
            if (i < details.length - 1)
              Container(
                width: 1,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.neutral100.withOpacity(0.0),
                      AppColors.neutral100.withOpacity(0.3),
                      AppColors.neutral100.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.neutral100.withOpacity(0.8),
          size: 20,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: AppColors.neutral100,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.neutral100,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String assetPath,
    String label,
    Widget destinationScreen,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationScreen),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.neutral300.withOpacity(0.6),
                  AppColors.neutral300.withOpacity(0.35),
                ],
              ),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.neutral200.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SvgPicture.asset(
              assetPath,
              height: 28,
              color: AppColors.neutral100,
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.neutral100,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _iconWithLabel(BuildContext context, String assetPath,
      String label, Widget destinationScreen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destinationScreen),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            assetPath,
            height: 48,
            color: AppColors.neutral100,
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.textXsmRegular.copyWith(
                color: AppColors.neutral100,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
