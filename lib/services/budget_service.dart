// lib/services/budget_service.dart

import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import 'api_service.dart';

class BudgetService {
  BudgetService(this._api);

  final ApiService _api;

  Future<List<BudgetModel>> getBudgets() async {
    final json = await _api.get('/budgets') as List<dynamic>;
    return json
        .map((item) => _budgetFromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<BudgetModel> createBudget({
    required TransactionCategory category,
    required double limitAmount,
    required String month,
  }) async {
    final json = await _api.post('/budgets', {
      'category': category.name,
      'limitAmount': limitAmount,
      'month': month,
    }) as Map<String, dynamic>;

    return _budgetFromJson(json);
  }

  Future<BudgetModel> updateBudget({
    required String id,
    required TransactionCategory category,
    required double limitAmount,
    required String month,
  }) async {
    final json = await _api.put('/budgets/$id', {
      'category': category.name,
      'limitAmount': limitAmount,
      'month': month,
    }) as Map<String, dynamic>;

    return _budgetFromJson(json);
  }

  Future<void> deleteBudget(String id) {
    return _api.delete('/budgets/$id');
  }

  BudgetModel _budgetFromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'].toString(),
      category: _categoryFromString(json['category'] as String),
      limit: (json['limitAmount'] as num).toDouble(),
      spent: (json['spent'] as num? ?? 0).toDouble(),
    );
  }

  TransactionCategory _categoryFromString(String value) {
    return TransactionCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => TransactionCategory.other,
    );
  }
}
