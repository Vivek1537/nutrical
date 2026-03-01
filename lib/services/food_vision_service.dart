import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';
import 'food_database.dart';

class FoodVisionService {
  // BLIP captioning model — free on HF Inference API
  static const _captionUrl = 'https://api-inference.huggingface.co/models/Salesforce/blip-image-captioning-large';
  static const _offUrl = 'https://world.openfoodfacts.org/cgi/search.pl';

  static bool get hasApiKey => true;
  static Future<void> loadApiKey() async {}
  static Future<void> setApiKey(String key) async {}

  static Future<List<FoodItem>> analyzeImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return analyzeImageBytes(bytes);
  }

  static Future<List<FoodItem>> analyzeImageBytes(Uint8List bytes, {String mimeType = 'image/jpeg'}) async {
    // Step 1: Get image caption from BLIP
    final caption = await _getCaption(bytes);
    if (caption.isEmpty) throw Exception('Could not analyze image. Try a clearer photo.');

    // Step 2: Extract food keywords from caption
    final foods = _extractFoodKeywords(caption);
    if (foods.isEmpty) throw Exception('No food detected. Caption: "$caption"');

    // Step 3: Look up nutrition for each food
    final results = <FoodItem>[];
    for (final food in foods) {
      // Try local DB
      final local = _searchLocalDb(food);
      if (local != null) {
        results.add(FoodItem(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}_${results.length}',
          name: local.name,
          category: 'AI Detected',
          servingSize: local.servingSize, servingUnit: local.servingUnit,
          calories: local.calories, protein: local.protein,
          carbs: local.carbs, fat: local.fat,
        ));
        continue;
      }

      // Fallback: Open Food Facts
      final off = await _searchOpenFoodFacts(food);
      if (off != null) {
        results.add(FoodItem(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}_${results.length}',
          name: _formatName(food),
          category: 'AI Detected',
          servingSize: off['serving']!, servingUnit: 'g',
          calories: off['calories']!, protein: off['protein']!,
          carbs: off['carbs']!, fat: off['fat']!,
        ));
      }
    }

    if (results.isEmpty) throw Exception('Detected "$caption" but no nutrition data found.');
    return results;
  }

  /// Get caption from BLIP model
  static Future<String> _getCaption(Uint8List bytes) async {
    final response = await http.post(
      Uri.parse(_captionUrl),
      headers: {'Content-Type': 'application/octet-stream'},
      body: bytes,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 503) {
      // Model loading — wait and retry
      final body = jsonDecode(response.body);
      final wait = ((body['estimated_time'] ?? 20) as num).toDouble();
      await Future.delayed(Duration(seconds: wait.ceil().clamp(5, 30)));
      final retry = await http.post(
        Uri.parse(_captionUrl),
        headers: {'Content-Type': 'application/octet-stream'},
        body: bytes,
      ).timeout(const Duration(seconds: 60));
      if (retry.statusCode != 200) throw Exception('AI model is warming up. Try again in a minute.');
      final list = jsonDecode(retry.body) as List;
      return (list.first['generated_text'] ?? '').toString().toLowerCase();
    }

    if (response.statusCode != 200) {
      throw Exception('Image analysis failed (${response.statusCode}). Try again.');
    }

    final list = jsonDecode(response.body) as List;
    return (list.first['generated_text'] ?? '').toString().toLowerCase();
  }

  /// Extract food items from a caption like "a plate of rice with chicken curry and vegetables"
  static List<String> _extractFoodKeywords(String caption) {
    final knownFoods = [
      // Indian
      'rice', 'dal', 'daal', 'curry', 'roti', 'chapati', 'naan', 'paratha',
      'paneer', 'chicken', 'mutton', 'fish', 'egg', 'biryani', 'pulao',
      'sambar', 'rasam', 'dosa', 'idli', 'vada', 'uttapam', 'upma', 'poha',
      'chole', 'rajma', 'aloo', 'potato', 'palak', 'spinach', 'bhindi',
      'gobi', 'cauliflower', 'sabzi', 'raita', 'chutney', 'pickle',
      'samosa', 'pakora', 'tikka', 'tandoori', 'korma', 'masala',
      'kheer', 'gulab jamun', 'halwa', 'ladoo', 'jalebi', 'barfi',
      'lassi', 'chai', 'buttermilk', 'curd', 'yogurt', 'milk',
      // International
      'pizza', 'pasta', 'burger', 'sandwich', 'salad', 'soup',
      'bread', 'toast', 'cereal', 'oatmeal', 'pancake', 'waffle',
      'steak', 'sushi', 'noodles', 'fried rice', 'taco', 'burrito',
      'cake', 'cookie', 'ice cream', 'chocolate', 'fruit', 'apple',
      'banana', 'mango', 'orange', 'watermelon', 'grapes',
      'coffee', 'tea', 'juice', 'smoothie', 'water',
      'beans', 'lentils', 'tofu', 'corn', 'peas', 'carrot', 'tomato',
      'onion', 'broccoli', 'mushroom', 'pepper',
    ];

    final found = <String>[];
    // Check multi-word matches first
    final multiWord = knownFoods.where((f) => f.contains(' ')).toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    var remaining = caption;
    for (final food in multiWord) {
      if (remaining.contains(food)) {
        found.add(food);
        remaining = remaining.replaceAll(food, ' ');
      }
    }
    // Then single words
    final words = remaining.split(RegExp(r'[\s,]+'));
    for (final food in knownFoods.where((f) => !f.contains(' '))) {
      if (words.contains(food) && !found.contains(food)) {
        found.add(food);
      }
    }

    return found.take(6).toList();
  }

  static FoodItem? _searchLocalDb(String name) {
    final query = name.toLowerCase().replaceAll('_', ' ');
    final db = FoodDatabase.search('');
    for (final item in db) {
      final n = item.name.toLowerCase();
      if (n.contains(query) || query.contains(n)) return item;
    }
    final words = query.split(' ').where((w) => w.length > 3).toList();
    for (final item in db) {
      final n = item.name.toLowerCase();
      for (final word in words) {
        if (n.contains(word)) return item;
      }
    }
    return null;
  }

  static Future<Map<String, double>?> _searchOpenFoodFacts(String query) async {
    try {
      final url = '$_offUrl?search_terms=${Uri.encodeComponent(query)}&json=1&page_size=3';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body);
      final products = data['products'] as List?;
      if (products == null || products.isEmpty) return null;
      for (final p in products) {
        final n = p['nutriments'];
        if (n == null) continue;
        final cal = _d(n['energy-kcal_100g']);
        if (cal <= 0) continue;
        return {
          'serving': 100.0, 'calories': cal,
          'protein': _d(n['proteins_100g']),
          'carbs': _d(n['carbohydrates_100g']),
          'fat': _d(n['fat_100g']),
        };
      }
    } catch (_) {}
    return null;
  }

  static String _formatName(String name) => name.split(' ').map((w) =>
    w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
