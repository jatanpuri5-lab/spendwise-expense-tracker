// lib/services/app_services.dart

import 'api_service.dart';
import 'auth_service.dart';
import 'budget_service.dart';
import 'transaction_service.dart';

class AppServices {
  AppServices._();

  static final ApiService api = ApiService();
  static final AuthService auth = AuthService(api);
  static final TransactionService transactions = TransactionService(api);
  static final BudgetService budgets = BudgetService(api);
}
