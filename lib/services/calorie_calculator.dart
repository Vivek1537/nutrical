import '../utils/constants.dart';

class CalorieCalculator {
  /// Mifflin-St Jeor BMR
  static double calculateBMR({
    required String gender,
    required double weightKg,
    required double heightCm,
    required int age,
  }) {
    if (gender == 'Male') {
      return 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else {
      return 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    }
  }

  static double calculateTDEE({required double bmr, required String activityLevel}) {
    final multiplier = AppConstants.activityMultipliers[activityLevel] ?? 1.2;
    return bmr * multiplier;
  }

  static double calculateDailyCalories({required double tdee, required String goal}) {
    switch (goal) {
      case 'Weight Loss': return tdee - 500;
      case 'Muscle Gain': return tdee + 400;
      default: return tdee;
    }
  }

  static Map<String, double> calculateMacros({
    required double calories,
    double proteinPct = 0.30,
    double carbsPct = 0.40,
    double fatPct = 0.30,
  }) {
    return {
      'protein': (calories * proteinPct) / 4, // 4 cal per gram
      'carbs': (calories * carbsPct) / 4,
      'fat': (calories * fatPct) / 9, // 9 cal per gram
    };
  }

  static double calculateWaterTarget(double weightKg) {
    return weightKg * AppConstants.waterPerKg;
  }
}
