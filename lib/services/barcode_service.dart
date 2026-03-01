import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';

class BarcodeService {
  static Future<FoodItem?> lookup(String barcode) async {
    try {
      final url = Uri.parse('https://world.openfoodfacts.org/api/v2/product/$barcode.json');
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      if (data['status'] != 1) return null;

      final product = data['product'];
      final nutrients = product['nutriments'] ?? {};
      final name = product['product_name'] ?? product['product_name_en'] ?? 'Unknown Product';
      final brand = product['brands'] ?? '';
      final servingSize = product['serving_quantity'] ?? 100;

      return FoodItem(
        id: 'barcode_$barcode',
        name: name.toString(),
        brand: brand.toString().isNotEmpty ? brand.toString() : null,
        category: product['categories_tags']?.isNotEmpty == true
          ? (product['categories_tags'][0] as String).replaceAll('en:', '').replaceAll('-', ' ')
          : 'Packaged Food',
        servingSize: (servingSize is num) ? servingSize.toDouble() : 100,
        servingUnit: 'g',
        calories: _toDouble(nutrients['energy-kcal_100g'] ?? nutrients['energy-kcal_serving'] ?? 0) * (servingSize is num ? servingSize / 100 : 1),
        protein: _toDouble(nutrients['proteins_100g'] ?? 0) * (servingSize is num ? servingSize / 100 : 1),
        carbs: _toDouble(nutrients['carbohydrates_100g'] ?? 0) * (servingSize is num ? servingSize / 100 : 1),
        fat: _toDouble(nutrients['fat_100g'] ?? 0) * (servingSize is num ? servingSize / 100 : 1),
        fiber: _toDouble(nutrients['fiber_100g']),
        sugar: _toDouble(nutrients['sugars_100g']),
        sodium: _toDouble(nutrients['sodium_100g']),
        barcode: barcode,
        isVerified: true,
      );
    } catch (_) {
      return null;
    }
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
