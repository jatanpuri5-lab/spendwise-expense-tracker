// lib/utils/formatters.dart

import 'package:intl/intl.dart';

class Formatters {
  static String currency(double amount, {bool showSign = false}) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final formatted = formatter.format(amount.abs());
    if (showSign) {
      return amount >= 0 ? '+$formatted' : '-$formatted';
    }
    return formatted;
  }

  static String shortCurrency(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  static String date(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String dateShort(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }

  static String dateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String percentage(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
}
