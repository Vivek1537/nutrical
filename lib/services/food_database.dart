import '../models/food_item.dart';

class FoodDatabase {
  static final List<FoodItem> _foods = [
    // Indian Breads
    FoodItem(id: '1', name: 'Roti (Chapati)', category: 'Indian Bread', servingSize: 40, servingUnit: 'g', calories: 120, protein: 3.5, carbs: 20, fat: 3.5, fiber: 2.0),
    FoodItem(id: '9', name: 'Paratha (Aloo)', category: 'Indian Bread', servingSize: 80, servingUnit: 'g', calories: 220, protein: 5, carbs: 30, fat: 9, fiber: 2.0),
    FoodItem(id: '14', name: 'Butter Naan', category: 'Indian Bread', servingSize: 80, servingUnit: 'g', calories: 260, protein: 7, carbs: 38, fat: 9, fiber: 1.5),
    FoodItem(id: '31', name: 'Puri', category: 'Indian Bread', servingSize: 30, servingUnit: 'g', calories: 120, protein: 2, carbs: 13, fat: 7, fiber: 0.5),
    FoodItem(id: '32', name: 'Kulcha', category: 'Indian Bread', servingSize: 80, servingUnit: 'g', calories: 240, protein: 6, carbs: 36, fat: 8, fiber: 1.5),
    FoodItem(id: '33', name: 'Bhatura', category: 'Indian Bread', servingSize: 60, servingUnit: 'g', calories: 200, protein: 4, carbs: 25, fat: 10, fiber: 1.0),
    // Indian Curries
    FoodItem(id: '2', name: 'Dal Tadka', category: 'Indian Curry', servingSize: 150, servingUnit: 'ml', calories: 150, protein: 9, carbs: 18, fat: 5, fiber: 4.0),
    FoodItem(id: '4', name: 'Paneer Butter Masala', category: 'Indian Curry', servingSize: 200, servingUnit: 'g', calories: 340, protein: 14, carbs: 12, fat: 26, fiber: 1.5),
    FoodItem(id: '5', name: 'Chicken Curry', category: 'Indian Curry', servingSize: 200, servingUnit: 'g', calories: 250, protein: 28, carbs: 8, fat: 12, fiber: 1.0),
    FoodItem(id: '11', name: 'Rajma', category: 'Indian Curry', servingSize: 150, servingUnit: 'g', calories: 180, protein: 12, carbs: 25, fat: 3, fiber: 7.0),
    FoodItem(id: '12', name: 'Chole', category: 'Indian Curry', servingSize: 150, servingUnit: 'g', calories: 200, protein: 10, carbs: 28, fat: 6, fiber: 6.0),
    FoodItem(id: '29', name: 'Aloo Gobi', category: 'Indian Curry', servingSize: 150, servingUnit: 'g', calories: 130, protein: 3, carbs: 18, fat: 6, fiber: 3.0),
    FoodItem(id: '34', name: 'Palak Paneer', category: 'Indian Curry', servingSize: 200, servingUnit: 'g', calories: 280, protein: 15, carbs: 10, fat: 20, fiber: 3.0),
    FoodItem(id: '35', name: 'Butter Chicken', category: 'Indian Curry', servingSize: 200, servingUnit: 'g', calories: 320, protein: 26, carbs: 10, fat: 20, fiber: 1.0),
    FoodItem(id: '36', name: 'Egg Curry', category: 'Indian Curry', servingSize: 200, servingUnit: 'g', calories: 220, protein: 16, carbs: 8, fat: 14, fiber: 1.5),
    FoodItem(id: '37', name: 'Kadhi Pakora', category: 'Indian Curry', servingSize: 200, servingUnit: 'ml', calories: 180, protein: 6, carbs: 15, fat: 11, fiber: 1.0),
    FoodItem(id: '38', name: 'Sambar', category: 'Indian Curry', servingSize: 200, servingUnit: 'ml', calories: 130, protein: 6, carbs: 20, fat: 3, fiber: 4.0),
    // South Indian
    FoodItem(id: '6', name: 'Idli', category: 'South Indian', servingSize: 60, servingUnit: 'g', calories: 78, protein: 2, carbs: 15, fat: 0.4, fiber: 0.8),
    FoodItem(id: '7', name: 'Dosa (Plain)', category: 'South Indian', servingSize: 100, servingUnit: 'g', calories: 168, protein: 4, carbs: 28, fat: 5, fiber: 1.2),
    FoodItem(id: '39', name: 'Masala Dosa', category: 'South Indian', servingSize: 200, servingUnit: 'g', calories: 350, protein: 7, carbs: 50, fat: 14, fiber: 3.0),
    FoodItem(id: '40', name: 'Uttapam', category: 'South Indian', servingSize: 120, servingUnit: 'g', calories: 180, protein: 5, carbs: 28, fat: 6, fiber: 2.0),
    FoodItem(id: '41', name: 'Vada', category: 'South Indian', servingSize: 50, servingUnit: 'g', calories: 140, protein: 5, carbs: 14, fat: 8, fiber: 1.5),
    // Rice Dishes
    FoodItem(id: '3', name: 'Rice (Steamed)', category: 'Rice Dishes', servingSize: 150, servingUnit: 'g', calories: 195, protein: 4, carbs: 43, fat: 0.4, fiber: 0.6),
    FoodItem(id: '13', name: 'Biryani (Chicken)', category: 'Rice Dishes', servingSize: 250, servingUnit: 'g', calories: 400, protein: 22, carbs: 50, fat: 14, fiber: 2.0),
    FoodItem(id: '42', name: 'Veg Pulao', category: 'Rice Dishes', servingSize: 200, servingUnit: 'g', calories: 250, protein: 5, carbs: 40, fat: 8, fiber: 2.5),
    FoodItem(id: '43', name: 'Jeera Rice', category: 'Rice Dishes', servingSize: 150, servingUnit: 'g', calories: 210, protein: 4, carbs: 42, fat: 3, fiber: 0.8),
    FoodItem(id: '44', name: 'Lemon Rice', category: 'Rice Dishes', servingSize: 150, servingUnit: 'g', calories: 220, protein: 4, carbs: 38, fat: 6, fiber: 1.0),
    // Breakfast
    FoodItem(id: '8', name: 'Poha', category: 'Breakfast', servingSize: 150, servingUnit: 'g', calories: 180, protein: 4, carbs: 32, fat: 5, fiber: 1.5),
    FoodItem(id: '15', name: 'Upma', category: 'Breakfast', servingSize: 150, servingUnit: 'g', calories: 170, protein: 4, carbs: 28, fat: 5, fiber: 2.0),
    FoodItem(id: '22', name: 'Oats (Cooked)', category: 'Breakfast', servingSize: 175, servingUnit: 'g', calories: 150, protein: 5, carbs: 27, fat: 2.5, fiber: 4.0),
    FoodItem(id: '45', name: 'Cornflakes with Milk', category: 'Breakfast', servingSize: 250, servingUnit: 'g', calories: 200, protein: 6, carbs: 38, fat: 3, fiber: 1.0),
    FoodItem(id: '46', name: 'Paratha (Plain)', category: 'Breakfast', servingSize: 60, servingUnit: 'g', calories: 180, protein: 4, carbs: 24, fat: 8, fiber: 1.5),
    // Snacks
    FoodItem(id: '10', name: 'Samosa', category: 'Snacks', servingSize: 80, servingUnit: 'g', calories: 250, protein: 4, carbs: 24, fat: 15, fiber: 1.5),
    FoodItem(id: '30', name: 'Maggi Noodles', category: 'Snacks', servingSize: 70, servingUnit: 'g', calories: 310, protein: 7, carbs: 42, fat: 13, fiber: 2.0),
    FoodItem(id: '47', name: 'Bhel Puri', category: 'Snacks', servingSize: 100, servingUnit: 'g', calories: 160, protein: 4, carbs: 28, fat: 4, fiber: 2.0),
    FoodItem(id: '48', name: 'Pav Bhaji', category: 'Snacks', servingSize: 250, servingUnit: 'g', calories: 380, protein: 10, carbs: 50, fat: 16, fiber: 5.0),
    FoodItem(id: '49', name: 'Pakora (Mixed Veg)', category: 'Snacks', servingSize: 100, servingUnit: 'g', calories: 280, protein: 5, carbs: 22, fat: 19, fiber: 2.0),
    FoodItem(id: '50', name: 'Dhokla', category: 'Snacks', servingSize: 100, servingUnit: 'g', calories: 160, protein: 5, carbs: 26, fat: 4, fiber: 1.5),
    // Protein
    FoodItem(id: '16', name: 'Egg (Boiled)', category: 'Protein', servingSize: 50, servingUnit: 'g', calories: 78, protein: 6, carbs: 0.6, fat: 5, fiber: 0),
    FoodItem(id: '21', name: 'Chicken Breast (Grilled)', category: 'Protein', servingSize: 120, servingUnit: 'g', calories: 190, protein: 35, carbs: 0, fat: 4, fiber: 0),
    FoodItem(id: '51', name: 'Fish Curry', category: 'Protein', servingSize: 200, servingUnit: 'g', calories: 200, protein: 24, carbs: 6, fat: 9, fiber: 1.0),
    FoodItem(id: '52', name: 'Tandoori Chicken', category: 'Protein', servingSize: 150, servingUnit: 'g', calories: 260, protein: 32, carbs: 4, fat: 13, fiber: 0.5),
    FoodItem(id: '53', name: 'Whey Protein Shake', category: 'Protein', servingSize: 300, servingUnit: 'ml', calories: 130, protein: 24, carbs: 4, fat: 2, fiber: 0),
    // Dairy
    FoodItem(id: '19', name: 'Milk (Full Cream)', category: 'Dairy', servingSize: 250, servingUnit: 'ml', calories: 150, protein: 8, carbs: 12, fat: 8, fiber: 0),
    FoodItem(id: '20', name: 'Curd (Plain)', category: 'Dairy', servingSize: 150, servingUnit: 'g', calories: 90, protein: 5, carbs: 7, fat: 5, fiber: 0),
    FoodItem(id: '28', name: 'Paneer (Raw)', category: 'Dairy', servingSize: 100, servingUnit: 'g', calories: 265, protein: 18, carbs: 2, fat: 21, fiber: 0),
    FoodItem(id: '54', name: 'Lassi (Sweet)', category: 'Dairy', servingSize: 250, servingUnit: 'ml', calories: 180, protein: 6, carbs: 28, fat: 5, fiber: 0),
    FoodItem(id: '55', name: 'Buttermilk (Chaas)', category: 'Dairy', servingSize: 250, servingUnit: 'ml', calories: 40, protein: 3, carbs: 4, fat: 1, fiber: 0),
    // Fruits
    FoodItem(id: '17', name: 'Banana', category: 'Fruits', servingSize: 120, servingUnit: 'g', calories: 105, protein: 1.3, carbs: 27, fat: 0.4, fiber: 3.1),
    FoodItem(id: '18', name: 'Apple', category: 'Fruits', servingSize: 180, servingUnit: 'g', calories: 95, protein: 0.5, carbs: 25, fat: 0.3, fiber: 4.4),
    FoodItem(id: '56', name: 'Mango', category: 'Fruits', servingSize: 150, servingUnit: 'g', calories: 100, protein: 1, carbs: 25, fat: 0.5, fiber: 2.5),
    FoodItem(id: '57', name: 'Papaya', category: 'Fruits', servingSize: 150, servingUnit: 'g', calories: 60, protein: 1, carbs: 15, fat: 0.3, fiber: 2.5),
    FoodItem(id: '58', name: 'Guava', category: 'Fruits', servingSize: 100, servingUnit: 'g', calories: 68, protein: 2.5, carbs: 14, fat: 1, fiber: 5.0),
    // Beverages
    FoodItem(id: '25', name: 'Tea (with Milk & Sugar)', category: 'Beverages', servingSize: 200, servingUnit: 'ml', calories: 60, protein: 2, carbs: 10, fat: 1.5, fiber: 0),
    FoodItem(id: '26', name: 'Coffee (with Milk)', category: 'Beverages', servingSize: 200, servingUnit: 'ml', calories: 45, protein: 2, carbs: 6, fat: 1.5, fiber: 0),
    FoodItem(id: '59', name: 'Coconut Water', category: 'Beverages', servingSize: 250, servingUnit: 'ml', calories: 45, protein: 1, carbs: 9, fat: 0.5, fiber: 0),
    FoodItem(id: '60', name: 'Nimbu Pani', category: 'Beverages', servingSize: 250, servingUnit: 'ml', calories: 50, protein: 0, carbs: 13, fat: 0, fiber: 0),
    // Nuts & Spreads
    FoodItem(id: '27', name: 'Almonds', category: 'Nuts', servingSize: 28, servingUnit: 'g', calories: 164, protein: 6, carbs: 6, fat: 14, fiber: 3.5),
    FoodItem(id: '23', name: 'Peanut Butter', category: 'Nuts', servingSize: 32, servingUnit: 'g', calories: 190, protein: 7, carbs: 7, fat: 16, fiber: 2.0),
    FoodItem(id: '61', name: 'Cashews', category: 'Nuts', servingSize: 28, servingUnit: 'g', calories: 155, protein: 5, carbs: 9, fat: 12, fiber: 1.0),
    FoodItem(id: '62', name: 'Walnuts', category: 'Nuts', servingSize: 28, servingUnit: 'g', calories: 185, protein: 4, carbs: 4, fat: 18, fiber: 2.0),
    // Breads & Other
    FoodItem(id: '24', name: 'Bread (Whole Wheat)', category: 'Breads', servingSize: 30, servingUnit: 'g', calories: 80, protein: 4, carbs: 14, fat: 1, fiber: 2.0),
    // Sweets
    FoodItem(id: '63', name: 'Gulab Jamun', category: 'Sweets', servingSize: 50, servingUnit: 'g', calories: 175, protein: 2, carbs: 28, fat: 7, fiber: 0.2),
    FoodItem(id: '64', name: 'Rasgulla', category: 'Sweets', servingSize: 50, servingUnit: 'g', calories: 130, protein: 3, carbs: 24, fat: 3, fiber: 0),
    FoodItem(id: '65', name: 'Jalebi', category: 'Sweets', servingSize: 50, servingUnit: 'g', calories: 200, protein: 2, carbs: 35, fat: 7, fiber: 0.2),
  ];

  static List<FoodItem> search(String query) {
    if (query.isEmpty) return _foods;
    final q = query.toLowerCase();
    return _foods.where((f) =>
      f.name.toLowerCase().contains(q) ||
      f.category.toLowerCase().contains(q) ||
      (f.brand?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  static FoodItem? getById(String id) {
    try { return _foods.firstWhere((f) => f.id == id); }
    catch (_) { return null; }
  }

  static List<FoodItem> getByCategory(String category) {
    return _foods.where((f) => f.category == category).toList();
  }

  static List<String> get categories => _foods.map((f) => f.category).toSet().toList()..sort();
}
