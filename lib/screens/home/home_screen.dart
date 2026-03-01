import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_state.dart';
import '../../utils/constants.dart';
import '../diary/add_food_screen.dart';
import '../diary/snap_track_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final profile = state.profile;
        if (profile == null) return const SizedBox();
        final calTarget = profile.dailyCalorieTarget;
        final calConsumed = state.todayCalories;
        final calRemaining = calTarget - calConsumed;
        final progress = calTarget > 0 ? (calConsumed / calTarget).clamp(0.0, 1.5) : 0.0;

        return Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(title: Text('Hi, ${profile.name}!')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calorie Ring
                Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
                  const Text('Today\'s Calories', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  SizedBox(width: 160, height: 160, child: Stack(alignment: Alignment.center, children: [
                    SizedBox(width: 160, height: 160, child: CircularProgressIndicator(
                      value: progress.toDouble(), strokeWidth: 12,
                      backgroundColor: AppTheme.primary.withAlpha(30),
                      valueColor: AlwaysStoppedAnimation(calRemaining >= 0 ? AppTheme.primary : AppTheme.error),
                    )),
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('${calRemaining.round()}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold,
                        color: calRemaining >= 0 ? AppTheme.primary : AppTheme.error)),
                      Text('remaining', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    ]),
                  ])),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _calStat('Eaten', calConsumed.round(), AppTheme.accent),
                    _calStat('Target', calTarget.round(), AppTheme.primary),
                    _calStat('Left', calRemaining.round().abs(), calRemaining >= 0 ? AppTheme.secondary : AppTheme.error),
                  ]),
                ]))),
                const SizedBox(height: 16),

                // Macros
                Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Macros', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    _macroBar('Protein', state.todayProtein, profile.proteinTarget, const Color(0xFF42A5F5)),
                    const SizedBox(height: 12),
                    _macroBar('Carbs', state.todayCarbs, profile.carbsTarget, const Color(0xFFFFA726)),
                    const SizedBox(height: 12),
                    _macroBar('Fat', state.todayFat, profile.fatTarget, const Color(0xFFEF5350)),
                  ],
                ))),
                const SizedBox(height: 16),

                // Water
                Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Water Intake', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text('${(state.todayWater / 1000).toStringAsFixed(1)} / ${(profile.waterTargetMl / 1000).toStringAsFixed(1)} L',
                        style: TextStyle(color: AppTheme.textSecondary)),
                    ]),
                    const SizedBox(height: 12),
                    ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
                      value: profile.waterTargetMl > 0 ? (state.todayWater / profile.waterTargetMl).clamp(0.0, 1.0) : 0,
                      minHeight: 12, backgroundColor: Colors.blue.withAlpha(30),
                      valueColor: const AlwaysStoppedAnimation(Colors.blue),
                    )),
                    const SizedBox(height: 12),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                      _waterButton(context, '250ml', 250),
                      _waterButton(context, '500ml', 500),
                      _waterButton(context, '1L', 1000),
                    ]),
                  ],
                ))),
                const SizedBox(height: 16),

                // Today's Meals
                Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Today\'s Meals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    if (state.todayMeals.isEmpty)
                      Center(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
                        Icon(Icons.restaurant, size: 48, color: AppTheme.textSecondary.withAlpha(100)),
                        const SizedBox(height: 8),
                        Text('No meals logged yet', style: TextStyle(color: AppTheme.textSecondary)),
                      ])))
                    else
                      ...AppConstants.mealTypes.where((type) => state.getMealsByType(type).isNotEmpty).map((type) {
                        final meals = state.getMealsByType(type);
                        final totalCal = meals.fold(0.0, (sum, m) => sum + m.calories);
                        return Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text(type, style: const TextStyle(fontWeight: FontWeight.w500)),
                            Text('${totalCal.round()} kcal', style: TextStyle(color: AppTheme.textSecondary)),
                          ],
                        ));
                      }),
                  ],
                ))),
              ],
            ),
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'snap',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SnapTrackScreen())),
                backgroundColor: AppTheme.accent,
                child: const Icon(Icons.camera_alt, size: 20),
              ),
              const SizedBox(height: 8),
              FloatingActionButton.extended(
                heroTag: 'log',
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFoodScreen())),
                icon: const Icon(Icons.add),
                label: const Text('Log Meal'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _calStat(String label, int value, Color color) => Column(children: [
    Text('$value', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
  ]);

  Widget _macroBar(String name, double current, double target, Color color) {
    final pct = target > 0 ? (current / target).clamp(0.0, 1.5) : 0.0;
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text('${current.round()} / ${target.round()} g', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(
        value: pct.toDouble(), minHeight: 8,
        backgroundColor: color.withAlpha(40), valueColor: AlwaysStoppedAnimation(color),
      )),
    ]);
  }

  Widget _waterButton(BuildContext context, String label, double ml) => OutlinedButton.icon(
    onPressed: () => context.read<AppState>().addWater(ml),
    icon: const Icon(Icons.water_drop, size: 16),
    label: Text(label),
    style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
  );
}
