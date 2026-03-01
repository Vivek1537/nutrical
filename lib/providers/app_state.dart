import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/meal_entry.dart';
import '../models/water_entry.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  UserProfile? _profile;
  List<MealEntry> _todayMeals = [];
  double _todayWater = 0;
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  UserProfile? get profile => _profile;
  List<MealEntry> get todayMeals => _todayMeals;
  double get todayWater => _todayWater;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;

  double get todayCalories => _todayMeals.fold(0, (sum, m) => sum + m.calories);
  double get todayProtein => _todayMeals.fold(0, (sum, m) => sum + m.protein);
  double get todayCarbs => _todayMeals.fold(0, (sum, m) => sum + m.carbs);
  double get todayFat => _todayMeals.fold(0, (sum, m) => sum + m.fat);
  double get remainingCalories => (_profile?.dailyCalorieTarget ?? 2000) - todayCalories;

  Future<void> init() async {
    _profile = await StorageService.getProfile();
    await loadDateData(_selectedDate);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadDateData(DateTime date) async {
    _selectedDate = date;
    _todayMeals = await StorageService.getMealsForDate(date);
    _todayWater = await StorageService.getWaterForDate(date);
    notifyListeners();
  }

  Future<void> setProfile(UserProfile profile) async {
    _profile = profile;
    await StorageService.saveProfile(profile);
    notifyListeners();
  }

  Future<void> addMeal(MealEntry meal) async {
    await StorageService.addMeal(meal);
    await loadDateData(_selectedDate);
  }

  Future<void> deleteMeal(String id) async {
    await StorageService.deleteMeal(id);
    await loadDateData(_selectedDate);
  }

  Future<void> addWater(double amountMl) async {
    final entry = WaterEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amountMl: amountMl,
      loggedAt: DateTime.now(),
    );
    await StorageService.addWater(entry);
    _todayWater = await StorageService.getWaterForDate(_selectedDate);
    notifyListeners();
  }

  List<MealEntry> getMealsByType(String type) {
    return _todayMeals.where((m) => m.mealType == type).toList();
  }
}
