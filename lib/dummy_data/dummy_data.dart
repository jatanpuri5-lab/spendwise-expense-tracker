// lib/dummy_data/dummy_data.dart

import '../models/transaction_model.dart';
import '../models/budget_model.dart';

class DummyData {
  // ─── Transactions ───────────────────────────────────────────────
  static final List<TransactionModel> transactions = [
    // This month
    TransactionModel(
      id: '1',
      title: 'Grocery Store',
      amount: 85.50,
      type: TransactionType.expense,
      category: TransactionCategory.food,
      date: DateTime.now().subtract(const Duration(hours: 2)),
      notes: 'Weekly groceries',
      paymentMethod: 'Credit Card',
    ),
    TransactionModel(
      id: '2',
      title: 'Monthly Salary',
      amount: 5200.00,
      type: TransactionType.income,
      category: TransactionCategory.salary,
      date: DateTime.now().subtract(const Duration(days: 1)),
      notes: 'May salary',
      paymentMethod: 'Bank Transfer',
    ),
    TransactionModel(
      id: '3',
      title: 'Netflix Subscription',
      amount: 15.99,
      type: TransactionType.expense,
      category: TransactionCategory.entertainment,
      date: DateTime.now().subtract(const Duration(days: 2)),
      paymentMethod: 'Credit Card',
    ),
    TransactionModel(
      id: '4',
      title: 'Uber Ride',
      amount: 23.40,
      type: TransactionType.expense,
      category: TransactionCategory.transport,
      date: DateTime.now().subtract(const Duration(days: 2)),
      paymentMethod: 'Debit Card',
    ),
    TransactionModel(
      id: '5',
      title: 'Electric Bill',
      amount: 120.00,
      type: TransactionType.expense,
      category: TransactionCategory.bills,
      date: DateTime.now().subtract(const Duration(days: 3)),
      notes: 'May electricity',
      paymentMethod: 'Bank Transfer',
    ),
    TransactionModel(
      id: '6',
      title: 'Pharmacy',
      amount: 45.20,
      type: TransactionType.expense,
      category: TransactionCategory.health,
      date: DateTime.now().subtract(const Duration(days: 4)),
      paymentMethod: 'Cash',
    ),
    TransactionModel(
      id: '7',
      title: 'Zara Shopping',
      amount: 189.99,
      type: TransactionType.expense,
      category: TransactionCategory.shopping,
      date: DateTime.now().subtract(const Duration(days: 5)),
      notes: 'Summer collection',
      paymentMethod: 'Credit Card',
    ),
    TransactionModel(
      id: '8',
      title: 'Freelance Project',
      amount: 800.00,
      type: TransactionType.income,
      category: TransactionCategory.investment,
      date: DateTime.now().subtract(const Duration(days: 6)),
      notes: 'Website redesign project',
      paymentMethod: 'Bank Transfer',
    ),
    TransactionModel(
      id: '9',
      title: 'Restaurant Dinner',
      amount: 67.80,
      type: TransactionType.expense,
      category: TransactionCategory.food,
      date: DateTime.now().subtract(const Duration(days: 7)),
      notes: 'Birthday dinner',
      paymentMethod: 'Credit Card',
    ),
    TransactionModel(
      id: '10',
      title: 'Cinema Tickets',
      amount: 32.00,
      type: TransactionType.expense,
      category: TransactionCategory.entertainment,
      date: DateTime.now().subtract(const Duration(days: 8)),
      paymentMethod: 'Debit Card',
    ),
    TransactionModel(
      id: '11',
      title: 'Internet Bill',
      amount: 60.00,
      type: TransactionType.expense,
      category: TransactionCategory.bills,
      date: DateTime.now().subtract(const Duration(days: 9)),
      paymentMethod: 'Bank Transfer',
    ),
    TransactionModel(
      id: '12',
      title: 'Bus Pass',
      amount: 40.00,
      type: TransactionType.expense,
      category: TransactionCategory.transport,
      date: DateTime.now().subtract(const Duration(days: 10)),
      paymentMethod: 'Cash',
    ),
    TransactionModel(
      id: '13',
      title: 'Gym Membership',
      amount: 55.00,
      type: TransactionType.expense,
      category: TransactionCategory.health,
      date: DateTime.now().subtract(const Duration(days: 11)),
      paymentMethod: 'Credit Card',
    ),
    TransactionModel(
      id: '14',
      title: 'Amazon Order',
      amount: 134.50,
      type: TransactionType.expense,
      category: TransactionCategory.shopping,
      date: DateTime.now().subtract(const Duration(days: 12)),
      notes: 'Electronics & books',
      paymentMethod: 'Credit Card',
    ),
    TransactionModel(
      id: '15',
      title: 'Stock Dividend',
      amount: 250.00,
      type: TransactionType.income,
      category: TransactionCategory.investment,
      date: DateTime.now().subtract(const Duration(days: 14)),
      paymentMethod: 'Bank Transfer',
    ),
    TransactionModel(
      id: '16',
      title: 'Coffee Shop',
      amount: 12.50,
      type: TransactionType.expense,
      category: TransactionCategory.food,
      date: DateTime.now().subtract(const Duration(days: 15)),
      paymentMethod: 'Cash',
    ),
    TransactionModel(
      id: '17',
      title: 'Spotify Premium',
      amount: 9.99,
      type: TransactionType.expense,
      category: TransactionCategory.entertainment,
      date: DateTime.now().subtract(const Duration(days: 16)),
      paymentMethod: 'Credit Card',
    ),
    TransactionModel(
      id: '18',
      title: 'Doctor Visit',
      amount: 90.00,
      type: TransactionType.expense,
      category: TransactionCategory.health,
      date: DateTime.now().subtract(const Duration(days: 18)),
      paymentMethod: 'Cash',
    ),
    TransactionModel(
      id: '19',
      title: 'Water Bill',
      amount: 35.00,
      type: TransactionType.expense,
      category: TransactionCategory.bills,
      date: DateTime.now().subtract(const Duration(days: 20)),
      paymentMethod: 'Bank Transfer',
    ),
    TransactionModel(
      id: '20',
      title: 'Taxi to Airport',
      amount: 55.00,
      type: TransactionType.expense,
      category: TransactionCategory.transport,
      date: DateTime.now().subtract(const Duration(days: 22)),
      paymentMethod: 'Cash',
    ),
  ];

