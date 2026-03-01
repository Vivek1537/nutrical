import 'dart:convert';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class ShareService {
  /// Generate a shareable daily summary text
  static Future<String> dailySummary(DateTime date, UserProfile profile) async {
    final meals = await StorageService.getMealsForDate(date);
    final water = await StorageService.getWaterForDate(date);
    final totalCal = meals.fold<double>(0, (s, m) => s + m.calories);
    final totalPro = meals.fold<double>(0, (s, m) => s + m.protein);
    final totalCarb = meals.fold<double>(0, (s, m) => s + m.carbs);
    final totalFat = meals.fold<double>(0, (s, m) => s + m.fat);

    final buf = StringBuffer();
    buf.writeln('\u{1F4CA} NutriCal Daily Summary');
    buf.writeln('${date.day}/${date.month}/${date.year}');
    buf.writeln();
    buf.writeln('\u{1F525} Calories: ${totalCal.round()} / ${profile.dailyCalorieTarget.round()} kcal');
    buf.writeln('\u{1F4AA} Protein: ${totalPro.round()}g');
    buf.writeln('\u{1F33E} Carbs: ${totalCarb.round()}g');
    buf.writeln('\u{1FAB7} Fat: ${totalFat.round()}g');
    buf.writeln('\u{1F4A7} Water: ${(water / 1000).toStringAsFixed(1)}L / ${(profile.waterTargetMl / 1000).toStringAsFixed(1)}L');
    buf.writeln();
    buf.writeln('Meals (${meals.length}):');
    for (final m in meals) {
      buf.writeln('  \u2022 ${m.foodName} (${m.mealType}) - ${m.calories.round()} kcal');
    }
    buf.writeln();
    buf.writeln('Tracked with NutriCal \u{1F34E}');
    return buf.toString();
  }

  /// Export all data as JSON
  static Future<String> exportDataJson(UserProfile profile) async {
    final now = DateTime.now();
    final allMeals = <Map<String, dynamic>>[];
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final meals = await StorageService.getMealsForDate(date);
      for (final m in meals) {
        allMeals.add({
          'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
          'foodName': m.foodName, 'mealType': m.mealType,
          'calories': m.calories, 'protein': m.protein,
          'carbs': m.carbs, 'fat': m.fat,
        });
      }
    }
    return const JsonEncoder.withIndent('  ').convert({
      'exportDate': now.toIso8601String(),
      'profile': {
        'name': profile.name, 'age': profile.age,
        'weight': profile.weightKg, 'height': profile.heightCm,
        'goal': profile.goal, 'dailyCalorieTarget': profile.dailyCalorieTarget,
      },
      'meals': allMeals,
    });
  }
}
