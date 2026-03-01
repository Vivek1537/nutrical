import 'package:flutter/material.dart';
import 'services/food_vision_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FoodVisionService.loadApiKey();
  runApp(const NutriCalApp());
}



