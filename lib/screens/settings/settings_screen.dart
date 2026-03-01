import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/app_state.dart';
import '../../services/auth_service.dart';
import '../../services/report_service.dart';
import '../../services/share_service.dart';
import '../auth/login_screen.dart';
import '../social/challenges_screen.dart';
import '../insights/micro_nutrients_screen.dart';
import '../diary/camera_food_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<AppState>(builder: (context, state, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Premium Banner
            Card(
              color: const Color(0xFFFFF3E0),
              child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
                Row(children: [
                  const Icon(Icons.workspace_premium, color: Colors.amber, size: 32),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('NutriCal Premium', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Unlock all features', style: TextStyle(color: AppTheme.textSecondary)),
                  ])),
                ]),
                const SizedBox(height: 12),
                const Text('\u2022 AI photo food recognition\n\u2022 Unlimited meal plans\n\u2022 Advanced micro-nutrient tracking\n\u2022 Ad-free experience\n\u2022 Priority support',
                  style: TextStyle(fontSize: 13)),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: ElevatedButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Premium coming soon!'))),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
                  child: const Text('Upgrade - Coming Soon'),
                )),
              ])),
            ),
            const SizedBox(height: 16),
            const Text('Features', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _tile(context, Icons.auto_awesome, 'AI Food Search', 'Search millions of foods online',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraFoodScreen()))),
            _tile(context, Icons.science, 'Micro-Nutrients', 'Track vitamins & minerals',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MicroNutrientsScreen()))),
            _tile(context, Icons.emoji_events, 'Challenges', 'Join health challenges',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChallengesScreen()))),
            const SizedBox(height: 16),
            const Text('Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _tile(context, Icons.picture_as_pdf, 'Weekly PDF Report', 'Export your progress',
              () { if (state.profile != null) ReportService.shareReport(state.profile!); }),
            _tile(context, Icons.share, 'Share Today', 'Share daily summary', () async {
              if (state.profile == null) return;
              await ShareService.dailySummary(DateTime.now(), state.profile!);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Summary generated!')));
            }),
            _tile(context, Icons.download, 'Export Data (JSON)', 'Export 30-day data', () async {
              if (state.profile == null) return;
              await ShareService.exportDataJson(state.profile!);
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data exported! (30 days)')));
            }),
            const SizedBox(height: 16),
            const Text('Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (AuthService.isLoggedIn) ...[
              _tile(context, Icons.email, 'Email', AuthService.email ?? 'Not set', null),
              _tile(context, Icons.logout, 'Sign Out', 'Log out of your account', () async {
                await AuthService.signOut();
              }),
            ] else
              _tile(context, Icons.login, 'Sign In', 'Sync your data across devices',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()))),
            const SizedBox(height: 16),
            const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _tile(context, Icons.info, 'NutriCal v1.0', 'AI-Powered Meal & Calorie Tracker', null),
          ],
        );
      }),
    );
  }

  Widget _tile(BuildContext ctx, IconData icon, String title, String sub, VoidCallback? onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 13)),
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }
}
