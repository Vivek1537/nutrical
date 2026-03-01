class AppConstants {
  static const String appName = 'NutriCal';
  static const double defaultProteinPct = 0.30;
  static const double defaultCarbsPct = 0.40;
  static const double defaultFatPct = 0.30;
  static const double waterPerKg = 33.0;
  static const Map<String, double> activityMultipliers = {
    'Sedentary': 1.2,
    'Lightly Active': 1.375,
    'Moderately Active': 1.55,
    'Very Active': 1.725,
    'Extremely Active': 1.9,
  };
  static const List<String> mealTypes = ['Breakfast', 'Morning Snack', 'Lunch', 'Evening Snack', 'Dinner', 'Late Night'];
  static const List<String> goals = ['Weight Loss', 'Maintenance', 'Muscle Gain'];
  static const List<String> genders = ['Male', 'Female'];
}
