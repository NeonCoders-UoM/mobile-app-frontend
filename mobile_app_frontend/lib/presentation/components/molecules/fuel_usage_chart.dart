import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class FuelUsageChart extends StatelessWidget {
  final Map<String, double> monthlySummary;

  const FuelUsageChart({required this.monthlySummary, super.key});

  @override
  Widget build(BuildContext context) {
    final months = monthlySummary.keys.toList();
    final amounts = monthlySummary.values.toList();
    final maxY = amounts.isNotEmpty
        ? amounts.reduce((a, b) => a > b ? a : b) * 1.2
        : 100.0;

    return Card(
      color: AppColors.neutral500,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fuel Usage by Month',
              style: AppTextStyles.textMdSemibold
                  .copyWith(color: AppColors.neutral100),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < months.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                months[index].substring(2),
                                style: AppTextStyles.textXsmRegular,
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
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          '${value.toInt()}',
                          style: AppTextStyles.textXsmRegular,
                        ),
                      ),
                    ),
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    amounts.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: amounts[index],
                          color: AppColors.primary200,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
