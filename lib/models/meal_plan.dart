import 'food_item.dart';

class PlannedMeal {
  final String id;
  final String foodId;
  final String foodName;
  final String mealType; // Breakfast, Lunch, etc.
  final double quantity;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double servingSize;
  final String servingUnit;

  PlannedMeal({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.mealType,
    required this.quantity,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
    required this.servingUnit,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'foodId': foodId, 'foodName': foodName,
    'mealType': mealType, 'quantity': quantity,
    'calories': calories, 'protein': protein,
    'carbs': carbs, 'fat': fat,
    'servingSize': servingSize, 'servingUnit': servingUnit,
  };

  factory PlannedMeal.fromJson(Map<String, dynamic> j) => PlannedMeal(
    id: j['id'], foodId: j['foodId'], foodName: j['foodName'],
    mealType: j['mealType'], quantity: (j['quantity'] as num).toDouble(),
    calories: (j['calories'] as num).toDouble(),
    protein: (j['protein'] as num).toDouble(),
    carbs: (j['carbs'] as num).toDouble(),
    fat: (j['fat'] as num).toDouble(),
    servingSize: (j['servingSize'] as num).toDouble(),
    servingUnit: j['servingUnit'],
  );

  factory PlannedMeal.fromFood(FoodItem food, String mealType, double qty) => PlannedMeal(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    foodId: food.id, foodName: food.name, mealType: mealType,
    quantity: qty, calories: food.calories * qty,
    protein: food.protein * qty, carbs: food.carbs * qty,
    fat: food.fat * qty, servingSize: food.servingSize,
    servingUnit: food.servingUnit,
  );
}

class DayPlan {
  final int weekday; // 1=Mon, 7=Sun
  final List<PlannedMeal> meals;

  DayPlan({required this.weekday, required this.meals});

  double get totalCalories => meals.fold<double>(0, (s, m) => s + m.calories);
  double get totalProtein => meals.fold<double>(0, (s, m) => s + m.protein);
  double get totalCarbs => meals.fold<double>(0, (s, m) => s + m.carbs);
  double get totalFat => meals.fold<double>(0, (s, m) => s + m.fat);

  List<PlannedMeal> byType(String type) => meals.where((m) => m.mealType == type).toList();

  Map<String, dynamic> toJson() => {
    'weekday': weekday,
    'meals': meals.map((m) => m.toJson()).toList(),
  };

  factory DayPlan.fromJson(Map<String, dynamic> j) => DayPlan(
    weekday: j['weekday'],
    meals: (j['meals'] as List).map((m) => PlannedMeal.fromJson(m)).toList(),
  );
}

class MealPlan {
  final String id;
  final String name;
  final List<DayPlan> days; // 7 days
  final DateTime createdAt;

  MealPlan({required this.id, required this.name, required this.days, required this.createdAt});

  double get avgCalories => days.isEmpty ? 0 : days.fold<double>(0, (s, d) => s + d.totalCalories) / days.length;

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name,
    'days': days.map((d) => d.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory MealPlan.fromJson(Map<String, dynamic> j) => MealPlan(
    id: j['id'], name: j['name'],
    days: (j['days'] as List).map((d) => DayPlan.fromJson(d)).toList(),
    createdAt: DateTime.parse(j['createdAt']),
  );
}
