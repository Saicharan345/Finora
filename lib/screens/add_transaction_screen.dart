import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/finance_transaction.dart';
import '../providers/finance_store.dart';

const transactionCategories = ['Food', 'Shopping', 'Transport', 'Entertainment', 'Bills', 'Health', 'Education', 'Travel', 'Other'];

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key, this.initialIncome = false});
  final bool initialIncome;
  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _description = TextEditingController();
  final _note = TextEditingController();
  late bool _income;
  String? _category;
  DateTime _date = DateTime.now();
  bool _saving = false;
  @override
  void initState() { super.initState(); _income = widget.initialIncome; }
  @override
  void dispose() { _amount.dispose(); _description.dispose(); _note.dispose(); super.dispose(); }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime.now());
    if (selected != null) setState(() => _date = selected);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await context.read<FinanceStore>().addTransaction(FinanceTransaction(id: DateTime.now().microsecondsSinceEpoch.toString(), amount: double.parse(_amount.text.trim()), isIncome: _income, category: _income ? 'Income' : _category!, title: _description.text.trim(), date: _date, note: _note.text.trim()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_income ? 'Income' : 'Expense'} saved')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('New transaction', style: TextStyle(fontWeight: FontWeight.w800)), leading: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close_rounded))),
    body: SafeArea(child: Form(key: _formKey, child: ListView(padding: const EdgeInsets.fromLTRB(22, 8, 22, 28), children: [
      SegmentedButton<bool>(segments: const [ButtonSegment(value: false, label: Text('Expense'), icon: Icon(Icons.north_east_rounded)), ButtonSegment(value: true, label: Text('Income'), icon: Icon(Icons.south_west_rounded))], selected: {_income}, onSelectionChanged: (selection) => setState(() { _income = selection.first; _category = null; })),
      const SizedBox(height: 24), const Text('Amount', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)), const SizedBox(height: 8),
      TextFormField(controller: _amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))], decoration: const InputDecoration(prefixText: '₹  ', hintText: '0.00', hintStyle: TextStyle(fontSize: 23, fontWeight: FontWeight.w700)), style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900), validator: (value) { final amount = double.tryParse(value?.trim() ?? ''); return amount == null || amount <= 0 ? 'Enter an amount greater than zero' : null; }),
      const SizedBox(height: 20),
      if (!_income) ...[const Text('Category', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)), const SizedBox(height: 8), DropdownButtonFormField<String>(initialValue: _category, decoration: const InputDecoration(hintText: 'Choose a category'), items: transactionCategories.map((category) => DropdownMenuItem(value: category, child: Text(category))).toList(), onChanged: (value) => setState(() => _category = value), validator: (value) => value == null ? 'Choose a category' : null), const SizedBox(height: 18)],
      const Text('Description', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)), const SizedBox(height: 8), TextFormField(controller: _description, textCapitalization: TextCapitalization.sentences, decoration: const InputDecoration(hintText: 'e.g. Lunch with friends'), validator: (value) => value == null || value.trim().isEmpty ? 'Add a description' : null),
      const SizedBox(height: 18), const Text('Date', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)), const SizedBox(height: 8),
      InkWell(onTap: _pickDate, borderRadius: BorderRadius.circular(14), child: InputDecorator(decoration: const InputDecoration(prefixIcon: Icon(Icons.calendar_today_rounded, size: 18), suffixIcon: Icon(Icons.expand_more_rounded)), child: Text('${_date.day.toString().padLeft(2, '0')} ${_month(_date.month)} ${_date.year}'))),
      const SizedBox(height: 18), const Text('Note · optional', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)), const SizedBox(height: 8), TextFormField(controller: _note, textCapitalization: TextCapitalization.sentences, maxLines: 2, decoration: const InputDecoration(hintText: 'Add a little context')),
      const SizedBox(height: 26), SizedBox(height: 54, child: FilledButton.icon(onPressed: _saving ? null : _save, icon: _saving ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_rounded), label: Text(_saving ? 'Saving...' : 'Save transaction'))),
      const SizedBox(height: 12), Center(child: Text('Saved securely on this device', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11))),
    ]))),
  );
  String _month(int month) => const ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][month - 1];
}
