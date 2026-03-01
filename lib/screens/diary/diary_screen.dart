import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_state.dart';
import '../../utils/constants.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(title: const Text('Food Diary')),
          body: state.todayMeals.isEmpty
            ? Center(child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.book, size: 64, color: AppTheme.textSecondary.withAlpha(100)),
                  const SizedBox(height: 12),
                  Text('No meals logged today', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                ],
              ))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: AppConstants.mealTypes.map((type) {
                  final meals = state.getMealsByType(type);
                  if (meals.isEmpty) return const SizedBox();
                  final totalCal = meals.fold(0.0, (sum, m) => sum + m.calories);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(type, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('${totalCal.round()} kcal', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const Divider(),
                          ...meals.map((meal) => Dismissible(
                            key: Key(meal.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              color: AppTheme.error,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => context.read<AppState>().deleteMeal(meal.id),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(meal.foodName, style: const TextStyle(fontWeight: FontWeight.w500)),
                                        Text('${meal.quantity}x ${meal.servingSize.round()}${meal.servingUnit}',
                                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('${meal.calories.round()} kcal', style: const TextStyle(fontWeight: FontWeight.w600)),
                                      Text('P:${meal.protein.round()} C:${meal.carbs.round()} F:${meal.fat.round()}',
                                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
        );
      },
    );
  }
}
