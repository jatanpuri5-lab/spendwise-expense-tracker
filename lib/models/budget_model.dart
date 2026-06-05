// lib/models/budget_model.dart

import 'transaction_model.dart';

class BudgetModel {
  final String id;
  final TransactionCategory category;
  final double limit;
  final double spent;

  const BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    required this.spent,
  });

  double get percentage => (spent / limit).clamp(0.0, 1.0);
  double get remaining => (limit - spent).clamp(0.0, double.infinity);
  bool get isOverBudget => spent > limit;
}
