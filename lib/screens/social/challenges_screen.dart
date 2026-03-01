import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/theme.dart';
import '../../models/challenge.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});
  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  List<Challenge> _active = [];
  List<Challenge> _available = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('active_challenges');
    if (raw != null) { _active = (jsonDecode(raw) as List).map((j) => Challenge.fromJson(j)).toList(); }
    _available = ChallengeTemplates.getDefaults().where((t) => !_active.any((a) => a.id == t.id)).toList();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _join(Challenge c) async {
    _active.add(Challenge(id: c.id, title: c.title, description: c.description, type: c.type, targetValue: c.targetValue, durationDays: c.durationDays, startDate: DateTime.now()));
    _available.removeWhere((a) => a.id == c.id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('active_challenges', jsonEncode(_active.map((c) => c.toJson()).toList()));
    setState(() {});
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Joined: ${c.title}!'), backgroundColor: AppTheme.primary));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Challenges')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (_active.isNotEmpty) ...[
          const Text('Active Challenges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._active.map((c) { final color = c.isCompleted ? AppTheme.primary : c.isExpired ? AppTheme.error : AppTheme.accent;
            return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(c.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(12)),
                  child: Text(c.isCompleted ? 'Done!' : c.isExpired ? 'Expired' : '${c.daysLeft}d left', style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600))),
              ]),
              const SizedBox(height: 4),
              Text(c.description, style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: c.progress, backgroundColor: Colors.grey[200], color: color, minHeight: 8)),
              const SizedBox(height: 4),
              Text('${(c.progress * 100).round()}% complete', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ]))); }),
          const SizedBox(height: 24),
        ],
        const Text('Available Challenges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (_available.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('All challenges joined!', style: TextStyle(color: AppTheme.textSecondary))))
        else
          ..._available.map((c) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
            title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text('${c.durationDays} days \u2022 ${c.description}', style: const TextStyle(fontSize: 13)),
            trailing: ElevatedButton(onPressed: () => _join(c), child: const Text('Join')),
          ))),
      ])),
    );
  }
}
