import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/finance_store.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/finance_widgets.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FinanceStore>();
    final theme = Theme.of(context);
    final progress = store.budgetProgress;
    final spent = store.monthlySpending;
    final budget = store.monthlyBudget;
    final remaining = store.remainingBudget;

    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    if (progress * 100 < 70) {
      statusColor = AppTheme.accent;
      statusLabel = 'Healthy';
      statusIcon = Icons.check_circle_rounded;
    } else if (progress * 100 < 80) {
      statusColor = const Color(0xFFE49B5E);
      statusLabel = 'Caution';
      statusIcon = Icons.info_rounded;
    } else if (progress * 100 <= 100) {
      statusColor = const Color(0xFFD77A6B);
      statusLabel = 'Warning';
      statusIcon = Icons.warning_rounded;
    } else {
      statusColor = const Color(0xFFD32F2F);
      statusLabel = 'Exceeded';
      statusIcon = Icons.error_rounded;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget',
            style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
          children: [
            // Progress ring card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    SizedBox(
                      width: 180,
                      height: 180,
                      child: _AnimatedRing(
                        progress: progress.clamp(0, 1),
                        color: statusColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(progress * 100).round()}%',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: statusColor,
                              ),
                            ),
                            Text(
                              'used',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon,
                              color: statusColor, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Breakdown
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    label: 'Monthly Budget',
                    value: formatRupees(budget),
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    label: 'Spent',
                    value: formatRupees(spent),
                    icon: Icons.north_east_rounded,
                    color: const Color(0xFFD77A6B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoTile(
                    label: 'Remaining',
                    value: formatRupees(remaining.abs()),
                    icon: remaining >= 0
                        ? Icons.south_west_rounded
                        : Icons.warning_rounded,
                    color: remaining >= 0
                        ? AppTheme.accent
                        : const Color(0xFFD32F2F),
                    subtitle: remaining < 0 ? 'Over budget' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Category-wise spending against budget
            const SectionTitle('Spending by Category'),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (store.spendingByCategory.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('No expense data yet',
                            style: TextStyle(fontSize: 13)),
                      )
                    else
                      ...(store.spendingByCategory.entries.toList()
                            ..sort(
                                (a, b) => b.value.compareTo(a.value)))
                          .map((e) {
                        final catPct = budget > 0
                            ? (e.value / budget)
                            : 0.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    iconForCategory(e.key),
                                    color: colorForCategory(e.key),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      e.key,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13),
                                    ),
                                  ),
                                  Text(
                                    formatRupees(e.value),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(4),
                                child:
                                    TweenAnimationBuilder<double>(
                                  tween: Tween(
                                      begin: 0,
                                      end: catPct.clamp(0.0, 1.0)),
                                  duration: const Duration(
                                      milliseconds: 600),
                                  builder: (context, value, _) =>
                                      LinearProgressIndicator(
                                    value: value,
                                    minHeight: 5,
                                    backgroundColor:
                                        colorForCategory(e.key)
                                            .withValues(alpha: 0.1),
                                    color:
                                        colorForCategory(e.key),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Edit budget
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () => _showEditBudgetDialog(context, store),
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Edit Monthly Budget'),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: AppTheme.accent.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBudgetDialog(
      BuildContext context, FinanceStore store) {
    final controller = TextEditingController(
        text: store.monthlyBudget.round().toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Monthly Budget',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: false),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly
          ],
          decoration: const InputDecoration(
            prefixText: '₹  ',
            hintText: '50000',
          ),
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.w900),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value =
                  double.tryParse(controller.text.trim());
              if (value != null && value > 0) {
                store.setBudget(value);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Budget updated to ${formatRupees(value)}')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _AnimatedRing extends StatefulWidget {
  const _AnimatedRing({
    required this.progress,
    required this.color,
    required this.child,
  });

  final double progress;
  final Color color;
  final Widget child;

  @override
  State<_AnimatedRing> createState() => _AnimatedRingState();
}

class _AnimatedRingState extends State<_AnimatedRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedRing old) {
    super.didUpdateWidget(old);
    if (old.progress != widget.progress) {
      _controller.forward(from: 0);
    }
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
          painter: _RingPainter(
            progress: widget.progress * _animation.value,
            color: widget.color,
            backgroundColor: widget.color.withValues(alpha: 0.1),
          ),
          child: Center(child: widget.child),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 14.0;
    final rect = Rect.fromCircle(
        center: center, radius: radius - strokeWidth / 2);

    // Background
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 20),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
