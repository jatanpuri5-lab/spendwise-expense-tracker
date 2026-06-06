// lib/services/budget_service.dart

import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import 'api_service.dart';

class BudgetService {
  BudgetService(this._api);

  final ApiService _api;

  Future<List<BudgetModel>> getBudgets() async {
    final json = await _api.get('/budgets');
    final items = _listFromJson(json);
    return items
        .map((item) => _budgetFromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<BudgetModel> createBudget({
    required TransactionCategory category,
    required double limitAmount,
    required String month,
  }) async {
    final json = await _api.post('/budgets', {
      'category': category.label,
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
      'category': category.label,
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
      userId: _intFromJson(json['userId'] ?? json['user_id']),
      category: _categoryFromString(json['category']?.toString() ?? ''),
      limit: _doubleFromJson(json['limitAmount'] ?? json['limit_amount']),
      spent: _doubleFromJson(json['spent']),
      month: json['month']?.toString() ?? '',
      createdAt: _nullableDateFromJson(json['createdAt'] ?? json['created_at']),
    );
  }

  TransactionCategory _categoryFromString(String value) {
    final normalized = value.trim().toLowerCase().replaceAll(' ', '');
    return TransactionCategory.values.firstWhere(
      (category) =>
          category.name == normalized ||
          category.label.toLowerCase().replaceAll(' ', '') == normalized,
      orElse: () => TransactionCategory.other,
    );
  }

  List<dynamic> _listFromJson(dynamic json) {
    if (json is List<dynamic>) {
      return json;
    }

    if (json is Map<String, dynamic>) {
      final budgets = json['budgets'] ?? json['data'];
      if (budgets is List<dynamic>) {
        return budgets;
      }
    }

    return const [];
  }

  int? _intFromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  double _doubleFromJson(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final normalized = value.replaceAll(',', '').trim();
      return double.tryParse(normalized) ?? 0;
    }
    return 0;
  }

  DateTime? _nullableDateFromJson(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
