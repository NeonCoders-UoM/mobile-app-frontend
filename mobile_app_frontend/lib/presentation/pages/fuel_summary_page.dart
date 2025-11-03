import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/data/models/fuel_efficiency_model.dart';
import 'package:mobile_app_frontend/data/repositories/fuel_efficiency_repository.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/fuel_input_form.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/fuel_usage_chart.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/monthly_fuel_usage_chart.dart';
import '../../../core/models/fuel_usage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class FuelSummaryPage extends StatefulWidget {
  final int vehicleId;
  final String token;

  const FuelSummaryPage({
    super.key,
    required this.vehicleId,
    required this.token,
  });

  @override
  FuelSummaryPageState createState() => FuelSummaryPageState();
}

class FuelSummaryPageState extends State<FuelSummaryPage> {
  final List<FuelEfficiencyModel> _fuelEntries = [];
  final FuelEfficiencyRepository _repository = FuelEfficiencyRepository();
  bool _isLoading = false;
  bool _isBackendConnected = false;
  String? _errorMessage;
  FuelEfficiencySummaryModel? _summary;
  List<MonthlyFuelSummaryModel> _monthlyChartData = [];
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _testBackendConnection();
  }

  Future<void> _testBackendConnection() async {
    final isConnected = await _repository.testConnection(token: widget.token);
    setState(() {
      _isBackendConnected = isConnected;
    });
  }

  Future<void> _loadEntries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use vehicle ID and token from widget parameters
      final records = await _repository.getFuelRecords(widget.vehicleId,
          token: widget.token);
      final summary = await _repository.getFuelSummary(
        widget.vehicleId,
        year: _selectedYear,
        token: widget.token,
      );
      final monthlyData = await _repository.getMonthlyChartData(
          widget.vehicleId, _selectedYear,
          token: widget.token);

      setState(() {
        _fuelEntries.clear();
        _fuelEntries.addAll(records);
        _summary = summary;
        _monthlyChartData = monthlyData;
        _isLoading = false;
      });

      print(
          '✅ Loaded ${records.length} fuel records and ${monthlyData.length} monthly data points');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load fuel records: $e';
      });
      print('❌ Error loading fuel records: $e');
    }
  }

  Future<void> _addFuelUsage(FuelUsage entry) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Convert legacy FuelUsage to FuelEfficiencyModel
      final fuelRecord = FuelEfficiencyModel(
        vehicleId: widget.vehicleId,
        date: entry.date, // Updated to use 'date' field to match backend DTO
        fuelAmount: entry.amount,
        fuelType: 'Petrol', // Default type, could be made selectable
      );

      final success =
          await _repository.addFuelRecord(fuelRecord, token: widget.token);

      if (success) {
        // Add small delay to ensure database commit
        await Future.delayed(const Duration(milliseconds: 500));

        // Reload data to get updated records
        await _loadEntries();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fuel record added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // If API failed, add to local storage (fallback already handled in repository)
        setState(() {
          _fuelEntries.add(fuelRecord);
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fuel record saved locally (backend unavailable)'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding fuel record: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Map<String, double> _calculateMonthlySummary() {
    return _repository.calculateMonthlySummary(_fuelEntries);
  }

  Widget _buildSummaryCards() {
    if (_summary == null) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Fuel',
                '${_summary!.totalFuelAmount.toStringAsFixed(1)} L',
                Icons.local_gas_station,
                AppColors.primary200,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Records',
                _summary!.totalRecords.toString(),
                Icons.list,
                AppColors.primary300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Avg Monthly',
                '${_summary!.averageMonthlyFuel.toStringAsFixed(1)}L',
                Icons.speed,
                AppColors.primary100,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'This Year',
                '${_summary!.totalFuelThisYear.toStringAsFixed(1)}L',
                Icons.local_gas_station,
                AppColors.neutral300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral500,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.textSmRegular.copyWith(
                  color: AppColors.neutral200,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.textLgSemibold.copyWith(
              color: AppColors.neutral100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector() {
    final currentYear = DateTime.now().year;
    final years = List.generate(5, (index) => currentYear - index);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(
            'Year:',
            style: AppTextStyles.textSmSemibold.copyWith(
              color: AppColors.neutral200,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: years.map((year) {
                  final isSelected = year == _selectedYear;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _changeYear(year),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary200
                              : AppColors.neutral500,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary200
                                : AppColors.neutral300,
                          ),
                        ),
                        child: Text(
                          year.toString(),
                          style: AppTextStyles.textSmRegular.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.neutral200,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeYear(int year) async {
    if (year == _selectedYear) return;

    setState(() {
      _selectedYear = year;
      _isLoading = true;
    });

    try {
      final summary = await _repository.getFuelSummary(
        widget.vehicleId,
        year: year,
        token: widget.token,
      );
      final monthlyData = await _repository.getMonthlyChartData(
        widget.vehicleId,
        year,
        token: widget.token,
      );

      setState(() {
        _summary = summary;
        _monthlyChartData = monthlyData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load data for year $year: $e';
      });
    }
  }

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Monthly Fuel Usage',
              style: AppTextStyles.textMdSemibold
                  .copyWith(color: AppColors.neutral100),
            ),
            const Spacer(),
            Text(
              _selectedYear.toString(),
              style: AppTextStyles.textSmRegular
                  .copyWith(color: AppColors.neutral300),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildChart(),
      ],
    );
  }

  Widget _buildChart() {
    // If we have backend monthly data, use the enhanced chart
    if (_monthlyChartData.isNotEmpty) {
      return MonthlyFuelUsageChart(
        monthlyData: _monthlyChartData,
        title: 'Monthly Fuel Usage (${_selectedYear})',
      );
    }

    // Fallback to legacy chart for local data
    final monthlySummary = _calculateMonthlySummary();
    if (monthlySummary.isEmpty) {
      return _buildEmptyChartState();
    }

    return FuelUsageChart(monthlySummary: monthlySummary);
  }

  Widget _buildEmptyChartState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.neutral500,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral400),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_gas_station_outlined,
            size: 48,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: 16),
          Text(
            'No fuel usage data for $_selectedYear',
            style: AppTextStyles.textMdSemibold
                .copyWith(color: AppColors.neutral200),
          ),
          const SizedBox(height: 8),
          Text(
            'Add fuel records to see monthly trends',
            style: AppTextStyles.textSmRegular
                .copyWith(color: AppColors.neutral300),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral600,
      appBar: CustomAppBar(
        title: 'Fuel Usage Summary',
        showTitle: true,
        onBackPressed: null, // Disable back button (root screen)
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FuelInputForm(onSubmit: _addFuelUsage),
                    const SizedBox(height: 24),
                    _buildSummaryCards(),
                    _buildYearSelector(),
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTextStyles.textSmRegular
                                    .copyWith(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _buildChartSection(),
                  ],
                ),
              ),
            ),
    );
  }
}
