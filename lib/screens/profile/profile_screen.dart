import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_state.dart';
import '../../services/auth_service.dart';
import '../../services/report_service.dart';
import '../settings/settings_screen.dart';
import '../social/challenges_screen.dart';
import '../insights/micro_nutrients_screen.dart';
import '../diary/camera_food_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final p = state.profile;
        if (p == null) return const SizedBox();
        return Scaffold(
          backgroundColor: AppTheme.bg,
          appBar: AppBar(title: const Text('Profile'), actions: [
            IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
          ]),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(children: [
                    CircleAvatar(radius: 40, backgroundColor: AppTheme.primary,
                      child: Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 12),
                    Text(p.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(p.goal, style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w500)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Personal Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    _infoRow(Icons.person, 'Gender', p.gender),
                    _infoRow(Icons.cake, 'Age', '${p.age} years'),
                    _infoRow(Icons.height, 'Height', '${p.heightCm.round()} cm'),
                    _infoRow(Icons.monitor_weight, 'Weight', '${p.weightKg} kg'),
                    if (p.targetWeightKg != null) _infoRow(Icons.flag, 'Target', '${p.targetWeightKg} kg'),
                    _infoRow(Icons.directions_run, 'Activity', p.activityLevel),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Daily Targets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    _infoRow(Icons.local_fire_department, 'Calories', '${p.dailyCalorieTarget.round()} kcal'),
                    _infoRow(Icons.egg, 'Protein', '${p.proteinTarget.round()} g'),
                    _infoRow(Icons.grain, 'Carbs', '${p.carbsTarget.round()} g'),
                    _infoRow(Icons.water_drop, 'Fat', '${p.fatTarget.round()} g'),
                    _infoRow(Icons.local_drink, 'Water', '${(p.waterTargetMl / 1000).toStringAsFixed(1)} L'),
                  ]),
                ),
              ),
              const SizedBox(height: 24),
              // Quick Features
Card(
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Features', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      ListTile(dense: true, contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.auto_awesome, color: AppTheme.primary),
        title: const Text('AI Food Search'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraFoodScreen()))),
      ListTile(dense: true, contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.science, color: AppTheme.primary),
        title: const Text('Micro-Nutrients'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MicroNutrientsScreen()))),
      ListTile(dense: true, contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.emoji_events, color: AppTheme.primary),
        title: const Text('Challenges'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChallengesScreen()))),
    ]),
  ),
),
const SizedBox(height: 16),
// Reports
Card(
  child: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Reports', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(
        onPressed: () => ReportService.shareReport(p),
        icon: const Icon(Icons.picture_as_pdf),
        label: const Text('Export Weekly Report (PDF)'),
      )),
      const SizedBox(height: 8),
      SizedBox(width: double.infinity, child: OutlinedButton.icon(
        onPressed: () => ReportService.printReport(p),
        icon: const Icon(Icons.print),
        label: const Text('Print Weekly Report'),
      )),
    ]),
  ),
),
const SizedBox(height: 16),
if (AuthService.isLoggedIn)
                SizedBox(width: double.infinity, child: OutlinedButton.icon(
                  onPressed: () => AuthService.signOut(),
                  icon: const Icon(Icons.logout, color: AppTheme.error),
                  label: const Text('Sign Out', style: TextStyle(color: AppTheme.error)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.error)),
                )),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(children: [
      Icon(icon, size: 20, color: AppTheme.primary),
      const SizedBox(width: 12),
      Text(label, style: TextStyle(color: AppTheme.textSecondary)),
      const Spacer(),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
    ]),
  );
}


