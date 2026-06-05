// lib/models/transaction_model.dart

import 'package:flutter/material.dart';

enum TransactionType { income, expense }

enum TransactionCategory {
  food,
  shopping,
  transport,
  bills,
  health,
  entertainment,
  salary,
  investment,
  other,
}

extension TransactionCategoryExtension on TransactionCategory {
  String get label {
    switch (this) {
      case TransactionCategory.food:
        return 'Food';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.bills:
        return 'Bills';
      case TransactionCategory.health:
        return 'Health';
      case TransactionCategory.entertainment:
        return 'Entertainment';
      case TransactionCategory.salary:
        return 'Salary';
      case TransactionCategory.investment:
        return 'Investment';
      case TransactionCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionCategory.food:
        return Icons.restaurant_rounded;
      case TransactionCategory.shopping:
        return Icons.shopping_bag_rounded;
      case TransactionCategory.transport:
        return Icons.directions_car_rounded;
      case TransactionCategory.bills:
        return Icons.receipt_long_rounded;
      case TransactionCategory.health:
        return Icons.favorite_rounded;
      case TransactionCategory.entertainment:
        return Icons.movie_rounded;
      case TransactionCategory.salary:
        return Icons.account_balance_wallet_rounded;
      case TransactionCategory.investment:
        return Icons.trending_up_rounded;
      case TransactionCategory.other:
        return Icons.category_rounded;
    }
  }

  Color get color {
    switch (this) {
      case TransactionCategory.food:
        return const Color(0xFFFF6B6B);
      case TransactionCategory.shopping:
        return const Color(0xFF845EF7);
      case TransactionCategory.transport:
        return const Color(0xFF339AF0);
      case TransactionCategory.bills:
        return const Color(0xFFFF922B);
      case TransactionCategory.health:
        return const Color(0xFFFF6B9D);
      case TransactionCategory.entertainment:
        return const Color(0xFF20C997);
      case TransactionCategory.salary:
        return const Color(0xFF51CF66);
      case TransactionCategory.investment:
        return const Color(0xFF74C0FC);
      case TransactionCategory.other:
        return const Color(0xFFADB5BD);
    }
  }
}

class TransactionModel {
  final String id;
  final int? userId;
  final String title;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final String? notes;
  final String? paymentMethod;
  final DateTime? createdAt;

  const TransactionModel({
    required this.id,
    this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.notes,
    this.paymentMethod,
    this.createdAt,
  });
}
