// lib/models/budget_model.dart

import 'transaction_model.dart';

class BudgetModel {
  final String id;
  final int? userId;
  final TransactionCategory category;
  final double limit;
  final double spent;
  final String month;
  final DateTime? createdAt;

  const BudgetModel({
    required this.id,
    this.userId,
    required this.category,
    required this.limit,
    required this.spent,
    this.month = '',
    this.createdAt,
  });

  double get percentage => limit <= 0 ? 0.0 : (spent / limit).clamp(0.0, 1.0);
  double get remaining => (limit - spent).clamp(0.0, double.infinity);
  bool get isOverBudget => spent > limit;
}
