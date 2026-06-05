// lib/screens/transactions_screen.dart

import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../models/transaction_model.dart';
import '../services/app_services.dart';
import '../widgets/transaction_card.dart';
import '../utils/formatters.dart';

enum SortOrder { latest, oldest, highest, lowest }

class TransactionsScreen extends StatefulWidget {
  final int refreshVersion;

  const TransactionsScreen({super.key, this.refreshVersion = 0});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  TransactionCategory? _selectedCategory;
  SortOrder _sortOrder = SortOrder.latest;
  final TextEditingController _searchController = TextEditingController();
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<Map<String, dynamic>> _categoryFilters = [
    {'label': 'All', 'category': null},
    {'label': 'Food', 'category': TransactionCategory.food},
    {'label': 'Shopping', 'category': TransactionCategory.shopping},
    {'label': 'Transport', 'category': TransactionCategory.transport},
    {'label': 'Bills', 'category': TransactionCategory.bills},
    {'label': 'Health', 'category': TransactionCategory.health},
    {'label': 'Entertainment', 'category': TransactionCategory.entertainment},
  ];

  List<TransactionModel> get _filteredTransactions {
    var list = List<TransactionModel>.from(_transactions);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              t.category.label
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Category filter
    if (_selectedCategory != null) {
      list = list.where((t) => t.category == _selectedCategory).toList();
    }

    // Sort
    switch (_sortOrder) {
      case SortOrder.latest:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOrder.oldest:
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOrder.highest:
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortOrder.lowest:
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return list;
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void didUpdateWidget(covariant TransactionsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _loadTransactions();
    }
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final transactions = await AppServices.transactions.getTransactions();
      if (!mounted) return;
      setState(() => _transactions = transactions);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Could not load transactions');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSortSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sort By',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              ...SortOrder.values.map(
                (s) => RadioListTile<SortOrder>(
                  title: Text(_sortLabel(s)),
                  value: s,
                  groupValue: _sortOrder,
                  activeColor: AppColors.primary,
                  onChanged: (v) {
                    setState(() => _sortOrder = v!);
                    Navigator.pop(ctx);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String _sortLabel(SortOrder s) {
    switch (s) {
      case SortOrder.latest:
        return 'Latest First';
      case SortOrder.oldest:
        return 'Oldest First';
      case SortOrder.highest:
        return 'Highest Amount';
      case SortOrder.lowest:
        return 'Lowest Amount';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transactions = _filteredTransactions;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transactions',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      GestureDetector(
                        onTap: _showSortSheet,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkDivider
                                  : Colors.grey.shade200,
                            ),
                          ),
                          child: Icon(
                            Icons.sort_rounded,
                            size: 20,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.darkTextSecondary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Icon(Icons.close_rounded,
                                color: AppColors.darkTextSecondary),
                          )
                        : null,
                  ),
                ),
              ),
            ),

            // Category filter chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  itemCount: _categoryFilters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final f = _categoryFilters[index];
                    final cat = f['category'] as TransactionCategory?;
                    final isSelected = _selectedCategory == cat;
                    final color = cat?.color ?? AppColors.primary;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color
                              : (isDark ? AppColors.darkCard : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? color
                                : (isDark
                                    ? AppColors.darkDivider
                                    : Colors.grey.shade200),
                          ),
                        ),
                        child: Row(
                          children: [
                            if (cat != null) ...[
                              Icon(cat.icon,
                                  size: 14,
                                  color: isSelected ? Colors.white : cat.color),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              f['label'] as String,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Results count
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Text(
                  _isLoading
                      ? 'Loading transactions...'
                      : '${transactions.length} transactions',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),

            // Transaction list
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (_errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_off_rounded,
                        size: 64,
                        color: AppColors.expense,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _loadTransactions,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (transactions.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => TransactionCard(
                      transaction: transactions[index],
                      onTap: () => _showTransactionDetail(transactions[index]),
                    ),
                    childCount: transactions.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetail(TransactionModel t) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = t.type == TransactionType.expense;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: t.category.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(t.category.icon, color: t.category.color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(t.title, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text(
              '${isExpense ? '-' : '+'}\$${t.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: isExpense ? AppColors.expense : AppColors.income,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            _detailRow('Category', t.category.label),
            _detailRow('Date', Formatters.dateTime(t.date)),
            if (t.paymentMethod != null)
              _detailRow('Payment', t.paymentMethod!),
            if (t.notes != null) _detailRow('Notes', t.notes!),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
