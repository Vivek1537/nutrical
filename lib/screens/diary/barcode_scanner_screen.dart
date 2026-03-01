import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/food_item.dart';
import '../../models/meal_entry.dart';
import '../../providers/app_state.dart';
import '../../services/barcode_service.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});
  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _isProcessing = false;
  String? _error;
  FoodItem? _foundFood;
  double _quantity = 1.0;
  String _mealType = 'Lunch';

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _foundFood != null) return;
    final barcode = capture.barcodes.firstOrNull?.rawValue;
    if (barcode == null) return;

    setState(() { _isProcessing = true; _error = null; });

    final food = await BarcodeService.lookup(barcode);
    if (mounted) {
      setState(() {
        _isProcessing = false;
        if (food != null) {
          _foundFood = food;
        } else {
          _error = 'Product not found for barcode: $barcode';
        }
      });
    }
  }

  void _logFood() {
    if (_foundFood == null) return;
    final entry = MealEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodId: _foundFood!.id,
      foodName: _foundFood!.name,
      mealType: _mealType,
      quantity: _quantity,
      servingSize: _foundFood!.servingSize,
      servingUnit: _foundFood!.servingUnit,
      calories: _foundFood!.calories * _quantity,
      protein: _foundFood!.protein * _quantity,
      carbs: _foundFood!.carbs * _quantity,
      fat: _foundFood!.fat * _quantity,
      loggedAt: DateTime.now(),
    );
    context.read<AppState>().addMeal(entry);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_foundFood!.name} logged!'), backgroundColor: AppTheme.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: _foundFood != null ? _buildResult() : _buildScanner(),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        MobileScanner(onDetect: _onDetect),
        if (_isProcessing)
          const Center(child: Card(child: Padding(padding: EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Looking up product...'),
            ])))),
        if (_error != null)
          Positioned(
            bottom: 40, left: 20, right: 20,
            child: Card(color: AppTheme.error,
              child: Padding(padding: const EdgeInsets.all(16),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() => _error = null),
                    child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                  ),
                ]))),
          ),
        Positioned(
          top: 20, left: 0, right: 0,
          child: Center(child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
            child: const Text('Point camera at barcode', style: TextStyle(color: Colors.white)),
          )),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final f = _foundFood!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(padding: const EdgeInsets.all(20), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(f.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                if (f.brand != null) Text(f.brand!, style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                Text('${f.servingSize.round()}${f.servingUnit} per serving', style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _nutriCol('Cal', '${(f.calories * _quantity).round()}', AppTheme.accent),
                  _nutriCol('Protein', '${(f.protein * _quantity).round()}g', const Color(0xFF42A5F5)),
                  _nutriCol('Carbs', '${(f.carbs * _quantity).round()}g', const Color(0xFFFFA726)),
                  _nutriCol('Fat', '${(f.fat * _quantity).round()}g', const Color(0xFFEF5350)),
                ]),
              ],
            )),
          ),
          const SizedBox(height: 16),
          // Quantity
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.remove_circle_outline), iconSize: 32,
                onPressed: _quantity > 0.5 ? () => setState(() => _quantity -= 0.5) : null),
              const SizedBox(width: 16),
              Text('${_quantity.toStringAsFixed(1)}x', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              IconButton(icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary), iconSize: 32,
                onPressed: () => setState(() => _quantity += 0.5)),
            ],
          ))),
          const SizedBox(height: 16),
          // Meal type
          Card(child: Padding(padding: const EdgeInsets.all(16), child: DropdownButtonFormField<String>(
            initialValue: _mealType,
            decoration: const InputDecoration(labelText: 'Meal Type', border: InputBorder.none),
            items: ['Breakfast', 'Morning Snack', 'Lunch', 'Evening Snack', 'Dinner', 'Late Night']
              .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _mealType = v!),
          ))),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: _logFood,
            icon: const Icon(Icons.check),
            label: const Text('Log Food'),
          )),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: OutlinedButton(
            onPressed: () => setState(() { _foundFood = null; _error = null; }),
            child: const Text('Scan Another'),
          )),
        ],
      ),
    );
  }

  Widget _nutriCol(String label, String value, Color color) => Column(children: [
    Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
  ]);
}

