import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';
import 'food_database.dart';

class FoodRecognitionService {
  /// Search Open Food Facts by name (free, no API key)
  static Future<List<FoodItem>> searchOnline(String query) async {
    try {
      final url = Uri.parse('https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1&page_size=10&fields=product_name,nutriments,serving_quantity,brands,categories_tags');
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final products = data['products'] as List? ?? [];
      return products.where((p) => p['product_name'] != null && p['product_name'].toString().isNotEmpty).map((p) {
        final n = p['nutriments'] ?? {};
        final serving = p['serving_quantity'] ?? 100;
        final sv = (serving is num) ? serving.toDouble() : 100.0;
        final factor = sv / 100.0;
        return FoodItem(
          id: 'off_${p['product_name'].hashCode}',
          name: p['product_name'].toString(),
          brand: p['brands']?.toString(),
          category: 'Online Result',
          servingSize: sv,
          servingUnit: 'g',
          calories: _d(n['energy-kcal_100g']) * factor,
          protein: _d(n['proteins_100g']) * factor,
          carbs: _d(n['carbohydrates_100g']) * factor,
          fat: _d(n['fat_100g']) * factor,
          fiber: _d(n['fiber_100g']) * factor,
          sugar: _d(n['sugars_100g']) * factor,
          sodium: _d(n['sodium_100g']) * factor,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Recognize food from image using device camera
  /// Returns best-guess food names for the user to confirm
  /// Uses a lightweight keyword-matching approach on local DB
  /// (Full ML model would need TFLite integration - placeholder for now)
  static Future<List<FoodItem>> recognizeFromImage(File imageFile) async {
    // In production: send to ML model (TFLite/Google Vision/custom API)
    // For MVP: return top suggestions from local DB as a demo
    // The UI will let users pick/search after camera capture
    await Future.delayed(const Duration(seconds: 1)); // simulate processing
    return FoodDatabase.search('').take(10).toList();
  }

  /// Smart search: local DB first, then online fallback
  static Future<List<FoodItem>> smartSearch(String query) async {
    final local = FoodDatabase.search(query);
    if (local.length >= 5) return local;
    final online = await searchOnline(query);
    // Merge: local first, then online (deduplicated)
    final localNames = local.map((f) => f.name.toLowerCase()).toSet();
    final merged = [...local];
    for (final f in online) {
      if (!localNames.contains(f.name.toLowerCase())) merged.add(f);
    }
    return merged;
  }

  static double _d(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
