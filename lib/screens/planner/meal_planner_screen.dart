import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/food_item.dart';
import '../../models/meal_plan.dart';
import '../../services/food_database.dart';
import '../../services/meal_plan_service.dart';
import '../grocery/grocery_list_screen.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});
  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> with SingleTickerProviderStateMixin {
  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _mealTypes = ['Breakfast', 'Lunch', 'Evening Snack', 'Dinner'];

  late TabController _tabCtrl;
  MealPlan? _plan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 7, vsync: this);
    _load();
  }

  Future<void> _load() async {
    var plan = await MealPlanService.getActivePlan();
    if (plan == null) {
      plan = MealPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'My Weekly Plan',
        days: List.generate(7, (i) => DayPlan(weekday: i + 1, meals: [])),
        createdAt: DateTime.now(),
      );
      await MealPlanService.savePlan(plan);
      await MealPlanService.setActivePlan(plan.id);
    }
    if (mounted) setState(() { _plan = plan; _loading = false; });
  }

  Future<void> _addMeal(int dayIndex, String mealType) async {
    final food = await showSearch<FoodItem?>(context: context, delegate: _FoodPlanSearchDelegate());
    if (food == null || _plan == null) return;
    setState(() => _plan!.days[dayIndex].meals.add(PlannedMeal.fromFood(food, mealType, 1)));
    await MealPlanService.savePlan(_plan!);
  }

  Future<void> _removeMeal(int dayIndex, int mealIndex) async {
    setState(() => _plan!.days[dayIndex].meals.removeAt(mealIndex));
    await MealPlanService.savePlan(_plan!);
  }

  void _openGroceryList() {
    if (_plan == null) return;
    final items = MealPlanService.generateGroceryList(_plan!);
    MealPlanService.saveGroceryList(items);
    Navigator.push(context, MaterialPageRoute(builder: (_) => GroceryListScreen(initialItems: items)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        actions: [IconButton(icon: const Icon(Icons.shopping_cart), tooltip: 'Grocery List', onPressed: _openGroceryList)],
        bottom: TabBar(
          controller: _tabCtrl, isScrollable: true,
          indicatorColor: Colors.white, labelColor: Colors.white, unselectedLabelColor: Colors.white60,
          tabs: List.generate(7, (i) => Tab(text: _dayNames[i])),
        ),
      ),
      body: TabBarView(controller: _tabCtrl, children: List.generate(7, _buildDayView)),
    );
  }

  Widget _buildDayView(int dayIdx) {
    final day = _plan!.days[dayIdx];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Card(color: AppTheme.primary.withAlpha(15), child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _chip('Cal', '${day.totalCalories.round()}', AppTheme.accent),
            _chip('Pro', '${day.totalProtein.round()}g', const Color(0xFF42A5F5)),
            _chip('Carb', '${day.totalCarbs.round()}g', const Color(0xFFFFA726)),
            _chip('Fat', '${day.totalFat.round()}g', const Color(0xFFEF5350)),
          ]),
        )),
        const SizedBox(height: 8),
        ..._mealTypes.map((type) {
          final meals = day.byType(type);
          return Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(type, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                InkWell(onTap: () => _addMeal(dayIdx, type), child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add_circle, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 4),
                  Text('Add', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w500, fontSize: 13)),
                ])),
              ]),
              if (meals.isEmpty)
                Padding(padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text('No meals planned', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)))
              else
                ...meals.map((m) {
                  final globalIdx = day.meals.indexOf(m);
                  return Dismissible(
                    key: Key(m.id),
                    direction: DismissDirection.endToStart,
                    background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), color: AppTheme.error, child: const Icon(Icons.delete, color: Colors.white)),
                    onDismissed: (_) => _removeMeal(dayIdx, globalIdx),
                    child: ListTile(dense: true, contentPadding: EdgeInsets.zero,
                      title: Text(m.foodName, style: const TextStyle(fontSize: 14)),
                      subtitle: Text('${m.quantity}x \u2022 ${m.calories.round()} kcal', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      trailing: Text('P${m.protein.round()} C${m.carbs.round()} F${m.fat.round()}', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    ),
                  );
                }),
            ]),
          ));
        }),
      ]),
    );
  }

  Widget _chip(String l, String v, Color c) => Column(children: [
    Text(v, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: c)),
    Text(l, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
  ]);

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }
}

class _FoodPlanSearchDelegate extends SearchDelegate<FoodItem?> {
  @override
  List<Widget> buildActions(BuildContext context) => [IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')];
  @override
  Widget buildLeading(BuildContext context) => IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  @override
  Widget buildResults(BuildContext context) => _build();
  @override
  Widget buildSuggestions(BuildContext context) => _build();
  Widget _build() {
    final r = FoodDatabase.search(query);
    return ListView.builder(itemCount: r.length, itemBuilder: (ctx, i) {
      final f = r[i];
      return ListTile(title: Text(f.name),
        subtitle: Text('${f.calories.round()} kcal \u2022 P${f.protein.round()} C${f.carbs.round()} F${f.fat.round()}'),
        onTap: () => close(ctx, f));
    });
  }
}
