import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/finance_store.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/finance_widgets.dart';
import 'add_transaction_screen.dart';
import 'analytics_screen.dart';
import 'budget_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onNavigate});
  final ValueChanged<int> onNavigate;
  @override
  Widget build(BuildContext context) {
    final store = context.watch<FinanceStore>();
    final recent = store.transactions.take(5).toList();
    return SafeArea(child: CustomScrollView(slivers: [SliverPadding(padding: const EdgeInsets.fromLTRB(22, 16, 22, 26), sliver: SliverList.list(children: [
      Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${_month(DateTime.now().month).toUpperCase()} ${DateTime.now().day}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1)), const SizedBox(height: 7), Text('Good evening,\nSaicharan', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.12))])), const CircleAvatar(radius: 23, backgroundColor: Color(0xFFDCECE1), child: Text('S', style: TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w900, fontSize: 18)))]),
      const SizedBox(height: 23), _BalanceCard(balance: store.balance), const SizedBox(height: 15),
      Row(children: [Expanded(child: _SummaryTile(label: 'INCOME', amount: store.monthlyIncome, icon: Icons.south_west_rounded, positive: true)), const SizedBox(width: 11), Expanded(child: _SummaryTile(label: 'SPENDING', amount: store.monthlySpending, icon: Icons.north_east_rounded))]),
      const SizedBox(height: 12), _BudgetStrip(spent: store.monthlySpending, budget: store.monthlyBudget, progress: store.budgetProgress, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const BudgetScreen()))),
      const SizedBox(height: 27), const SectionTitle('Quick actions'), const SizedBox(height: 9),
      Row(children: [
        _QuickAction(icon: Icons.remove_rounded, label: 'Expense', color: const Color(0xFFD77A6B), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AddTransactionScreen()))),
        _QuickAction(icon: Icons.add_rounded, label: 'Income', color: AppTheme.accent, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AddTransactionScreen(initialIncome: true)))),
        _QuickAction(icon: Icons.bar_chart_rounded, label: 'Analytics', color: const Color(0xFF6D8AA8), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AnalyticsScreen()))),
      ]),
      const SizedBox(height: 26), SectionTitle('Recent transactions', action: 'See all', onAction: () => onNavigate(1)), const SizedBox(height: 4),
      if (recent.isEmpty) const EmptyState(title: 'Nothing here yet', message: 'Add your first transaction to start seeing your money clearly.') else ...recent.map((tx) => TransactionTile(transaction: tx)),
      const SizedBox(height: 12), _SmartInsight(store: store), const SizedBox(height: 90),
    ]))]));
  }
  static String _month(int month) => const ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][month - 1];
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});
  final double balance;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: const Color(0xFF1F5947), borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: const Color(0xFF1F5947).withValues(alpha: .17), blurRadius: 24, offset: const Offset(0, 12))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [const Text('TOTAL BALANCE', style: TextStyle(color: Color(0xFFD4E5DC), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2)), const Spacer(), Icon(Icons.more_horiz_rounded, color: Colors.white.withValues(alpha: .75))]), const SizedBox(height: 11),
    TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: balance), duration: const Duration(milliseconds: 850), curve: Curves.easeOutCubic, builder: (context, value, _) => Text(formatRupees(value), style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900))), const SizedBox(height: 17),
    Row(children: [Icon(Icons.trending_up_rounded, size: 15, color: AppTheme.lime), const SizedBox(width: 6), const Text('Available across all your accounts', style: TextStyle(color: Color(0xFFD4E5DC), fontSize: 11))]),
  ]));
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.amount, required this.icon, this.positive = false});
  final String label; final double amount; final IconData icon; final bool positive;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: positive ? AppTheme.accent : const Color(0xFFD77A6B), size: 16), const SizedBox(width: 7), Text(label, style: TextStyle(fontSize: 9, letterSpacing: .8, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurfaceVariant))]), const SizedBox(height: 10), FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown, child: Text(formatRupees(amount), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)))])));
}

class _BudgetStrip extends StatelessWidget {
  const _BudgetStrip({required this.spent, required this.budget, required this.progress, required this.onTap});
  final double spent, budget, progress; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(18), child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    Row(children: [const Icon(Icons.savings_outlined, size: 18, color: AppTheme.accent), const SizedBox(width: 8), const Expanded(child: Text('Monthly budget', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13))), Text('${(progress * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.accent)), const Icon(Icons.chevron_right_rounded, size: 19)]), const SizedBox(height: 12),
    ClipRRect(borderRadius: BorderRadius.circular(8), child: TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: progress.clamp(0, 1)), duration: const Duration(milliseconds: 700), builder: (context, value, _) => LinearProgressIndicator(value: value, minHeight: 8, backgroundColor: AppTheme.accent.withValues(alpha: .12), color: progress > .8 ? const Color(0xFFD77A6B) : AppTheme.accent))), const SizedBox(height: 8),
    Row(children: [Text('${formatRupees(spent)} spent', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)), const Spacer(), Text('of ${formatRupees(budget)}', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant))]),
  ]))));
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 10), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16), child: Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Column(children: [Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: color)), const SizedBox(height: 8), Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))]))))));
}

class _SmartInsight extends StatelessWidget {
  const _SmartInsight({required this.store});
  final FinanceStore store;
  @override
  Widget build(BuildContext context) {
    final category = store.highestSpendingCategory;
    final lastFood = store.spendingForCategory(store.previousMonthTransactions, 'Food');
    final thisFood = store.spendingForCategory(store.currentMonthTransactions, 'Food');
    final message = category == null ? 'Your spending patterns will appear here as you add transactions.' : lastFood > 0 && thisFood < lastFood ? 'You have spent ${formatRupees(lastFood - thisFood)} less on food than last month.' : '$category is your highest spending category this month at ${formatRupees(store.spendingByCategory[category] ?? 0)}.';
    return Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF20352C) : const Color(0xFFEAF1E7), borderRadius: BorderRadius.circular(18)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 35, height: 35, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .8), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.accent, size: 18)), const SizedBox(width: 11), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('A little insight', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.accent)), const SizedBox(height: 5), Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.4, fontSize: 12))]))]));
  }
}
