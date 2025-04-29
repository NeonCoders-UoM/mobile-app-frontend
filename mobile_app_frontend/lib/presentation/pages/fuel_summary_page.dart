import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/custom_app_bar.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/fuel_input_form.dart';
import 'package:mobile_app_frontend/presentation/components/molecules/fuel_usage_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/fuel_usage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class FuelSummaryPage extends StatefulWidget {
  const FuelSummaryPage({super.key});

  @override
  FuelSummaryPageState createState() => FuelSummaryPageState();
}

class FuelSummaryPageState extends State<FuelSummaryPage> {
  final List<FuelUsage> _fuelEntries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entries = prefs.getStringList('fuel_entries') ?? [];
      setState(() {
        _fuelEntries.addAll(
          entries.map((e) => FuelUsage.fromJson(jsonDecode(e))).toList(),
        );
      });
    } catch (e) {
      print('Error loading entries: $e');
    }
  }

  Future<void> _saveEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entries = _fuelEntries.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList('fuel_entries', entries);
    } catch (e) {
      print('Error saving entries: $e');
    }
  }

  void _addFuelUsage(FuelUsage entry) {
    setState(() {
      _fuelEntries.add(entry);
    });
    _saveEntries();
  }

  Map<String, double> _calculateMonthlySummary() {
    final Map<String, double> summary = {};
    for (var entry in _fuelEntries) {
      final monthKey = DateFormat('yyyy-MM').format(entry.date);
      summary[monthKey] = (summary[monthKey] ?? 0) + entry.amount;
    }
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    final monthlySummary = _calculateMonthlySummary();

    return Scaffold(
      backgroundColor: AppColors.neutral600,
      appBar: CustomAppBar(
        title: 'Fuel Usage Summary',
        showTitle: true,
        onBackPressed: null, // Disable back button (root screen)
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FuelInputForm(onSubmit: _addFuelUsage),
              const SizedBox(height: 24),
              Text(
                'Monthly Summary',
                style: AppTextStyles.textMdSemibold
                    .copyWith(color: AppColors.neutral100),
              ),
              const SizedBox(height: 16),
              monthlySummary.isEmpty
                  ? Center(
                      child: Text(
                        'No fuel usage recorded',
                        style: AppTextStyles.textSmRegular
                            .copyWith(color: AppColors.neutral300),
                      ),
                    )
                  : FuelUsageChart(monthlySummary: monthlySummary),
            ],
          ),
        ),
      ),
    );
  }
}
