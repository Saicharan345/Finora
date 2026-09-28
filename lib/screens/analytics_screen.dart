import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/finance_store.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/finance_widgets.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FinanceStore>();
    final spending = store.spendingByCategory;
    final totalSpending = store.monthlySpending;
    final sortedCategories = spending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics',
            style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: sortedCategories.isEmpty
            ? const Center(
                child: EmptyState(
                  title: 'No spending data yet',
                  message:
                      'Add some expense transactions to see your analytics.',
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
                children: [
                  // Total spending card
                  _SpendingOverviewCard(
                    totalSpending: totalSpending,
                    income: store.monthlyIncome,
                    transactionCount:
                        store.currentMonthTransactions.length,
                    avgDaily: store.averageDailySpending,
                  ),
                  const SizedBox(height: 24),

                  // Donut chart
                  const SectionTitle('Category Breakdown'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: _DonutChart(
                              data: sortedCategories
                                  .map((e) => _ChartSegment(
                                        label: e.key,
                                        value: e.value,
                                        color: colorForCategory(e.key),
                                      ))
                                  .toList(),
                              total: totalSpending,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ...sortedCategories.map((e) {
                            final pct = totalSpending > 0
                                ? (e.value / totalSpending * 100)
                                : 0.0;
                            return _CategoryRow(
                              category: e.key,
                              amount: e.value,
                              percentage: pct,
                              color: colorForCategory(e.key),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Weekly spending bar chart
                  const SectionTitle('Weekly Spending'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _WeeklyBarChart(store: store),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats grid
                  const SectionTitle('Key Metrics'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.trending_down_rounded,
                          label: 'Avg. Daily',
                          value: formatRupees(store.averageDailySpending),
                          color: const Color(0xFFE49B5E),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.category_rounded,
                          label: 'Top Category',
                          value: store.highestSpendingCategory ?? '-',
                          color: const Color(0xFF6E9CC7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.receipt_rounded,
                          label: 'Transactions',
                          value: '${store.currentMonthTransactions.length}',
                          color: const Color(0xFF9A85C4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.savings_rounded,
                          label: 'Savings',
                          value: formatRupees(
                              store.monthlyIncome - store.monthlySpending),
                          color: AppTheme.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Comparison with previous month
                  _PreviousMonthComparison(store: store),
                ],
              ),
      ),
    );
  }
}

class _SpendingOverviewCard extends StatelessWidget {
  const _SpendingOverviewCard({
    required this.totalSpending,
    required this.income,
    required this.transactionCount,
    required this.avgDaily,
  });

  final double totalSpending;
  final double income;
  final int transactionCount;
  final double avgDaily;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F5947), Color(0xFF2B7A60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F5947).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOTAL MONTHLY SPENDING',
            style: TextStyle(
              color: Color(0xFFD4E5DC),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: totalSpending),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Text(
              formatRupees(value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniStat(label: 'Income', value: formatRupees(income)),
              const SizedBox(width: 24),
              _MiniStat(
                  label: 'Avg/day', value: formatRupees(avgDaily)),
              const SizedBox(width: 24),
              _MiniStat(
                  label: 'Count', value: transactionCount.toString()),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFFD4E5DC), fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _DonutChart extends StatefulWidget {
  const _DonutChart({required this.data, required this.total});
  final List<_ChartSegment> data;
  final double total;

  @override
  State<_DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<_DonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return CustomPaint(
          size: const Size(200, 200),
          painter: _DonutPainter(
            data: widget.data,
            total: widget.total,
            progress: _animation.value,
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
        );
      },
    );
  }
}

class _ChartSegment {
  final String label;
  final double value;
  final Color color;
  const _ChartSegment(
      {required this.label, required this.value, required this.color});
}

class _DonutPainter extends CustomPainter {
  final List<_ChartSegment> data;
  final double total;
  final double progress;
  final bool isDark;

  _DonutPainter({
    required this.data,
    required this.total,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 28.0;
    final rect = Rect.fromCircle(
        center: center, radius: radius - strokeWidth / 2);

    double startAngle = -math.pi / 2;

    for (final segment in data) {
      final sweepAngle =
          (segment.value / total) * 2 * math.pi * progress;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }

    // Center text
    final textPainter = TextPainter(
      text: TextSpan(
        text: formatRupees(total * progress),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : const Color(0xFF182923),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        center -
            Offset(textPainter.width / 2, textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.color,
  });

  final String category;
  final double amount;
  final double percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Icon(iconForCategory(category), size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              category,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Text(
            formatRupees(amount),
            style: const TextStyle(
                fontWeight: FontWeight.w800, fontSize: 13),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 42,
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyBarChart extends StatefulWidget {
  const _WeeklyBarChart({required this.store});
  final FinanceStore store;

  @override
  State<_WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<_WeeklyBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Build weekly data
    final expenses = widget.store.currentMonthTransactions
        .where((t) => !t.isIncome)
        .toList();

    final weekData = <int, double>{};
    for (final t in expenses) {
      final week = ((t.date.day - 1) / 7).floor() + 1;
      weekData[week] = (weekData[week] ?? 0) + t.amount;
    }

    final maxVal = weekData.values.fold<double>(
        0, (prev, v) => math.max(prev, v));

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Column(
          children: [
            SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(4, (i) {
                  final week = i + 1;
                  final value = weekData[week] ?? 0;
                  final height = maxVal > 0
                      ? (value / maxVal) * 110 * _animation.value
                      : 0.0;
                  return Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            formatCompactRupees(value * _animation.value),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: math.max(height, 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accent
                                  .withValues(alpha: 0.7 + (i * 0.1).clamp(0, 0.3)),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: Text(
                    'Week ${i + 1}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviousMonthComparison extends StatelessWidget {
  const _PreviousMonthComparison({required this.store});
  final FinanceStore store;

  @override
  Widget build(BuildContext context) {
    final prevExpenses = store.previousMonthTransactions
        .where((t) => !t.isIncome)
        .fold<double>(0, (sum, t) => sum + t.amount);

    if (prevExpenses <= 0) {
      return const SizedBox.shrink();
    }

    final currentSpending = store.monthlySpending;
    final diff = currentSpending - prevExpenses;
    final pctChange =
        prevExpenses > 0 ? (diff / prevExpenses * 100) : 0.0;
    final isUp = diff > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('vs Last Month'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (isUp ? const Color(0xFFD77A6B) : AppTheme.accent)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isUp
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color:
                        isUp ? const Color(0xFFD77A6B) : AppTheme.accent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUp
                            ? 'Spending increased'
                            : 'Spending decreased',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pctChange.abs().toStringAsFixed(0)}% ${isUp ? "more" : "less"} than last month',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${isUp ? "+" : "-"}${formatRupees(diff.abs())}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color:
                        isUp ? const Color(0xFFD77A6B) : AppTheme.accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
