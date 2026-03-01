import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../utils/constants.dart';
import '../../models/user_profile.dart';
import '../../services/calorie_calculator.dart';
import '../../providers/app_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();

  String _gender = 'Male';
  String _activityLevel = 'Moderately Active';
  String _goal = 'Maintenance';

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _finish() {
    final age = int.tryParse(_ageController.text) ?? 25;
    final height = double.tryParse(_heightController.text) ?? 170;
    final weight = double.tryParse(_weightController.text) ?? 70;
    final targetWeight = double.tryParse(_targetWeightController.text);

    final bmr = CalorieCalculator.calculateBMR(gender: _gender, weightKg: weight, heightCm: height, age: age);
    final tdee = CalorieCalculator.calculateTDEE(bmr: bmr, activityLevel: _activityLevel);
    final dailyCal = CalorieCalculator.calculateDailyCalories(tdee: tdee, goal: _goal);
    final macros = CalorieCalculator.calculateMacros(calories: dailyCal);
    final water = CalorieCalculator.calculateWaterTarget(weight);

    final profile = UserProfile(
      name: _nameController.text.isEmpty ? 'User' : _nameController.text,
      age: age, gender: _gender, heightCm: height, weightKg: weight,
      targetWeightKg: targetWeight, activityLevel: _activityLevel, goal: _goal,
      dailyCalorieTarget: dailyCal.roundToDouble(),
      proteinTarget: macros['protein']!.roundToDouble(),
      carbsTarget: macros['carbs']!.roundToDouble(),
      fatTarget: macros['fat']!.roundToDouble(),
      waterTargetMl: water.roundToDouble(),
    );

    context.read<AppState>().setProfile(profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Progress dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 24 : 8, height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == i ? AppTheme.primary : AppTheme.primary.withAlpha(77),
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                physics: const NeverScrollableScrollPhysics(),
                children: [_welcomePage(), _bodyPage(), _activityPage(), _goalPage()],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(_currentPage < 3 ? 'Continue' : 'Get Started'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _welcomePage() => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.restaurant_menu, size: 80, color: AppTheme.primary),
        const SizedBox(height: 24),
        const Text('Welcome to NutriCal', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('AI-Powered Meal & Calorie Tracker', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
        const SizedBox(height: 40),
        TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Your Name', prefixIcon: Icon(Icons.person))),
      ],
    ),
  );

  Widget _bodyPage() => Padding(
    padding: const EdgeInsets.all(24),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('About You', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('We need this to calculate your daily targets', style: TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 24),
          // Gender
          const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: AppConstants.genders.map((g) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: SizedBox(width: double.infinity, child: Center(child: Text(g))),
                selected: _gender == g,
                onSelected: (_) => setState(() => _gender = g),
                selectedColor: AppTheme.primary.withAlpha(51),
              ),
            ),
          )).toList()),
          const SizedBox(height: 16),
          TextField(controller: _ageController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Age', prefixIcon: Icon(Icons.cake), suffixText: 'years')),
          const SizedBox(height: 16),
          TextField(controller: _heightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Height', prefixIcon: Icon(Icons.height), suffixText: 'cm')),
          const SizedBox(height: 16),
          TextField(controller: _weightController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Weight', prefixIcon: Icon(Icons.monitor_weight), suffixText: 'kg')),
        ],
      ),
    ),
  );

  Widget _activityPage() => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Activity Level', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('How active are you on a typical day?', style: TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 24),
        ...AppConstants.activityMultipliers.keys.map((level) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Card(
            color: _activityLevel == level ? AppTheme.primary.withAlpha(26) : AppTheme.surface,
            child: ListTile(
              title: Text(level, style: TextStyle(fontWeight: _activityLevel == level ? FontWeight.bold : FontWeight.normal)),
              trailing: _activityLevel == level ? const Icon(Icons.check_circle, color: AppTheme.primary) : null,
              onTap: () => setState(() => _activityLevel = level),
            ),
          ),
        )),
      ],
    ),
  );

  Widget _goalPage() => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Goal', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('What do you want to achieve?', style: TextStyle(color: AppTheme.textSecondary)),
        const SizedBox(height: 24),
        ...AppConstants.goals.map((goal) {
          final icons = {'Weight Loss': Icons.trending_down, 'Maintenance': Icons.balance, 'Muscle Gain': Icons.fitness_center};
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              color: _goal == goal ? AppTheme.primary.withAlpha(26) : AppTheme.surface,
              child: ListTile(
                leading: Icon(icons[goal], color: _goal == goal ? AppTheme.primary : AppTheme.textSecondary),
                title: Text(goal, style: TextStyle(fontWeight: _goal == goal ? FontWeight.bold : FontWeight.normal)),
                trailing: _goal == goal ? const Icon(Icons.check_circle, color: AppTheme.primary) : null,
                onTap: () => setState(() => _goal = goal),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        if (_goal != 'Maintenance')
          TextField(controller: _targetWeightController, keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Target Weight', prefixIcon: const Icon(Icons.flag), suffixText: 'kg')),
      ],
    ),
  );

  @override
  void dispose() {
    _pageController.dispose(); _nameController.dispose(); _ageController.dispose();
    _heightController.dispose(); _weightController.dispose(); _targetWeightController.dispose();
    super.dispose();
  }
}
