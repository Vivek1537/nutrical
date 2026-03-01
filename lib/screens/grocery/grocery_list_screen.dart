import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/grocery_item.dart';
import '../../services/meal_plan_service.dart';

class GroceryListScreen extends StatefulWidget {
  final List<GroceryItem> initialItems;
  const GroceryListScreen({super.key, required this.initialItems});
  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  late List<GroceryItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialItems);
  }

  void _toggle(int idx) {
    setState(() => _items[idx].checked = !_items[idx].checked);
    MealPlanService.saveGroceryList(_items);
  }

  void _share() {
    final text = StringBuffer('🛒 NutriCal Grocery List\n\n');
    for (final item in _items) {
      text.write('${item.checked ? "✅" : "⬜"} ${item.name} - ${item.quantity.round()}${item.unit}\n');
    }
    // Copy to clipboard
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Grocery list copied!')));
  }

  @override
  Widget build(BuildContext context) {
    final unchecked = _items.where((i) => !i.checked).toList();
    final checked = _items.where((i) => i.checked).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Grocery List (${_items.length})'),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _share),
        ],
      ),
      body: _items.isEmpty
        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 12),
            Text('Plan meals first to generate a grocery list', style: TextStyle(color: AppTheme.textSecondary)),
          ]))
        : ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (unchecked.isNotEmpty) ...[
                Text('To Buy (${unchecked.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...unchecked.map((item) {
                  final idx = _items.indexOf(item);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: ListTile(
                      leading: Checkbox(value: false, onChanged: (_) => _toggle(idx), activeColor: AppTheme.primary),
                      title: Text(item.name),
                      trailing: Text('${item.quantity.round()} ${item.unit}', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                    ),
                  );
                }),
              ],
              if (checked.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Done (${checked.length})', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                ...checked.map((item) {
                  final idx = _items.indexOf(item);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 4),
                    color: Colors.grey[50],
                    child: ListTile(
                      leading: Checkbox(value: true, onChanged: (_) => _toggle(idx), activeColor: AppTheme.primary),
                      title: Text(item.name, style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey)),
                      trailing: Text('${item.quantity.round()} ${item.unit}', style: const TextStyle(color: Colors.grey)),
                    ),
                  );
                }),
              ],
            ],
          ),
    );
  }
}
