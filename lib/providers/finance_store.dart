import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/finance_transaction.dart';

class FinanceStore extends ChangeNotifier {
  static const _transactionsKey = 'finora.transactions.v1';
  static const _budgetKey = 'finora.monthlyBudget';
  static const _themeKey = 'finora.darkMode';
  static const _onboardingKey = 'finora.onboardingCompleted';
  static const openingBalance = 35838.0;

  List<FinanceTransaction> _transactions = [];
  double monthlyBudget = 50000;
  bool isDarkMode = false;
  bool onboardingCompleted = false;

  List<FinanceTransaction> get transactions => List.unmodifiable(_transactions);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    monthlyBudget = prefs.getDouble(_budgetKey) ?? 50000;
    isDarkMode = prefs.getBool(_themeKey) ?? false;
    onboardingCompleted = prefs.getBool(_onboardingKey) ?? false;
    final stored = prefs.getString(_transactionsKey);
    if (stored == null) {
      _transactions = _demoTransactions();
      await _saveTransactions();
    } else {
      try {
        _transactions = (jsonDecode(stored) as List).map((item) => FinanceTransaction.fromJson(Map<String, dynamic>.from(item as Map))).toList();
      } on Object {
        _transactions = _demoTransactions();
        await _saveTransactions();
      }
    }
  }

  List<FinanceTransaction> _demoTransactions() {
    final now = DateTime.now();
    DateTime day(int offset, [int hour = 12]) => DateTime(now.year, now.month, now.day - offset, hour);
    return [
      FinanceTransaction(id: 'demo-1', amount: 15000, isIncome: true, category: 'Income', title: 'Internship Stipend', date: day(2)),
      FinanceTransaction(id: 'demo-2', amount: 420, isIncome: false, category: 'Food', title: 'Swiggy', date: day(0, 13)),
      FinanceTransaction(id: 'demo-3', amount: 350, isIncome: false, category: 'Food', title: 'Zomato', date: day(1, 19)),
      FinanceTransaction(id: 'demo-4', amount: 280, isIncome: false, category: 'Transport', title: 'Uber', date: day(0, 9)),
      FinanceTransaction(id: 'demo-5', amount: 160, isIncome: false, category: 'Transport', title: 'Rapido', date: day(4, 10)),
      FinanceTransaction(id: 'demo-6', amount: 1299, isIncome: false, category: 'Shopping', title: 'Amazon', date: day(3)),
      FinanceTransaction(id: 'demo-7', amount: 649, isIncome: false, category: 'Entertainment', title: 'Netflix', date: day(5)),
      FinanceTransaction(id: 'demo-8', amount: 1850, isIncome: false, category: 'Bills', title: 'Electricity', date: day(8)),
      FinanceTransaction(id: 'demo-9', amount: 750, isIncome: false, category: 'Education', title: 'College Supplies', date: day(10)),
      FinanceTransaction(id: 'demo-10', amount: 2400, isIncome: false, category: 'Travel', title: 'Travel', date: day(12)),
      FinanceTransaction(id: 'demo-11', amount: 1620, isIncome: false, category: 'Food', title: 'Groceries', date: day(16)),
      FinanceTransaction(id: 'demo-12', amount: 1380, isIncome: false, category: 'Shopping', title: 'Home essentials', date: day(21)),
      FinanceTransaction(id: 'demo-13', amount: 12000, isIncome: true, category: 'Income', title: 'Part-time work', date: day(9, 15)),
      FinanceTransaction(id: 'demo-14', amount: 850, isIncome: false, category: 'Health', title: 'Pharmacy', date: day(31)),
      FinanceTransaction(id: 'demo-15', amount: 1840, isIncome: false, category: 'Food', title: 'Dining out', date: day(37)),
      FinanceTransaction(id: 'demo-16', amount: 900, isIncome: false, category: 'Transport', title: 'Cab rides', date: day(42)),
      FinanceTransaction(id: 'demo-17', amount: 2500, isIncome: false, category: 'Shopping', title: 'Clothing', date: day(46)),
    ];
  }

  List<FinanceTransaction> get currentMonthTransactions => _transactions.where((tx) => tx.date.year == DateTime.now().year && tx.date.month == DateTime.now().month).toList();

  List<FinanceTransaction> get previousMonthTransactions {
    final previous = DateTime(DateTime.now().year, DateTime.now().month - 1);
    return _transactions.where((tx) => tx.date.year == previous.year && tx.date.month == previous.month).toList();
  }

  double _sum(Iterable<FinanceTransaction> items, bool income) => items.where((tx) => tx.isIncome == income).fold(0, (sum, tx) => sum + tx.amount);
  double get monthlyIncome => _sum(currentMonthTransactions, true);
  double get monthlySpending => _sum(currentMonthTransactions, false);
  double get balance => openingBalance + _sum(_transactions, true) - _sum(_transactions, false);
  double get budgetProgress => monthlyBudget <= 0 ? 0 : monthlySpending / monthlyBudget;
  double get remainingBudget => monthlyBudget - monthlySpending;
  double get averageDailySpending => monthlySpending / DateTime.now().day;

  Map<String, double> get spendingByCategory {
    final result = <String, double>{};
    for (final tx in currentMonthTransactions.where((tx) => !tx.isIncome)) {
      result.update(tx.category, (value) => value + tx.amount, ifAbsent: () => tx.amount);
    }
    return result;
  }

  String? get highestSpendingCategory {
    if (spendingByCategory.isEmpty) return null;
    return spendingByCategory.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  double spendingForCategory(List<FinanceTransaction> items, String category) => items.where((tx) => !tx.isIncome && tx.category == category).fold(0, (sum, tx) => sum + tx.amount);

  Future<void> addTransaction(FinanceTransaction transaction) async {
    _transactions = [transaction, ..._transactions]..sort((a, b) => b.date.compareTo(a.date));
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((tx) => tx.id == id);
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> setBudget(double value) async {
    monthlyBudget = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_budgetKey, value);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    onboardingCompleted = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    notifyListeners();
  }

  Future<void> resetDemoData() async {
    _transactions = _demoTransactions();
    monthlyBudget = 50000;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_budgetKey, monthlyBudget);
    await _saveTransactions();
    notifyListeners();
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_transactionsKey, jsonEncode(_transactions.map((tx) => tx.toJson()).toList()));
  }
}
