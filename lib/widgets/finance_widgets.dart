import 'package:flutter/material.dart';

import '../models/finance_transaction.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

IconData iconForCategory(String category) => switch (category) {
      'Food' => Icons.restaurant_rounded,
      'Shopping' => Icons.shopping_bag_rounded,
      'Transport' => Icons.directions_car_filled_rounded,
      'Entertainment' => Icons.movie_rounded,
      'Bills' => Icons.receipt_long_rounded,
      'Health' => Icons.favorite_rounded,
      'Education' => Icons.menu_book_rounded,
      'Travel' => Icons.flight_takeoff_rounded,
      'Income' => Icons.south_west_rounded,
      _ => Icons.more_horiz_rounded,
    };

Color colorForCategory(String category) => switch (category) {
      'Food' => const Color(0xFFE49B5E),
      'Shopping' => const Color(0xFF6E9CC7),
      'Transport' => const Color(0xFF9A85C4),
      'Entertainment' => const Color(0xFFDA7890),
      'Bills' => const Color(0xFF6EAA91),
      'Health' => const Color(0xFFD87974),
      'Education' => const Color(0xFF7FA8A1),
      'Travel' => const Color(0xFF6BAFC3),
      'Income' => AppTheme.accent,
      _ => const Color(0xFF9A9F9C),
    };

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Row(children: [Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))), if (action != null) TextButton(onPressed: onAction, child: Text(action!))]);
}

class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction, this.onDelete});
  final FinanceTransaction transaction;
  final VoidCallback? onDelete;
  @override
  Widget build(BuildContext context) {
    final color = colorForCategory(transaction.category);
    return Padding(padding: const EdgeInsets.symmetric(vertical: 9), child: Row(children: [
      Container(width: 46, height: 46, decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(15)), child: Icon(iconForCategory(transaction.category), color: color, size: 21)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(transaction.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)), const SizedBox(height: 4), Text(transaction.category, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12))])),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('${transaction.isIncome ? '+' : '−'}${formatRupees(transaction.amount)}', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: transaction.isIncome ? AppTheme.accent : Theme.of(context).colorScheme.onSurface)), const SizedBox(height: 4), Text('${transaction.date.day.toString().padLeft(2, '0')}/${transaction.date.month.toString().padLeft(2, '0')}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11))]),
      if (onDelete != null) ...[const SizedBox(width: 4), IconButton(onPressed: onDelete, tooltip: 'Delete transaction', icon: const Icon(Icons.delete_outline_rounded, size: 20))],
    ]));
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.message});
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.receipt_long_outlined, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant), const SizedBox(height: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(message, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))]));
}
