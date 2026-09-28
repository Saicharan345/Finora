import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/finance_store.dart';
import 'screens/app_shell.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

class FinoraApp extends StatelessWidget {
  const FinoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FinanceStore>();
    return MaterialApp(
      title: 'Finora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: store.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: store.onboardingCompleted
          ? const AppShell()
          : const OnboardingScreen(),
    );
  }
}
