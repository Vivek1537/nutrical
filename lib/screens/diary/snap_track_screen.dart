import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/food_item.dart';
import '../../models/meal_entry.dart';
import '../../providers/app_state.dart';
import '../../services/food_vision_service.dart';

class SnapTrackScreen extends StatefulWidget {
  const SnapTrackScreen({super.key});
  @override
  State<SnapTrackScreen> createState() => _SnapTrackScreenState();
}

class _SnapTrackScreenState extends State<SnapTrackScreen> {
  File? _image;
  List<FoodItem> _detected = [];
  bool _analyzing = false;
  String? _error;
  String _mealType = 'Lunch';
  final Map<String, double> _quantities = {};

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);
    if (picked == null) return;

    final file = File(picked.path);
    setState(() { _image = file; _detected = []; _error = null; _analyzing = true; });

    try {
      final foods = await FoodVisionService.analyzeImage(file);
      if (mounted) {
        setState(() {
          _detected = foods;
          _analyzing = false;
          for (final f in foods) { _quantities[f.id] = 1.0; }
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _analyzing = false; });
    }
  }

  void _logFood(FoodItem food) {
    final qty = _quantities[food.id] ?? 1.0;
    final entry = MealEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodId: food.id, foodName: food.name, mealType: _mealType,
      quantity: qty, servingSize: food.servingSize, servingUnit: food.servingUnit,
      calories: food.calories * qty, protein: food.protein * qty,
      carbs: food.carbs * qty, fat: food.fat * qty, loggedAt: DateTime.now(),
    );
    context.read<AppState>().addMeal(entry);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${food.name} logged!'), backgroundColor: AppTheme.primary));
  }

  void _logAll() {
    for (final food in _detected) { _logFood(food); }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Snap & Track')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Camera buttons
          Row(children: [
            Expanded(child: ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            )),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
            )),
          ]),
          const SizedBox(height: 16),

          // Meal type selector
          SizedBox(
            height: 42, child: ListView(scrollDirection: Axis.horizontal, children: [
              for (final type in ['Breakfast', 'Morning Snack', 'Lunch', 'Evening Snack', 'Dinner', 'Late Night'])
                Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(
                  label: Text(type, style: const TextStyle(fontSize: 12)),
                  selected: _mealType == type,
                  onSelected: (_) => setState(() => _mealType = type),
                  selectedColor: AppTheme.primary.withAlpha(51),
                )),
            ]),
          ),
          const SizedBox(height: 16),

          // Image preview
          if (_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_image!, height: 250, width: double.infinity, fit: BoxFit.cover),
            ),

          // Loading
          if (_analyzing)
            const Padding(padding: EdgeInsets.all(32), child: Center(child: Column(children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Analyzing your meal with AI...'),
              SizedBox(height: 4),
              Text('First time may take ~20s to warm up', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ]))),

          // Error
          if (_error != null)
            Padding(padding: const EdgeInsets.all(16), child: Card(color: Colors.red[50],
              child: Padding(padding: const EdgeInsets.all(12), child: Text(_error!,
                style: TextStyle(color: AppTheme.error))))),

          // Results
          if (_detected.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Detected Foods (${_detected.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton.icon(onPressed: _logAll, icon: const Icon(Icons.check_circle), label: const Text('Log All')),
            ]),
            const SizedBox(height: 8),
            ..._detected.map((food) {
              final qty = _quantities[food.id] ?? 1.0;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(padding: const EdgeInsets.all(12), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Expanded(child: Text(food.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                      IconButton(icon: const Icon(Icons.add_circle, color: AppTheme.primary),
                        onPressed: () => _logFood(food)),
                    ]),
                    Text('${food.category} • ${food.servingSize.round()}${food.servingUnit}',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _nutriChip('Cal', '${(food.calories * qty).round()}', AppTheme.accent),
                      _nutriChip('Pro', '${(food.protein * qty).round()}g', const Color(0xFF42A5F5)),
                      _nutriChip('Carb', '${(food.carbs * qty).round()}g', const Color(0xFFFFA726)),
                      _nutriChip('Fat', '${(food.fat * qty).round()}g', const Color(0xFFEF5350)),
                    ]),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      IconButton(icon: const Icon(Icons.remove_circle_outline, size: 28),
                        onPressed: qty > 0.5 ? () => setState(() => _quantities[food.id] = qty - 0.5) : null),
                      Text('${qty.toStringAsFixed(1)}x', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.add_circle_outline, size: 28, color: AppTheme.primary),
                        onPressed: () => setState(() => _quantities[food.id] = qty + 0.5)),
                    ]),
                  ],
                )),
              );
            }),
          ],

          // Empty state
          if (_image == null && !_analyzing)
            Padding(padding: const EdgeInsets.all(40), child: Center(child: Column(children: [
              Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text('Take a photo of your meal', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
              const SizedBox(height: 4),
              Text('AI will identify foods and estimate calories', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 4),
              Text('No API key needed — 100% free!', style: TextStyle(fontSize: 12, color: AppTheme.primary)),
            ]))),
        ]),
      ),
    );
  }

  Widget _nutriChip(String label, String value, Color color) => Column(children: [
    Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
  ]);
}
