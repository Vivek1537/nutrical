import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/meal_entry.dart';
import '../models/water_entry.dart';

class StorageService {
  static const _profileKey = 'user_profile';
  static const _mealsKey = 'meals';
  static const _waterKey = 'water';
  static const _onboardedKey = 'onboarded';

  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
    await prefs.setBool(_onboardedKey, true);
  }

  static Future<UserProfile?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_profileKey);
    if (data == null) return null;
    return UserProfile.fromJson(jsonDecode(data));
  }

  static Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardedKey) ?? false;
  }

  static Future<void> saveMeals(List<MealEntry> meals) async {
    final prefs = await SharedPreferences.getInstance();
    final data = meals.map((m) => m.toJson()).toList();
    await prefs.setString(_mealsKey, jsonEncode(data));
  }

  static Future<List<MealEntry>> getMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_mealsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => MealEntry.fromJson(e)).toList();
  }

  static Future<List<MealEntry>> getMealsForDate(DateTime date) async {
    final meals = await getMeals();
    return meals.where((m) =>
      m.loggedAt.year == date.year &&
      m.loggedAt.month == date.month &&
      m.loggedAt.day == date.day
    ).toList();
  }

  static Future<void> addMeal(MealEntry meal) async {
    final meals = await getMeals();
    meals.add(meal);
    await saveMeals(meals);
  }

  static Future<void> deleteMeal(String id) async {
    final meals = await getMeals();
    meals.removeWhere((m) => m.id == id);
    await saveMeals(meals);
  }

  static Future<void> saveWaterEntries(List<WaterEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final data = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_waterKey, jsonEncode(data));
  }

  static Future<List<WaterEntry>> getWaterEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_waterKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => WaterEntry.fromJson(e)).toList();
  }

  static Future<double> getWaterForDate(DateTime date) async {
    final entries = await getWaterEntries();
    return entries.where((e) =>
      e.loggedAt.year == date.year &&
      e.loggedAt.month == date.month &&
      e.loggedAt.day == date.day
    ).fold<double>(0.0, (sum, e) => sum + e.amountMl);
  }

  static Future<void> addWater(WaterEntry entry) async {
    final entries = await getWaterEntries();
    entries.add(entry);
    await saveWaterEntries(entries);
  }
}

