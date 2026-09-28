String formatRupees(num amount, {bool showSign = false}) {
  final absolute = amount.abs().round().toString();
  final lastThree = absolute.length > 3 ? absolute.substring(absolute.length - 3) : absolute;
  var leading = absolute.length > 3 ? absolute.substring(0, absolute.length - 3) : '';
  if (leading.isNotEmpty) {
    final groups = <String>[];
    while (leading.length > 2) {
      groups.insert(0, leading.substring(leading.length - 2));
      leading = leading.substring(0, leading.length - 2);
    }
    groups.insert(0, leading);
    leading = '${groups.join(',')},';
  }
  final sign = amount < 0 ? '-' : (showSign && amount > 0 ? '+' : '');
  return '$sign₹$leading$lastThree';
}

String formatCompactRupees(num amount) {
  if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
  if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}k';
  return '₹${amount.round()}';
}
