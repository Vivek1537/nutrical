import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/food_item.dart';
import '../../models/meal_entry.dart';
import '../../providers/app_state.dart';
import '../../services/food_recognition_service.dart';

class CameraFoodScreen extends StatefulWidget {
  const CameraFoodScreen({super.key});
  @override
  State<CameraFoodScreen> createState() => _CameraFoodScreenState();
}

class _CameraFoodScreenState extends State<CameraFoodScreen> {
  bool _searching = false;
  List<FoodItem> _suggestions = [];
  final _searchCtrl = TextEditingController();
  String _mealType = 'Lunch';

  Future<void> _searchFood(String query) async {
    if (query.length < 2) return;
    setState(() => _searching = true);
    final results = await FoodRecognitionService.smartSearch(query);
    if (mounted) setState(() { _suggestions = results; _searching = false; });
  }

  void _logFood(FoodItem food) {
    final entry = MealEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodId: food.id, foodName: food.name, mealType: _mealType,
      quantity: 1, servingSize: food.servingSize, servingUnit: food.servingUnit,
      calories: food.calories, protein: food.protein,
      carbs: food.carbs, fat: food.fat, loggedAt: DateTime.now(),
    );
    context.read<AppState>().addMeal(entry);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${food.name} logged!'), backgroundColor: AppTheme.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Food Search')),
      body: Column(
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primary.withAlpha(15),
            child: Row(children: [
              Icon(Icons.auto_awesome, color: AppTheme.primary),
              const SizedBox(width: 12),
              const Expanded(child: Text(
                'Smart search: finds food from our 65+ item database + millions of products from Open Food Facts',
                style: TextStyle(fontSize: 13),
              )),
            ]),
          ),
          // Meal type chips
          Container(
            height: 50, padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final type in ['Breakfast', 'Morning Snack', 'Lunch', 'Evening Snack', 'Dinner', 'Late Night'])
                Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: ChoiceChip(label: Text(type, style: const TextStyle(fontSize: 12)),
                    selected: _mealType == type, onSelected: (_) => setState(() => _mealType = type),
                    selectedColor: AppTheme.primary.withAlpha(51))),
            ]),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Type food name (e.g. "maggi", "amul cheese")',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searching
                  ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                  : _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchCtrl.clear(); setState(() => _suggestions = []); })
                    : null,
              ),
              onSubmitted: _searchFood,
              onChanged: (q) { if (q.length >= 3) _searchFood(q); },
            ),
          ),
          // Results
          Expanded(
            child: _suggestions.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('Search for any food item', style: TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  Text('Local DB + Open Food Facts', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                ]))
              : ListView.builder(
                  itemCount: _suggestions.length,
                  itemBuilder: (_, i) {
                    final f = _suggestions[i];
                    final isOnline = f.id.startsWith('off_');
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isOnline ? Colors.blue[50] : AppTheme.primary.withAlpha(30),
                        child: Icon(isOnline ? Icons.cloud : Icons.restaurant, color: isOnline ? Colors.blue : AppTheme.primary, size: 20),
                      ),
                      title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(
                        '${f.calories.round()} kcal \u2022 P${f.protein.round()} C${f.carbs.round()} F${f.fat.round()}${f.brand != null ? " \u2022 ${f.brand}" : ""}',
                        style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      trailing: IconButton(icon: const Icon(Icons.add_circle, color: AppTheme.primary), onPressed: () => _logFood(f)),
                      onTap: () => _logFood(f),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }
}

