import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/finance_transaction.dart';
import '../providers/finance_store.dart';
import '../theme/app_theme.dart';
import '../widgets/finance_widgets.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  String? _categoryFilter;
  bool? _typeFilter; // null = all, true = income, false = expense

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FinanceStore>();
    final theme = Theme.of(context);
    var filtered = store.transactions.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((t) =>
              t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              t.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              t.note.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply category filter
    if (_categoryFilter != null) {
      filtered =
          filtered.where((t) => t.category == _categoryFilter).toList();
    }

    // Apply type filter
    if (_typeFilter != null) {
      filtered =
          filtered.where((t) => t.isIncome == _typeFilter).toList();
    }

    // Group by date
    final grouped = <String, List<FinanceTransaction>>{};
    for (final t in filtered) {
      final key = _groupLabel(t.date);
      grouped.putIfAbsent(key, () => []).add(t);
    }

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
            sliver: SliverList.list(
              children: [
                Text(
                  'Transactions',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                // Search bar
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() => _searchQuery = '');
                            },
                            icon: const Icon(Icons.close_rounded, size: 18),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 14),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _typeFilter == null && _categoryFilter == null,
                        onSelected: () => setState(() {
                          _typeFilter = null;
                          _categoryFilter = null;
                        }),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Income',
                        selected: _typeFilter == true,
                        onSelected: () => setState(() {
                          _typeFilter = _typeFilter == true ? null : true;
                          _categoryFilter = null;
                        }),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Expense',
                        selected: _typeFilter == false,
                        onSelected: () => setState(() {
                          _typeFilter = _typeFilter == false ? null : false;
                          _categoryFilter = null;
                        }),
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(
                        height: 24,
                        child: VerticalDivider(width: 1),
                      ),
                      const SizedBox(width: 8),
                      ..._categories.map((cat) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _FilterChip(
                              label: cat,
                              selected: _categoryFilter == cat,
                              onSelected: () => setState(() {
                                _categoryFilter =
                                    _categoryFilter == cat ? null : cat;
                                _typeFilter = null;
                              }),
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Summary
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '${filtered.length} transaction${filtered.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: EmptyState(
                  title: 'No transactions found',
                  message: _searchQuery.isNotEmpty || _categoryFilter != null || _typeFilter != null
                      ? 'Try adjusting your filters or search.'
                      : 'Add your first transaction to get started.',
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
              sliver: SliverList.list(
                children: [
                  for (final entry in grouped.entries) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    ...entry.value.map(
                      (tx) => Dismissible(
                        key: ValueKey(tx.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete_rounded,
                              color: Colors.white),
                        ),
                        confirmDismiss: (direction) => _confirmDelete(context),
                        onDismissed: (_) {
                          store.deleteTransaction(tx.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('"${tx.title}" deleted'),
                              action: SnackBarAction(
                                label: 'OK',
                                onPressed: () {},
                              ),
                            ),
                          );
                        },
                        child: TransactionTile(
                          transaction: tx,
                          onDelete: () async {
                            final confirm = await _confirmDelete(context);
                            if (confirm == true) {
                              store.deleteTransaction(tx.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('"${tx.title}" deleted'),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content:
            const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade400,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _groupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) return 'TODAY';
    if (diff == 1) return 'YESTERDAY';
    if (diff < 7) {
      const days = [
        'MONDAY',
        'TUESDAY',
        'WEDNESDAY',
        'THURSDAY',
        'FRIDAY',
        'SATURDAY',
        'SUNDAY'
      ];
      return days[date.weekday - 1];
    }
    const months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static const _categories = [
    'Food',
    'Shopping',
    'Transport',
    'Entertainment',
    'Bills',
    'Health',
    'Education',
    'Travel',
    'Other',
  ];
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.accent.withValues(alpha: 0.14)
              : Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF202C26)
                  : const Color(0xFFF0F3EF),
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(color: AppTheme.accent.withValues(alpha: 0.4))
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? AppTheme.accent
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
