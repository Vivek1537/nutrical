import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_plan.dart';
import '../models/grocery_item.dart';

class MealPlanService {
  static const _plansKey = 'meal_plans';
  static const _activeKey = 'active_plan_id';
  static const _groceryKey = 'grocery_list';

  // Save/load plans
  static Future<List<MealPlan>> getPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_plansKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((j) => MealPlan.fromJson(j)).toList();
  }

  static Future<void> savePlan(MealPlan plan) async {
    final plans = await getPlans();
    final idx = plans.indexWhere((p) => p.id == plan.id);
    if (idx >= 0) {
      plans[idx] = plan;
    } else {
      plans.add(plan);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_plansKey, jsonEncode(plans.map((p) => p.toJson()).toList()));
  }

  static Future<void> deletePlan(String id) async {
    final plans = await getPlans();
    plans.removeWhere((p) => p.id == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_plansKey, jsonEncode(plans.map((p) => p.toJson()).toList()));
  }

  static Future<void> setActivePlan(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeKey, id);
  }

  static Future<String?> getActivePlanId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeKey);
  }

  static Future<MealPlan?> getActivePlan() async {
    final id = await getActivePlanId();
    if (id == null) return null;
    final plans = await getPlans();
    try {
      return plans.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // Generate grocery list from plan
  static List<GroceryItem> generateGroceryList(MealPlan plan) {
    final map = <String, GroceryItem>{};
    for (final day in plan.days) {
      for (final meal in day.meals) {
        final key = meal.foodName.toLowerCase();
        if (map.containsKey(key)) {
          final existing = map[key]!;
          map[key] = GroceryItem(
            name: existing.name,
            quantity: existing.quantity + (meal.quantity * meal.servingSize),
            unit: existing.unit,
          );
        } else {
          map[key] = GroceryItem(
            name: meal.foodName,
            quantity: meal.quantity * meal.servingSize,
            unit: meal.servingUnit,
          );
        }
      }
    }
    return map.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  // Grocery list persistence
  static Future<List<GroceryItem>> getGroceryList() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_groceryKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((j) => GroceryItem.fromJson(j)).toList();
  }

  static Future<void> saveGroceryList(List<GroceryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_groceryKey, jsonEncode(items.map((i) => i.toJson()).toList()));
  }
}
