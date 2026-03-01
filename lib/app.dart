import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/app_state.dart';
import 'navigation/main_shell.dart';
import 'screens/onboarding/onboarding_screen.dart';

class NutriCalApp extends StatelessWidget {
  const NutriCalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: MaterialApp(
        title: 'NutriCal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: Consumer<AppState>(
          builder: (context, state, _) {
            if (state.isLoading) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            if (state.profile == null) return const OnboardingScreen();
            return const MainShell();
          },
        ),
      ),
    );
  }
}
