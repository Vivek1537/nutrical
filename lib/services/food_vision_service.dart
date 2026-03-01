import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item.dart';

class FoodVisionService {
  static const _apiUrl = 'https://router.huggingface.co/hyperbolic/v1/chat/completions';
  static const _model = 'Qwen/Qwen2.5-VL-7B-Instruct';
  static const _prefsKey = 'hf_api_token';

  static String _token = '';

  static bool get hasApiKey => _token.isNotEmpty;

  static Future<void> loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_prefsKey) ?? '';
  }

  static Future<void> setApiKey(String key) async {
    _token = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, key);
  }

  static Future<List<FoodItem>> analyzeImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return analyzeImageBytes(bytes);
  }

  static Future<List<FoodItem>> analyzeImageBytes(Uint8List bytes, {String mimeType = 'image/jpeg'}) async {
    if (!hasApiKey) {
      throw Exception('HuggingFace token not set. Go to Settings to add your free token.');
    }

    final base64Img = base64Encode(bytes);

    final body = jsonEncode({
      'model': _model,
      'messages': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'image_url',
              'image_url': {'url': 'data:image/jpeg;base64,$base64Img'}
            },
            {
              'type': 'text',
              'text': '''Identify ALL individual food items visible in this image.
List each food SEPARATELY (do NOT group as "thali" or "plate").
For each item, estimate nutrition per typical serving.

Return ONLY a JSON array, no markdown fences, no explanation:
[{"name":"Food Name","serving_size":100,"serving_unit":"g","calories":200,"protein":10,"carbs":25,"fat":8}]

Use specific names (e.g. "Sambar" not "soup", "Jeera Rice" not "rice").
Use Indian food names where applicable.'''
            }
          ]
        }
      ],
      'max_tokens': 800,
    });

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Authorization': 'Bearer $_token',
        'Content-Type': 'application/json',
      },
      body: body,
    ).timeout(const Duration(seconds: 45));

    if (response.statusCode != 200) {
      throw Exception('AI analysis failed (${response.statusCode}). Try again.');
    }

    final data = jsonDecode(response.body);
    final content = data['choices'][0]['message']['content'] as String;

    // Parse JSON from response (strip markdown fences if present)
    var jsonStr = content.trim();
    if (jsonStr.startsWith('```')) {
      jsonStr = jsonStr.replaceAll(RegExp(r'^```\w*\n?'), '').replaceAll(RegExp(r'\n?```$'), '');
    }

    try {
      final list = jsonDecode(jsonStr.trim()) as List;
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
      throw Exception('Could not parse results. Try a clearer photo.');
    }
  }

  static double _d(dynamic v, double fallback) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? fallback;
  }
}
