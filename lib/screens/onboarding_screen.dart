import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/finance_store.dart';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  Future<void> _finish() => context.read<FinanceStore>().completeOnboarding();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(body: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(26, 12, 26, 22), child: Column(children: [
      Row(children: [Container(width: 34, height: 34, decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.auto_graph_rounded, color: Colors.white, size: 20)), const SizedBox(width: 9), const Text('finora', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 21)), const Spacer(), TextButton(onPressed: _finish, child: const Text('Skip'))]),
      Expanded(child: PageView(controller: _controller, onPageChanged: (value) => setState(() => _page = value), children: [
        _OnboardingPage(dark: dark, icon: Icons.account_balance_wallet_rounded, title: 'Track smarter.\nSpend better.', subtitle: 'Understand your spending, manage your budget, and make better financial decisions.'),
        _OnboardingPage(dark: dark, icon: Icons.insights_rounded, title: 'See the story\nin your spending.', subtitle: 'Turn everyday transactions into clear insights and calmer financial habits.'),
        _OnboardingPage(dark: dark, icon: Icons.lock_rounded, title: 'Your money.\nYour device.', subtitle: 'Finora works offline. Your personal finance data stays stored locally on this device.'),
      ])),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (index) => AnimatedContainer(duration: const Duration(milliseconds: 250), margin: const EdgeInsets.symmetric(horizontal: 4), width: _page == index ? 24 : 7, height: 7, decoration: BoxDecoration(color: _page == index ? AppTheme.accent : AppTheme.accent.withValues(alpha: .22), borderRadius: BorderRadius.circular(9))))),
      const SizedBox(height: 22),
      SizedBox(width: double.infinity, height: 54, child: FilledButton(onPressed: () async { if (_page == 2) { await _finish(); } else { await _controller.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic); } }, child: Text(_page == 2 ? 'Get started' : 'Continue'))),
    ]))));
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.dark, required this.icon, required this.title, required this.subtitle});
  final bool dark;
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 230, height: 230, decoration: BoxDecoration(color: dark ? const Color(0xFF20352C) : const Color(0xFFE5F0E8), shape: BoxShape.circle), child: Stack(alignment: Alignment.center, children: [
      Container(width: 168, height: 168, decoration: BoxDecoration(color: dark ? const Color(0xFF294B3D) : const Color(0xFFD3E9D8), shape: BoxShape.circle)),
      Container(width: 112, height: 112, decoration: BoxDecoration(color: AppTheme.accent, borderRadius: BorderRadius.circular(34), boxShadow: [BoxShadow(color: AppTheme.accent.withValues(alpha: .24), blurRadius: 24, offset: const Offset(0, 12))]), child: Icon(icon, size: 54, color: Colors.white)),
      Positioned(right: 28, top: 30, child: _bubble(Icons.north_east_rounded)), Positioned(left: 24, bottom: 36, child: _bubble(Icons.currency_rupee_rounded)),
    ])),
    const SizedBox(height: 44),
    Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, height: 1.12)),
    const SizedBox(height: 14),
    Text(subtitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.5)),
  ]);
  Widget _bubble(IconData icon) => Container(width: 40, height: 40, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: Icon(icon, color: AppTheme.accent, size: 20));
}
