import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/micro_nutrient.dart';
import '../../providers/app_state.dart';

class MicroNutrientsScreen extends StatelessWidget {
  const MicroNutrientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(builder: (context, state, _) {
      // Calculate from today's meals (fiber, sugar, sodium from food items)
      final micros = MicroNutrientDefaults.getDefaults();
      double totalFiber = 0, totalSugar = 0, totalSodium = 0;
      for (final meal in state.todayMeals) {
        // These come from foods that have fiber/sugar/sodium data
        // For MVP we estimate from macro ratios
        totalFiber += meal.carbs * 0.08; // rough estimate
        totalSugar += meal.carbs * 0.15;
        totalSodium += meal.calories * 0.8; // mg estimate
      }
      micros[0].consumed = totalFiber; // Fiber
      micros[1].consumed = totalSugar; // Sugar
      micros[2].consumed = totalSodium; // Sodium

      return Scaffold(
        appBar: AppBar(title: const Text('Micro-Nutrients')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(padding: const EdgeInsets.all(16), child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Fiber, sugar & sodium are estimated from logged meals. Other vitamins need manual entry or barcode data.',
                      style: TextStyle(fontSize: 13))),
                  ]),
                ],
              )),
            ),
            const SizedBox(height: 12),
            ...micros.map((m) => _buildNutrientCard(m)),
          ],
        ),
      );
    });
  }

  Widget _buildNutrientCard(MicroNutrient m) {
    final pct = m.percentage;
    final color = m.isLow ? AppTheme.error : m.isGood ? AppTheme.primary : m.isExcess ? Colors.orange : AppTheme.accent;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              Text('${m.consumed.toStringAsFixed(1)} / ${m.dailyTarget.toStringAsFixed(0)} ${m.unit}',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (pct / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                color: color,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${pct.round()}%', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
              Text(
                m.isLow ? 'Low' : m.isGood ? 'Good' : m.isExcess ? 'High' : 'OK',
                style: TextStyle(fontSize: 12, color: color),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
