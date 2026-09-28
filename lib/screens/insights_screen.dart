import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/finance_store.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/finance_widgets.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FinanceStore>();
    final theme = Theme.of(context);
    final insights = _generateInsights(store);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 100),
        children: [
          Text(
            'Insights',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Smart observations about your finances',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          if (insights.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 60),
              child: EmptyState(
                title: 'No insights yet',
                message:
                    'Add more transactions to unlock personalized financial insights.',
              ),
            )
          else
            ...insights.asMap().entries.map((entry) {
              final i = entry.key;
              final insight = entry.value;
              return TweenAnimationBuilder<double>(
                key: ValueKey(insight.title),
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 400 + (i * 100)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _InsightCard(insight: insight),
                ),
              );
            }),
        ],
      ),
    );
  }

  List<_Insight> _generateInsights(FinanceStore store) {
    final insights = <_Insight>[];
    final currentMonth = store.currentMonthTransactions;
    final prevMonth = store.previousMonthTransactions;

    if (currentMonth.isEmpty) return insights;

    final expenses =
        currentMonth.where((t) => !t.isIncome).toList();
    final totalSpending =
        expenses.fold<double>(0, (sum, t) => sum + t.amount);
    final totalIncome = store.monthlyIncome;

    // Highest category
    final category = store.highestSpendingCategory;
    if (category != null) {
      final amount = store.spendingByCategory[category] ?? 0;
      insights.add(_Insight(
        icon: Icons.category_rounded,
        color: colorForCategory(category),
        title: 'Top spending category',
        message:
            '$category is your highest spending category at ${formatRupees(amount)} this month.',
        type: _InsightType.info,
      ));
    }

    // Average daily
    if (expenses.isNotEmpty) {
      final avg = store.averageDailySpending;
      insights.add(_Insight(
        icon: Icons.trending_down_rounded,
        color: const Color(0xFFE49B5E),
        title: 'Daily average',
        message:
            'Your average daily spending is ${formatRupees(avg)}.',
        type: _InsightType.info,
      ));
    }

    // Budget status
    final budgetPct = store.budgetProgress;
    if (budgetPct > 1.0) {
      insights.add(_Insight(
        icon: Icons.warning_rounded,
        color: const Color(0xFFD77A6B),
        title: 'Budget exceeded!',
        message:
            'You\'ve exceeded your monthly budget of ${formatRupees(store.monthlyBudget)} by ${formatRupees(totalSpending - store.monthlyBudget)}.',
        type: _InsightType.warning,
      ));
    } else if (budgetPct > 0.8) {
      insights.add(_Insight(
        icon: Icons.info_rounded,
        color: const Color(0xFFE49B5E),
        title: 'Budget warning',
        message:
            'You\'ve used ${(budgetPct * 100).toStringAsFixed(0)}% of your monthly budget. ${formatRupees(store.remainingBudget)} remaining.',
        type: _InsightType.caution,
      ));
    } else {
      insights.add(_Insight(
        icon: Icons.check_circle_rounded,
        color: AppTheme.accent,
        title: 'On track',
        message:
            'You are within your monthly budget. ${formatRupees(store.remainingBudget)} remaining.',
        type: _InsightType.positive,
      ));
    }

    // Savings rate
    if (totalIncome > 0) {
      final savingsRate =
          ((totalIncome - totalSpending) / totalIncome * 100);
      if (savingsRate > 0) {
        insights.add(_Insight(
          icon: Icons.savings_rounded,
          color: AppTheme.accent,
          title: 'Savings rate',
          message:
              'Your savings rate is ${savingsRate.toStringAsFixed(0)}% this month. Keep it up!',
          type: _InsightType.positive,
        ));
      } else {
        insights.add(_Insight(
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFD77A6B),
          title: 'Overspending',
          message:
              'You are spending more than you earn this month. Consider reviewing your expenses.',
          type: _InsightType.warning,
        ));
      }
    }

    // Compare with prev month
    if (prevMonth.isNotEmpty) {
      final prevExpenses = prevMonth
          .where((t) => !t.isIncome)
          .fold<double>(0, (sum, t) => sum + t.amount);
      if (prevExpenses > 0) {
        final change =
            ((totalSpending - prevExpenses) / prevExpenses * 100);
        if (change > 10) {
          insights.add(_Insight(
            icon: Icons.trending_up_rounded,
            color: const Color(0xFFD77A6B),
            title: 'Spending increased',
            message:
                'Your spending is ${change.toStringAsFixed(0)}% higher than last month.',
            type: _InsightType.caution,
          ));
        } else if (change < -10) {
          insights.add(_Insight(
            icon: Icons.trending_down_rounded,
            color: AppTheme.accent,
            title: 'Great job!',
            message:
                'Your spending is ${change.abs().toStringAsFixed(0)}% lower than last month.',
            type: _InsightType.positive,
          ));
        }
      }

      // Category comparison
      final spending = store.spendingByCategory;
      for (final entry in spending.entries) {
        final prevAmt =
            store.spendingForCategory(prevMonth, entry.key);
        if (prevAmt > 0) {
          final catChange =
              ((entry.value - prevAmt) / prevAmt * 100);
          if (catChange > 20) {
            insights.add(_Insight(
              icon: iconForCategory(entry.key),
              color: colorForCategory(entry.key),
              title: '${entry.key} spending up',
              message:
                  '${entry.key} spending increased by ${catChange.toStringAsFixed(0)}% compared to last month.',
              type: _InsightType.caution,
            ));
          } else if (catChange < -20) {
            insights.add(_Insight(
              icon: iconForCategory(entry.key),
              color: colorForCategory(entry.key),
              title: 'Less on ${entry.key.toLowerCase()}',
              message:
                  'You\'ve spent ${catChange.abs().toStringAsFixed(0)}% less on ${entry.key.toLowerCase()} this month.',
              type: _InsightType.positive,
            ));
          }
        }
      }
    }

    // Transaction count
    insights.add(_Insight(
      icon: Icons.receipt_long_rounded,
      color: const Color(0xFF9A85C4),
      title: 'Activity',
      message:
          'You\'ve made ${expenses.length} expense transaction${expenses.length == 1 ? '' : 's'} this month.',
      type: _InsightType.info,
    ));

    return insights;
  }
}

enum _InsightType { positive, caution, warning, info }

class _Insight {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final _InsightType type;

  const _Insight({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.type,
  });
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});
  final _Insight insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    Color bgColor;
    switch (insight.type) {
      case _InsightType.positive:
        bgColor = dark
            ? const Color(0xFF1A2E24)
            : const Color(0xFFEAF5ED);
      case _InsightType.caution:
        bgColor = dark
            ? const Color(0xFF2E2A1A)
            : const Color(0xFFFFF3E0);
      case _InsightType.warning:
        bgColor = dark
            ? const Color(0xFF2E1A1A)
            : const Color(0xFFFFEBEE);
      case _InsightType.info:
        bgColor = dark
            ? const Color(0xFF1A2530)
            : const Color(0xFFF0F4F8);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: insight.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(insight.icon, color: insight.color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: insight.color,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  insight.message,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
