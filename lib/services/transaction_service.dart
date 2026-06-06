// lib/services/transaction_service.dart

import '../models/transaction_model.dart';
import 'api_service.dart';

class TransactionService {
  TransactionService(this._api);

  final ApiService _api;

  Future<List<TransactionModel>> getTransactions() async {
    final json = await _api.get('/transactions');
    final items = _listFromJson(json);
    return items
        .map((item) => _transactionFromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<TransactionModel> createTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    required TransactionCategory category,
    required DateTime date,
    String? notes,
  }) async {
    final json = await _api.post('/transactions', {
      'title': title,
      'amount': amount,
      'type': type.name,
      'category': category.label,
      'transactionDate': _dateOnly(date),
      'note': notes,
    }) as Map<String, dynamic>;

    return _transactionFromJson(json);
  }

  Future<TransactionModel> updateTransaction(
      TransactionModel transaction) async {
    final json = await _api.put('/transactions/${transaction.id}', {
      'title': transaction.title,
      'amount': transaction.amount,
      'type': transaction.type.name,
      'category': transaction.category.label,
      'transactionDate': _dateOnly(transaction.date),
      'note': transaction.notes,
    }) as Map<String, dynamic>;

    return _transactionFromJson(json);
  }

  Future<void> deleteTransaction(String id) {
    return _api.delete('/transactions/$id');
  }

  TransactionModel _transactionFromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'].toString(),
      userId: _intFromJson(json['userId'] ?? json['user_id']),
      title: json['title']?.toString() ?? '',
      amount: _doubleFromJson(json['amount']),
      type: _typeFromString(json['type']?.toString() ?? ''),
      category: _categoryFromString(json['category']?.toString() ?? ''),
      date: _dateFromJson(json['transactionDate'] ?? json['transaction_date']),
      notes: json['note']?.toString(),
      createdAt: _nullableDateFromJson(json['createdAt'] ?? json['created_at']),
    );
  }

  TransactionType _typeFromString(String value) {
    final normalized = value.trim().toLowerCase();
    return TransactionType.values.firstWhere(
      (type) => type.name == normalized,
      orElse: () => TransactionType.expense,
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
      final transactions = json['transactions'] ?? json['data'];
      if (transactions is List<dynamic>) {
        return transactions;
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

  DateTime _dateFromJson(dynamic value) {
    if (value == null) return DateTime.now();
    return DateTime.parse(value.toString());
  }

  DateTime? _nullableDateFromJson(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  String _dateOnly(DateTime date) {
    return date.toIso8601String().split('T').first;
  }
}
