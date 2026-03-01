import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/food_item.dart';
import '../../models/meal_entry.dart';
import '../../providers/app_state.dart';
import '../../services/food_database.dart';
import '../../utils/constants.dart';
import 'barcode_scanner_screen.dart';
import 'recipe_builder_screen.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});
  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchController = TextEditingController();
  List<FoodItem> _results = [];
  String _selectedMealType = 'Breakfast';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _results = FoodDatabase.search('');
  }

  void _search(String query) {
    setState(() { _results = FoodDatabase.search(query); });
  }

  void _selectFood(FoodItem food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _FoodDetailSheet(food: food, mealType: _selectedMealType),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'Search'),
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'Scan'),
            Tab(icon: Icon(Icons.restaurant), text: 'Recipe'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // Search tab
          Column(
            children: [
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: AppConstants.mealTypes.map((type) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: ChoiceChip(
                      label: Text(type, style: const TextStyle(fontSize: 13)),
                      selected: _selectedMealType == type,
                      onSelected: (_) => setState(() => _selectedMealType = type),
                      selectedColor: AppTheme.primary.withAlpha(51),
                    ),
                  )).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  onChanged: _search,
                  decoration: InputDecoration(
                    hintText: 'Search 65+ foods...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _search(''); })
                      : null,
                  ),
                ),
              ),
              Expanded(
                child: _results.isEmpty
                  ? Center(child: Text('No foods found', style: TextStyle(color: AppTheme.textSecondary)))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (_, i) {
                        final food = _results[i];
                        return ListTile(
                          title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text('${food.calories.round()} kcal • ${food.servingSize.round()}${food.servingUnit}  |  P:${food.protein.round()} C:${food.carbs.round()} F:${food.fat.round()}',
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle, color: AppTheme.primary),
                            onPressed: () => _selectFood(food),
                          ),
                          onTap: () => _selectFood(food),
                        );
                      },
                    ),
              ),
            ],
          ),
          // Scan tab
          const BarcodeScannerScreen(),
          // Recipe tab
          const RecipeBuilderScreen(),
        ],
      ),
    );
  }

  @override
  void dispose() { _searchController.dispose(); _tabCtrl.dispose(); super.dispose(); }
}

class _FoodDetailSheet extends StatefulWidget {
  final FoodItem food;
  final String mealType;
  const _FoodDetailSheet({required this.food, required this.mealType});
  @override
  State<_FoodDetailSheet> createState() => _FoodDetailSheetState();
}

class _FoodDetailSheetState extends State<_FoodDetailSheet> {
  double _quantity = 1.0;

  double get _cal => widget.food.calories * _quantity;
  double get _pro => widget.food.protein * _quantity;
  double get _carb => widget.food.carbs * _quantity;
  double get _fat => widget.food.fat * _quantity;

  void _log() {
    final entry = MealEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodId: widget.food.id,
      foodName: widget.food.name,
      mealType: widget.mealType,
      quantity: _quantity,
      servingSize: widget.food.servingSize,
      servingUnit: widget.food.servingUnit,
      calories: _cal,
      protein: _pro,
      carbs: _carb,
      fat: _fat,
      loggedAt: DateTime.now(),
    );
    context.read<AppState>().addMeal(entry);
    Navigator.pop(context);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.food.name} logged!'), backgroundColor: AppTheme.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text(widget.food.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('${widget.food.servingSize.round()}${widget.food.servingUnit} per serving', style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.remove_circle_outline), iconSize: 36,
                onPressed: _quantity > 0.5 ? () => setState(() => _quantity -= 0.5) : null),
              const SizedBox(width: 16),
              Text('${_quantity.toStringAsFixed(1)}x', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              IconButton(icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary), iconSize: 36,
                onPressed: () => setState(() => _quantity += 0.5)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _nutrient('Calories', '${_cal.round()}', 'kcal', AppTheme.accent),
                _nutrient('Protein', '${_pro.round()}', 'g', const Color(0xFF42A5F5)),
                _nutrient('Carbs', '${_carb.round()}', 'g', const Color(0xFFFFA726)),
                _nutrient('Fat', '${_fat.round()}', 'g', const Color(0xFFEF5350)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _log,
              icon: const Icon(Icons.check),
              label: Text('Log to ${widget.mealType}'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _nutrient(String name, String value, String unit, Color color) => Column(
    children: [
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      Text(unit, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      Text(name, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
    ],
  );
}
