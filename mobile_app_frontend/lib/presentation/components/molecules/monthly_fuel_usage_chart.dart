import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/fuel_efficiency_model.dart';

class MonthlyFuelUsageChart extends StatefulWidget {
  final List<MonthlyFuelSummaryModel> monthlyData;
  final String title;

  const MonthlyFuelUsageChart({
    required this.monthlyData,
    this.title = 'Monthly Fuel Usage',
    super.key,
  });

  @override
  State<MonthlyFuelUsageChart> createState() => _MonthlyFuelUsageChartState();
}

class _MonthlyFuelUsageChartState extends State<MonthlyFuelUsageChart> {

  @override
  Widget build(BuildContext context) {
    if (widget.monthlyData.isEmpty) {
      return _buildEmptyState();
    }

    // Sort data by month
    final sortedData = List<MonthlyFuelSummaryModel>.from(widget.monthlyData)
      ..sort((a, b) => a.month.compareTo(b.month));

    return Card(
      color: AppColors.neutral500,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: _buildChart(sortedData),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(sortedData),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.local_gas_station,
          color: AppColors.primary200,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          widget.title,
          style: AppTextStyles.textMdSemibold
              .copyWith(color: AppColors.neutral100),
        ),
      ],
    );
  }

  Widget _buildChart(List<MonthlyFuelSummaryModel> sortedData) {
    final values = _getValuesForSelectedView(sortedData);

    // Ensure we have valid data
    if (values.isEmpty || values.every((v) => v == 0)) {
      return _buildEmptyChart();
    }

    final maxY = values.isNotEmpty
        ? values.reduce((a, b) => a > b ? a : b) * 1.2
        : 100.0;

    // Ensure maxY is valid
    final chartMaxY = maxY > 0 ? maxY : 100.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: chartMaxY,
        minY: 0,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedData.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      sortedData[index].displayMonth,
                      style: AppTextStyles.textXsmRegular
                          .copyWith(color: AppColors.neutral200),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) => Text(
                _formatYAxisValue(value),
                style: AppTextStyles.textXsmRegular
                    .copyWith(color: AppColors.neutral200),
              ),
            ),
          ),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: AppColors.neutral300, width: 1),
            left: BorderSide(color: AppColors.neutral300, width: 1),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: chartMaxY / 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.neutral400.withOpacity(0.5),
            strokeWidth: 0.5,
          ),
          drawVerticalLine: false,
        ),
        barGroups: _buildBarGroups(sortedData, values),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppColors.neutral400,
            tooltipBorder: BorderSide(color: AppColors.neutral300),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex < sortedData.length) {
                final data = sortedData[groupIndex];
                return BarTooltipItem(
                  _buildTooltipText(data),
                  AppTextStyles.textSmRegular.copyWith(
                    color: AppColors.neutral100,
                  ),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: AppColors.neutral500,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral400),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: 16),
            Text(
              'No fuel data available',
              style: AppTextStyles.textLgMedium.copyWith(
                color: AppColors.neutral200,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add fuel records to see your usage trends',
              style: AppTextStyles.textSmRegular.copyWith(
                color: AppColors.neutral300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
      List<MonthlyFuelSummaryModel> sortedData, List<double> values) {
    return List.generate(
      sortedData.length,
      (index) {
        final value = index < values.length ? values[index] : 0.0;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: value > 0
                  ? value
                  : 0.1, // Ensure minimum height for visibility
              color: _getBarColor(index, sortedData.length),
              width: _calculateBarWidth(sortedData.length),
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  _getBarColor(index, sortedData.length),
                  _getBarColor(index, sortedData.length).withOpacity(0.7),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<double> _getValuesForSelectedView(List<MonthlyFuelSummaryModel> data) {
    // Only fuel amount is available since cost and efficiency were removed
    return data.map((d) => d.totalFuelAmount).toList();
  }

  String _formatYAxisValue(double value) {
    // Only fuel amount formatting is needed since cost and efficiency were removed
    return '${value.toInt()}L';
  }

  Color _getBarColor(int index, int total) {
    final colors = [
      AppColors.primary200,
      AppColors.primary100,
      AppColors.primary300,
      AppColors.states['ok']!,
      AppColors.states['upcoming']!,
    ];
    return colors[index % colors.length];
  }

  double _calculateBarWidth(int dataLength) {
    if (dataLength <= 6) return 24;
    if (dataLength <= 9) return 20;
    return 16;
  }

  String _buildTooltipText(MonthlyFuelSummaryModel data) {
    // Only fuel amount tooltip since cost and efficiency were removed
    return '${data.monthName}\nFuel: ${data.totalFuelAmount.toStringAsFixed(1)}L\nRecords: ${data.recordCount}';
  }

  Widget _buildSummaryRow(List<MonthlyFuelSummaryModel> data) {
    final totalFuel = data.fold(0.0, (sum, d) => sum + d.totalFuelAmount);
    final totalRecords = data.fold(0, (sum, d) => sum + d.recordCount);

    return Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            'Total Fuel',
            '${totalFuel.toStringAsFixed(1)}L',
            Icons.local_gas_station,
          ),
        ),
        Expanded(
          child: _buildSummaryItem(
            'Records',
            totalRecords.toString(),
            Icons.receipt,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.neutral200, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.textSmSemibold
              .copyWith(color: AppColors.neutral100),
        ),
        Text(
          label,
          style: AppTextStyles.textXsmRegular
              .copyWith(color: AppColors.neutral300),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      color: AppColors.neutral500,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.local_gas_station_outlined,
              size: 48,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: 16),
            Text(
              'No Fuel Data Available',
              style: AppTextStyles.textMdSemibold
                  .copyWith(color: AppColors.neutral200),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding fuel records to see monthly usage trends',
              style: AppTextStyles.textSmRegular
                  .copyWith(color: AppColors.neutral300),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
