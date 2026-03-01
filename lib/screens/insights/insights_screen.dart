import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../config/theme.dart';
import '../../providers/app_state.dart';
import '../../services/storage_service.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});
  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  List<double> _weekCalories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWeekData();
  }

  Future<void> _loadWeekData() async {
    final now = DateTime.now();
    final cals = <double>[];
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final meals = await StorageService.getMealsForDate(date);
      cals.add(meals.fold<double>(0, (sum, m) => sum + m.calories));
    }
    if (mounted) setState(() { _weekCalories = cals; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final profile = state.profile;
        if (profile == null) return const SizedBox();
        final pro = state.todayProtein;
        final carb = state.todayCarbs;
        final fat = state.todayFat;
        final totalMacroG = pro + carb + fat;

        return Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(title: const Text('Insights')),
          body: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMacroPieCard(totalMacroG, pro, carb, fat),
                    const SizedBox(height: 16),
                    _buildWeeklyBarCard(profile.dailyCalorieTarget),
                    const SizedBox(height: 16),
                    _buildSummaryCard(state),
                    const SizedBox(height: 16),
                    _buildTipsCard(state),
                  ],
                ),
              ),
        );
      },
    );
  }

  Widget _buildMacroPieCard(double total, double pro, double carb, double fat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Today's Macro Split", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: total == 0
                ? Center(child: Text('Log food to see macros', style: TextStyle(color: AppTheme.textSecondary)))
                : Row(
                    children: [
                      Expanded(
                        child: PieChart(PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(value: pro, color: const Color(0xFF42A5F5), title: '${(pro / total * 100).round()}%', titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white), radius: 50),
                            PieChartSectionData(value: carb, color: const Color(0xFFFFA726), title: '${(carb / total * 100).round()}%', titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white), radius: 50),
                            PieChartSectionData(value: fat, color: const Color(0xFFEF5350), title: '${(fat / total * 100).round()}%', titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white), radius: 50),
                          ],
                        )),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _legendItem('Protein', '${pro.round()}g', const Color(0xFF42A5F5)),
                          const SizedBox(height: 8),
                          _legendItem('Carbs', '${carb.round()}g', const Color(0xFFFFA726)),
                          const SizedBox(height: 8),
                          _legendItem('Fat', '${fat.round()}g', const Color(0xFFEF5350)),
                        ],
                      ),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyBarCard(double target) {
    final maxY = _weekCalories.isEmpty ? 2500.0 : (_weekCalories.reduce((a, b) => a > b ? a : b) * 1.3).clamp(500.0, 5000.0).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weekly Calories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, gi, rod, ri) => BarTooltipItem('${rod.toY.round()} kcal', const TextStyle(color: Colors.white, fontSize: 12)))),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      final dayIndex = DateTime.now().subtract(Duration(days: 6 - value.toInt())).weekday - 1;
                      return SideTitleWidget(meta: meta, child: Text(days[dayIndex], style: const TextStyle(fontSize: 11)));
                    })),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text('${value.toInt()}', style: const TextStyle(fontSize: 10)))),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true, drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withAlpha(30), strokeWidth: 1)),
                barGroups: List.generate(7, (i) => BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: i < _weekCalories.length ? _weekCalories[i] : 0,
                    color: i == 6 ? AppTheme.primary : AppTheme.primary.withAlpha(150),
                    width: 20,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ])),
              )),
            ),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 12, height: 3, color: AppTheme.accent),
              const SizedBox(width: 4),
              Text('Target: ${target.round()} kcal', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(AppState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Today's Summary", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _statRow('Total Calories', '${state.todayCalories.round()} kcal'),
            _statRow('Meals Logged', '${state.todayMeals.length}'),
            _statRow('Water', '${(state.todayWater / 1000).toStringAsFixed(1)} L'),
            _statRow('Remaining', '${state.remainingCalories.round()} kcal'),
            if (_weekCalories.isNotEmpty) ...[
              const Divider(),
              _statRow('7-Day Avg', '${(_weekCalories.reduce((a, b) => a + b) / 7).round()} kcal'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard(AppState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.lightbulb, color: AppTheme.accent, size: 20),
              const SizedBox(width: 8),
              const Text('Tips', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.accent.withAlpha(20), borderRadius: BorderRadius.circular(10)),
              child: Text(_getTip(state), style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  String _getTip(AppState state) {
    final profile = state.profile!;
    if (state.todayMeals.isEmpty) return 'Start logging your meals to get personalized insights!';
    if (state.todayProtein < profile.proteinTarget * 0.5) return 'Your protein intake is low today. Try adding eggs, paneer, dal, or chicken.';
    if (state.todayCalories > profile.dailyCalorieTarget) return "You've exceeded your calorie target. Consider a light dinner or a walk!";
    if (state.todayWater < profile.waterTargetMl * 0.3) return "Don't forget to stay hydrated! You're behind on your water goal.";
    return 'Great job tracking your meals! Consistency is key to reaching your goals.';
  }

  Widget _legendItem(String label, String value, Color color) => Row(children: [
    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 6),
    Text('$label ', style: const TextStyle(fontSize: 13)),
    Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
  ]);

  Widget _statRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(color: AppTheme.textSecondary)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]),
  );
}
