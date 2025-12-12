import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/vehicle.dart';
import '../../core/theme/app_colors.dart';
import '../../state/providers/vehicle_provider.dart';
import '../pages/add_vehicledeails_page.dart';

class VehicleSwitcher extends StatelessWidget {
  final int customerId;
  final String token;
  const VehicleSwitcher(
      {Key? key, required this.customerId, required this.token})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<VehicleProvider>(
      builder: (context, vehicleProvider, child) {
        final vehicles = vehicleProvider.vehicles;
        final selectedVehicle = vehicleProvider.selectedVehicle;
        final isLoading = vehicleProvider.isLoading;

        // Show loading indicator if vehicles are being loaded
        if (isLoading) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }

        // Show placeholder if no vehicles are available
        if (vehicles.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'No vehicles',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          );
        }

        return DropdownButton<Vehicle?>(
          value: selectedVehicle,
          underline: Container(),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          dropdownColor: Colors.grey[900],
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          items: [
            ...vehicles.map((vehicle) => DropdownMenuItem<Vehicle?>(
                  value: vehicle,
                  child: Text(vehicle.registrationNumber,
                      style: const TextStyle(color: Colors.white)),
                )),
            const DropdownMenuItem<Vehicle?>(
              value: null,
              child: Row(
                children: [
                  Icon(Icons.add, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Add Vehicle', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
          onChanged: (vehicle) async {
            if (vehicle == null) {
              // Add Vehicle selected
              await showDialog(
                context: context,
                builder: (context) =>
                    AddVehicleDialog(customerId: customerId, token: token),
              );
            } else {
              vehicleProvider.selectVehicle(vehicle);
            }
          },
        );
      },
    );
  }
}

class AddVehicleDialog extends StatefulWidget {
  final int customerId;
  final String token;
  const AddVehicleDialog(
      {Key? key, required this.customerId, required this.token})
      : super(key: key);

  @override
  State<AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<AddVehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'registrationNumber': '',
    'brand': '',
    'model': '',
    'chassisNumber': '',
    'mileage': 0,
    'fuel': '',
    'year': 0,
  };
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.neutral450,
              AppColors.neutral450.withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary200,
                      AppColors.primary300,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.directions_car,
                        size: 32,
                        color: AppColors.neutral100,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add New Vehicle',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral100,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fill in the vehicle details',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.neutral100.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),

              // Form content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModernTextField(
                        label: 'Registration Number',
                        icon: Icons.pin,
                        onSaved: (v) =>
                            _formData['registrationNumber'] = v ?? '',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        label: 'Brand',
                        icon: Icons.business,
                        onSaved: (v) => _formData['brand'] = v ?? '',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        label: 'Model',
                        icon: Icons.drive_eta,
                        onSaved: (v) => _formData['model'] = v ?? '',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        label: 'Chassis Number',
                        icon: Icons.numbers,
                        onSaved: (v) => _formData['chassisNumber'] = v ?? '',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        label: 'Mileage',
                        icon: Icons.speed,
                        keyboardType: TextInputType.number,
                        onSaved: (v) =>
                            _formData['mileage'] = int.tryParse(v ?? '0') ?? 0,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        label: 'Fuel Type',
                        icon: Icons.local_gas_station,
                        onSaved: (v) => _formData['fuel'] = v ?? '',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        label: 'Year',
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        onSaved: (v) =>
                            _formData['year'] = int.tryParse(v ?? '0') ?? 0,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.red.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _loading
                                    ? null
                                    : () => Navigator.of(context).pop(),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.neutral400.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          AppColors.neutral300.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: AppColors.neutral100,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _loading
                                    ? null
                                    : () async {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          _formKey.currentState?.save();
                                          setState(() {
                                            _loading = true;
                                            _error = null;
                                          });
                                          try {
                                            await Provider.of<VehicleProvider>(
                                                    context,
                                                    listen: false)
                                                .addVehicle(widget.customerId,
                                                    _formData, widget.token);
                                            Navigator.of(context).pop();
                                          } catch (e) {
                                            setState(() {
                                              _error = e.toString();
                                              _loading = false;
                                            });
                                          }
                                        }
                                      },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primary200,
                                        AppColors.primary300,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary200
                                            .withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: _loading
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                AppColors.neutral100,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            'Add Vehicle',
                                            style: TextStyle(
                                              color: AppColors.neutral100,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
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
  }

  Widget _buildModernTextField({
    required String label,
    required IconData icon,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral400.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neutral300.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        keyboardType: keyboardType,
        onSaved: onSaved,
        validator: validator,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white, fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.white, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          floatingLabelStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