  // ─── Budgets ────────────────────────────────────────────────────
  static const List<BudgetModel> budgets = [
    BudgetModel(
        id: 'b1',
        category: TransactionCategory.food,
        limit: 400.0,
        spent: 265.80),
    BudgetModel(
        id: 'b2',
        category: TransactionCategory.shopping,
        limit: 300.0,
        spent: 324.49),
    BudgetModel(
        id: 'b3',
        category: TransactionCategory.transport,
        limit: 150.0,
        spent: 118.40),
    BudgetModel(
        id: 'b4',
        category: TransactionCategory.bills,
        limit: 250.0,
        spent: 215.00),
    BudgetModel(
        id: 'b5',
        category: TransactionCategory.health,
        limit: 200.0,
        spent: 190.20),
    BudgetModel(
        id: 'b6',
        category: TransactionCategory.entertainment,
        limit: 100.0,
        spent: 57.98),
  ];

  // ─── Weekly Chart Data ───────────────────────────────────────────
  static const List<double> weeklyExpenses = [
    120.0,
    85.0,
    210.0,
    95.0,
    180.0,
    240.0,
    65.0
  ];

  static const List<double> weeklyIncome = [
    0.0,
    0.0,
    800.0,
    0.0,
    0.0,
    5200.0,
    0.0
  ];

  static const List<String> weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  // ─── Monthly Chart Data ──────────────────────────────────────────
  static const List<double> monthlyExpenses = [
    2100,
    1850,
    2400,
    2200,
    1950,
    2800,
    2100,
    1750,
    2300,
    2600,
    2450,
    1971
  ];

  static const List<double> monthlyIncome = [
    5200,
    5200,
    6000,
    5200,
    5450,
    5200,
    5700,
    5200,
    5200,
    5900,
    5200,
    6250
  ];

  static const List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  // ─── Summary ─────────────────────────────────────────────────────
  static double get totalBalance => 12458.50;
  static double get totalIncome => 6250.00;
  static double get totalExpenses => 1971.37;
  static double get totalSavings => totalIncome - totalExpenses;

  // ─── Category Spending (for pie chart) ───────────────────────────
  static Map<TransactionCategory, double> get categoryTotals {
    final Map<TransactionCategory, double> totals = {};
    for (final t
        in transactions.where((t) => t.type == TransactionType.expense)) {
      totals[t.category] = (totals[t.category] ?? 0) + t.amount;
    }
    return totals;
  }
}
