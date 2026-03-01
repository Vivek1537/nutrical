import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/food_item.dart';
import '../../models/meal_entry.dart';
import '../../models/recipe.dart';
import '../../providers/app_state.dart';
import '../../services/food_database.dart';

class RecipeBuilderScreen extends StatefulWidget {
  const RecipeBuilderScreen({super.key});
  @override
  State<RecipeBuilderScreen> createState() => _RecipeBuilderScreenState();
}

class _RecipeBuilderScreenState extends State<RecipeBuilderScreen> {
  final _nameCtrl = TextEditingController();
  final _servingsCtrl = TextEditingController(text: '1');
  final List<RecipeIngredient> _ingredients = [];
  String _mealType = 'Lunch';

  double get _totalCal => _ingredients.fold<double>(0, (s, i) => s + i.calories);
  double get _totalPro => _ingredients.fold<double>(0, (s, i) => s + i.protein);
  double get _totalCarb => _ingredients.fold<double>(0, (s, i) => s + i.carbs);
  double get _totalFat => _ingredients.fold<double>(0, (s, i) => s + i.fat);
  int get _servings => int.tryParse(_servingsCtrl.text) ?? 1;

  void _addIngredient() async {
    final food = await showSearch<FoodItem?>(context: context, delegate: _FoodSearchDelegate());
    if (food != null) {
      setState(() => _ingredients.add(RecipeIngredient(food: food, quantity: 1)));
    }
  }

  void _logRecipe() {
    if (_nameCtrl.text.isEmpty || _ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a name and at least one ingredient')),
      );
      return;
    }
    final servings = _servings.clamp(1, 20);
    final entry = MealEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodId: 'recipe_${DateTime.now().millisecondsSinceEpoch}',
      foodName: '${_nameCtrl.text} (Recipe)',
      mealType: _mealType,
      quantity: 1,
      servingSize: servings.toDouble(),
      servingUnit: 'serving',
      calories: _totalCal / servings,
      protein: _totalPro / servings,
      carbs: _totalCarb / servings,
      fat: _totalFat / servings,
      loggedAt: DateTime.now(),
    );
    context.read<AppState>().addMeal(entry);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_nameCtrl.text} logged!'), backgroundColor: AppTheme.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Builder')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Recipe Name', prefixIcon: Icon(Icons.restaurant))),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _servingsCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Servings', prefixIcon: Icon(Icons.people)),
                onChanged: (_) => setState(() {}))),
              const SizedBox(width: 12),
              Expanded(child: DropdownButtonFormField<String>(
                initialValue: _mealType,
                decoration: const InputDecoration(labelText: 'Meal Type'),
                items: ['Breakfast', 'Morning Snack', 'Lunch', 'Evening Snack', 'Dinner', 'Late Night']
                  .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 14)))).toList(),
                onChanged: (v) => setState(() => _mealType = v!),
              )),
            ]),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Ingredients', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              TextButton.icon(onPressed: _addIngredient, icon: const Icon(Icons.add), label: const Text('Add')),
            ]),
            if (_ingredients.isEmpty)
              Padding(padding: const EdgeInsets.all(20),
                child: Center(child: Text('Tap "Add" to search and add ingredients', style: TextStyle(color: AppTheme.textSecondary))))
            else
              ...List.generate(_ingredients.length, (i) {
                final ing = _ingredients[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(ing.food.name),
                    subtitle: Text('${ing.quantity}x ${ing.food.servingSize.round()}${ing.food.servingUnit} • ${ing.calories.round()} kcal',
                      style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.remove, size: 18),
                        onPressed: ing.quantity > 0.5 ? () => setState(() => _ingredients[i] = RecipeIngredient(food: ing.food, quantity: ing.quantity - 0.5)) : null),
                      Text('${ing.quantity}x', style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.add, size: 18),
                        onPressed: () => setState(() => _ingredients[i] = RecipeIngredient(food: ing.food, quantity: ing.quantity + 0.5))),
                      IconButton(icon: Icon(Icons.delete, size: 18, color: AppTheme.error),
                        onPressed: () => setState(() => _ingredients.removeAt(i))),
                    ]),
                  ),
                );
              }),
            if (_ingredients.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: AppTheme.primary.withAlpha(15),
                child: Padding(padding: const EdgeInsets.all(16), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Per Serving (1 of $_servings)', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _nutriCol('Cal', '${(_totalCal / _servings).round()}', AppTheme.accent),
                      _nutriCol('Protein', '${(_totalPro / _servings).round()}g', const Color(0xFF42A5F5)),
                      _nutriCol('Carbs', '${(_totalCarb / _servings).round()}g', const Color(0xFFFFA726)),
                      _nutriCol('Fat', '${(_totalFat / _servings).round()}g', const Color(0xFFEF5350)),
                    ]),
                    const SizedBox(height: 8),
                    Text('Total: ${_totalCal.round()} kcal', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                )),
              ),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: _logRecipe,
                icon: const Icon(Icons.check),
                label: const Text('Log Recipe'),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _nutriCol(String label, String value, Color color) => Column(children: [
    Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
  ]);
}

class _FoodSearchDelegate extends SearchDelegate<FoodItem?> {
  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) =>
    IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final results = FoodDatabase.search(query);
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, i) {
        final food = results[i];
        return ListTile(
          title: Text(food.name),
          subtitle: Text('${food.calories.round()} kcal • ${food.servingSize.round()}${food.servingUnit}'),
          onTap: () => close(context, food),
        );
      },
    );
  }
}

