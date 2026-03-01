class FoodItem {
  final String id;
  final String name;
  final String? brand;
  final String category;
  final double servingSize;
  final String servingUnit;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double? fiber;
  final double? sugar;
  final double? sodium;
  final String? barcode;
  final bool isVerified;

  FoodItem({
    required this.id, required this.name, this.brand, required this.category,
    required this.servingSize, required this.servingUnit, required this.calories,
    required this.protein, required this.carbs, required this.fat,
    this.fiber, this.sugar, this.sodium, this.barcode, this.isVerified = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'brand': brand, 'category': category,
    'servingSize': servingSize, 'servingUnit': servingUnit, 'calories': calories,
    'protein': protein, 'carbs': carbs, 'fat': fat, 'fiber': fiber,
    'sugar': sugar, 'sodium': sodium, 'barcode': barcode, 'isVerified': isVerified,
  };

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
    id: json['id'], name: json['name'], brand: json['brand'],
    category: json['category'] ?? 'General',
    servingSize: (json['servingSize'] as num).toDouble(),
    servingUnit: json['servingUnit'] ?? 'g',
    calories: (json['calories'] as num).toDouble(),
    protein: (json['protein'] as num).toDouble(),
    carbs: (json['carbs'] as num).toDouble(),
    fat: (json['fat'] as num).toDouble(),
    fiber: json['fiber'] != null ? (json['fiber'] as num).toDouble() : null,
    sugar: json['sugar'] != null ? (json['sugar'] as num).toDouble() : null,
    sodium: json['sodium'] != null ? (json['sodium'] as num).toDouble() : null,
    barcode: json['barcode'], isVerified: json['isVerified'] ?? false,
  );
}
