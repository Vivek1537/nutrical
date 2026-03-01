import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/food_item.dart';

class FoodVisionService {
  static const _apiKey = ''; // User sets this in Settings

  static String _currentKey = _apiKey;

    static Future<void> setApiKey(String key) async {
    _currentKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', key);
  }
    static bool get hasApiKey => _currentKey.isNotEmpty;

  static Future<void> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    _currentKey = prefs.getString('gemini_api_key') ?? '';
  }

  /// Analyze a food image and return detected foods with nutrition
  static Future<List<FoodItem>> analyzeImage(File imageFile) async {
    if (!hasApiKey) throw Exception('Gemini API key not set. Go to Settings > AI Food Recognition to add your free key.');

    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _currentKey,
    );

    final imageBytes = await imageFile.readAsBytes();
    final mimeType = imageFile.path.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';

    final prompt = '''Analyze this food image. Identify ALL food items visible.
For each item, estimate the nutrition per typical serving.

Return ONLY a JSON array (no markdown, no explanation), where each object has:
{
  "name": "food name",
  "serving_size": 100,
  "serving_unit": "g",
  "calories": 200,
  "protein": 10,
  "carbs": 25,
  "fat": 8,
  "confidence": 0.85
}

Rules:
- Be specific (e.g. "Paneer Butter Masala" not just "curry")
- Use Indian food names if applicable
- Estimate realistic portions visible in the image
- confidence is 0-1 (how sure you are)
- If no food is detected, return empty array []''';

    final content = Content.multi([
      TextPart(prompt),
      DataPart(mimeType, imageBytes),
    ]);

    final response = await model.generateContent([content]);
    final text = response.text ?? '';

    // Parse JSON from response
    try {
      // Strip markdown code fences if present
      var jsonStr = text.trim();
      if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.replaceAll(RegExp(r'^```\w*\n?'), '').replaceAll(RegExp(r'\n?```$'), '');
      }

      final list = jsonDecode(jsonStr) as List;
      return list.asMap().entries.map((entry) {
        final j = entry.value;
        return FoodItem(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
          name: j['name'] ?? 'Unknown Food',
          category: 'AI Detected',
          servingSize: _d(j['serving_size'], 100),
          servingUnit: j['serving_unit'] ?? 'g',
          calories: _d(j['calories'], 0),
          protein: _d(j['protein'], 0),
          carbs: _d(j['carbs'], 0),
          fat: _d(j['fat'], 0),
        );
      }).toList();
    } catch (e) {
      throw Exception('Could not parse food data from image. Try again with a clearer photo.');
    }
  }

  /// Analyze image from bytes (for web/camera)
  static Future<List<FoodItem>> analyzeImageBytes(Uint8List bytes, {String mimeType = 'image/jpeg'}) async {
    if (!hasApiKey) throw Exception('Gemini API key not set.');

    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _currentKey,
    );

    final prompt = '''Analyze this food image. Identify ALL food items visible.
For each item, estimate the nutrition per typical serving.

Return ONLY a JSON array (no markdown, no explanation), where each object has:
{
  "name": "food name",
  "serving_size": 100,
  "serving_unit": "g",
  "calories": 200,
  "protein": 10,
  "carbs": 25,
  "fat": 8,
  "confidence": 0.85
}

Be specific with Indian food names if applicable. If no food detected, return [].''';

    final content = Content.multi([
      TextPart(prompt),
      DataPart(mimeType, bytes),
    ]);

    final response = await model.generateContent([content]);
    final text = response.text ?? '';

    try {
      var jsonStr = text.trim();
      if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.replaceAll(RegExp(r'^```\w*\n?'), '').replaceAll(RegExp(r'\n?```$'), '');
      }
      final list = jsonDecode(jsonStr) as List;
      return list.asMap().entries.map((entry) {
        final j = entry.value;
        return FoodItem(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}_${entry.key}',
          name: j['name'] ?? 'Unknown Food',
          category: 'AI Detected',
          servingSize: _d(j['serving_size'], 100),
          servingUnit: j['serving_unit'] ?? 'g',
          calories: _d(j['calories'], 0),
          protein: _d(j['protein'], 0),
          carbs: _d(j['carbs'], 0),
          fat: _d(j['fat'], 0),
        );
      }).toList();
    } catch (e) {
      throw Exception('Could not parse food data. Try a clearer photo.');
    }
  }

  static double _d(dynamic v, double fallback) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }
}

