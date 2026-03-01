class MealEntry {
  final String id;
  final String foodId;
  final String foodName;
  final String mealType;
  final double quantity;
  final double servingSize;
  final String servingUnit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime loggedAt;
  final String? photoUrl;
  final String? notes;

  MealEntry({
    required this.id, required this.foodId, required this.foodName,
    required this.mealType, required this.quantity, required this.servingSize,
    required this.servingUnit, required this.calories, required this.protein,
    required this.carbs, required this.fat, required this.loggedAt,
    this.photoUrl, this.notes,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'foodId': foodId, 'foodName': foodName, 'mealType': mealType,
    'quantity': quantity, 'servingSize': servingSize, 'servingUnit': servingUnit,
    'calories': calories, 'protein': protein, 'carbs': carbs, 'fat': fat,
    'loggedAt': loggedAt.toIso8601String(), 'photoUrl': photoUrl, 'notes': notes,
  };

  factory MealEntry.fromJson(Map<String, dynamic> json) => MealEntry(
    id: json['id'], foodId: json['foodId'], foodName: json['foodName'],
    mealType: json['mealType'], quantity: (json['quantity'] as num).toDouble(),
    servingSize: (json['servingSize'] as num).toDouble(),
    servingUnit: json['servingUnit'],
    calories: (json['calories'] as num).toDouble(),
    protein: (json['protein'] as num).toDouble(),
    carbs: (json['carbs'] as num).toDouble(),
    fat: (json['fat'] as num).toDouble(),
    loggedAt: DateTime.parse(json['loggedAt']),
    photoUrl: json['photoUrl'], notes: json['notes'],
  );
}
