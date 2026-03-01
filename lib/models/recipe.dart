import 'food_item.dart';

class RecipeIngredient {
  final FoodItem food;
  final double quantity; // number of servings

  RecipeIngredient({required this.food, required this.quantity});

  double get calories => food.calories * quantity;
  double get protein => food.protein * quantity;
  double get carbs => food.carbs * quantity;
  double get fat => food.fat * quantity;

  Map<String, dynamic> toJson() => {
    'foodId': food.id,
    'foodName': food.name,
    'servingSize': food.servingSize,
    'servingUnit': food.servingUnit,
    'quantity': quantity,
    'caloriesPerServing': food.calories,
    'proteinPerServing': food.protein,
    'carbsPerServing': food.carbs,
    'fatPerServing': food.fat,
  };
}

class Recipe {
  final String id;
  final String name;
  final int servings;
  final List<RecipeIngredient> ingredients;
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.name,
    required this.servings,
    required this.ingredients,
    required this.createdAt,
  });

  double get totalCalories => ingredients.fold<double>(0, (s, i) => s + i.calories);
  double get totalProtein => ingredients.fold<double>(0, (s, i) => s + i.protein);
  double get totalCarbs => ingredients.fold<double>(0, (s, i) => s + i.carbs);
  double get totalFat => ingredients.fold<double>(0, (s, i) => s + i.fat);

  double get caloriesPerServing => servings > 0 ? totalCalories / servings : totalCalories;
  double get proteinPerServing => servings > 0 ? totalProtein / servings : totalProtein;
  double get carbsPerServing => servings > 0 ? totalCarbs / servings : totalCarbs;
  double get fatPerServing => servings > 0 ? totalFat / servings : totalFat;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'servings': servings,
    'ingredients': ingredients.map((i) => i.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };
}
