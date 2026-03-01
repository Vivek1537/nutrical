import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';
import 'food_database.dart';

class FoodVisionService {
  // Public HF Inference API — no key needed for public models
  static const _hfUrl = 'https://api-inference.huggingface.co/models/nateraw/food';
  static const _offUrl = 'https://world.openfoodfacts.org/cgi/search.pl';

  static bool get hasApiKey => true; // No key needed

  static Future<void> loadApiKey() async {} // No-op
  static Future<void> setApiKey(String key) async {} // No-op

  /// Analyze food image → returns detected foods with nutrition
  static Future<List<FoodItem>> analyzeImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return analyzeImageBytes(bytes);
  }

  /// Analyze from bytes
  static Future<List<FoodItem>> analyzeImageBytes(Uint8List bytes, {String mimeType = 'image/jpeg'}) async {
    // Step 1: Classify food using HF model
    final classifications = await _classifyFood(bytes);
    if (classifications.isEmpty) {
      throw Exception('No food detected in this image. Try a clearer photo.');
    }

    // Step 2: For top results, look up nutrition
    final results = <FoodItem>[];
    for (final entry in classifications.take(5)) {
      final name = entry['label'] as String;
      final confidence = (entry['score'] as num).toDouble();
      if (confidence < 0.05) continue; // Skip very low confidence

      // Try local DB first
      final localMatch = _searchLocalDb(name);
      if (localMatch != null) {
        results.add(FoodItem(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}_${results.length}',
          name: _formatName(name),
          category: 'AI Detected (${(confidence * 100).round()}%)',
          servingSize: localMatch.servingSize,
          servingUnit: localMatch.servingUnit,
          calories: localMatch.calories,
          protein: localMatch.protein,
          carbs: localMatch.carbs,
          fat: localMatch.fat,
        ));
        continue;
      }

      // Fallback: Open Food Facts search
      final offMatch = await _searchOpenFoodFacts(name);
      if (offMatch != null) {
        results.add(FoodItem(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}_${results.length}',
          name: _formatName(name),
          category: 'AI Detected (${(confidence * 100).round()}%)',
          servingSize: offMatch['serving'] ?? 100,
          servingUnit: 'g',
          calories: offMatch['calories'] ?? 0,
          protein: offMatch['protein'] ?? 0,
          carbs: offMatch['carbs'] ?? 0,
          fat: offMatch['fat'] ?? 0,
        ));
        continue;
      }

      // Still add with name even without nutrition
      results.add(FoodItem(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}_${results.length}',
        name: _formatName(name),
        category: 'AI Detected (${(confidence * 100).round()}%)',
        servingSize: 100,
        servingUnit: 'g',
        calories: 0, protein: 0, carbs: 0, fat: 0,
      ));
    }

    if (results.isEmpty) {
      throw Exception('Could not identify any food. Try another photo.');
    }
    return results;
  }

  /// Call HF Inference API
  static Future<List<Map<String, dynamic>>> _classifyFood(Uint8List bytes) async {
    final response = await http.post(
      Uri.parse(_hfUrl),
      headers: {'Content-Type': 'application/octet-stream'},
      body: bytes,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 503) {
      // Model loading — retry once after delay
      final body = jsonDecode(response.body);
      final wait = (body['estimated_time'] ?? 20).toDouble();
      await Future.delayed(Duration(seconds: wait.ceil().clamp(5, 30)));
      final retry = await http.post(
        Uri.parse(_hfUrl),
        headers: {'Content-Type': 'application/octet-stream'},
        body: bytes,
      ).timeout(const Duration(seconds: 60));
      if (retry.statusCode != 200) throw Exception('AI model is loading. Please try again in a minute.');
      return List<Map<String, dynamic>>.from(jsonDecode(retry.body));
    }

    if (response.statusCode != 200) {
      throw Exception('Food recognition failed (${response.statusCode}). Try again.');
    }

    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }

  /// Search local food database
  static FoodItem? _searchLocalDb(String name) {
    final query = name.toLowerCase().replaceAll('_', ' ');
    final db = FoodDatabase.search('');
    // Exact-ish match
    for (final item in db) {
      if (item.name.toLowerCase().contains(query) || query.contains(item.name.toLowerCase())) {
        return item;
      }
    }
    // Word match
    final words = query.split(' ').where((w) => w.length > 3).toList();
    for (final item in db) {
      final itemLower = item.name.toLowerCase();
      for (final word in words) {
        if (itemLower.contains(word)) return item;
      }
    }
    return null;
  }

  /// Search Open Food Facts for nutrition data
  static Future<Map<String, double>?> _searchOpenFoodFacts(String query) async {
    try {
      final url = '$_offUrl?search_terms=${Uri.encodeComponent(query)}&json=1&page_size=3';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final products = data['products'] as List?;
      if (products == null || products.isEmpty) return null;

      // Find first product with nutrition data
      for (final p in products) {
        final n = p['nutriments'];
        if (n == null) continue;
        final cal = _d(n['energy-kcal_100g']);
        if (cal <= 0) continue;
        return {
          'serving': 100.0,
          'calories': cal,
          'protein': _d(n['proteins_100g']),
          'carbs': _d(n['carbohydrates_100g']),
          'fat': _d(n['fat_100g']),
        };
      }
    } catch (_) {}
    return null;
  }

  static String _formatName(String name) {
    return name.replaceAll('_', ' ').split(' ').map((w) =>
      w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}'
    ).join(' ');
  }

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

