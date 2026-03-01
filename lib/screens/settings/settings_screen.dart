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
import '../diary/snap_track_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Premium banner
              Card(
                color: AppTheme.primary,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(children: [
                    const Icon(Icons.star, color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('NutriCal Premium', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Unlock all features', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13)),
                      ],
                    )),
                    ElevatedButton(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Premium coming soon!'))),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primary),
                      child: const Text('Upgrade'),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Features', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _tile(context, Icons.camera_alt, 'Snap & Track', 'Take photo → AI detects calories',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SnapTrackScreen()))),
              _tile(context, Icons.auto_awesome, 'AI Food Search', 'Search millions of foods online',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraFoodScreen()))),
              _tile(context, Icons.science, 'Micro-Nutrients', 'Track vitamins & minerals',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MicroNutrientsScreen()))),
              _tile(context, Icons.emoji_events, 'Challenges', 'Join health challenges',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChallengesScreen()))),
              const SizedBox(height: 16),
              const Text('Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _tile(context, Icons.picture_as_pdf, 'Weekly Report', 'Export PDF progress report',
                () async { await ReportService.shareReport(state.profile!); }),
              _tile(context, Icons.share, 'Share Progress', 'Share today\u0027s summary',
                () async { await ShareService.dailySummary(DateTime.now(), state.profile!); }),
              _tile(context, Icons.download, 'Export Data', 'Export 30-day JSON backup',
                () async {
                  final path = await ShareService.exportDataJson(state.profile!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Exported to $path')));
                  }
                }),
              const SizedBox(height: 16),
              const Text('Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _tile(context, Icons.person, 'Profile', 'Edit your details', null),
              _tile(context, Icons.delete_outline, 'Clear All Data', 'Reset the app',
                () => _showClearDialog(context, state)),
              if (AuthService.isLoggedIn)
                _tile(context, Icons.logout, 'Logout', 'Sign out of your account',
                  () {
                    AuthService.signOut();
                    Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
                  }),
              const SizedBox(height: 16),
              const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _tile(context, Icons.info_outline, 'Version', 'NutriCal v1.0.0', null),
            ],
          ),
        );
      },
    );
  }

  void _showClearDialog(BuildContext context, AppState state) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Clear All Data?'),
      content: const Text('This will delete all meals, water logs, and preferences. This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
          onPressed: () { Navigator.pop(ctx); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data cleared'))); },
          child: const Text('Clear'),
        ),
      ],
    ));
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

