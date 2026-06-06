// lib/screens/budget_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../themes/app_theme.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';
import '../services/app_services.dart';
import '../utils/formatters.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  final TextEditingController _limitController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  List<BudgetModel> _budgets = [];
  TransactionCategory _newBudgetCategory = TransactionCategory.food;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();
    final now = DateTime.now();
    _monthController.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';
    _loadBudgets();
  }

  @override
  void dispose() {
    _limitController.dispose();
    _monthController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadBudgets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final budgets = await AppServices.budgets.getBudgets();
      if (!mounted) return;
      setState(() => _budgets = budgets);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Could not load budgets');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveBudget({BudgetModel? budget}) async {
    final limit =
        double.tryParse(_limitController.text.replaceAll(',', '').trim());
    final month = _monthController.text.trim();

    if (limit == null ||
        limit <= 0 ||
        !RegExp(r'^\d{4}-\d{2}$').hasMatch(month)) {
      _showMessage('Enter a valid limit and month like 2026-06', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (budget == null) {
        await AppServices.budgets.createBudget(
          category: _newBudgetCategory,
          limitAmount: limit,
          month: month,
        );
      } else {
        await AppServices.budgets.updateBudget(
          id: budget.id,
          category: _newBudgetCategory,
          limitAmount: limit,
          month: month,
        );
      }
      _limitController.clear();
      if (!mounted) return;
      Navigator.pop(context);
      _showMessage(budget == null ? 'Budget created' : 'Budget updated',
          isError: false);
      await _loadBudgets();
    } on ApiException catch (err) {
      if (!mounted) return;
      _showMessage(err.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      _showMessage(
        budget == null ? 'Could not create budget' : 'Could not update budget',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteBudget(BudgetModel budget) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete budget?'),
        content: Text('Remove the ${budget.category.label} budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await AppServices.budgets.deleteBudget(budget.id);
      await _loadBudgets();
      if (!mounted) return;
      _showMessage('Budget deleted', isError: false);
    } on ApiException catch (err) {
      if (!mounted) return;
      _showMessage(err.message, isError: true);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not delete budget', isError: true);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.expense : AppColors.income,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final budgets = _budgets;
    final totalLimit = budgets.fold(0.0, (s, b) => s + b.limit);
    final totalSpent = budgets.fold(0.0, (s, b) => s + b.spent);
    final overallPct = totalLimit == 0 ? 0.0 : totalSpent / totalLimit;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    GestureDetector(
                      onTap: () => _showBudgetSheet(),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkDivider
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: const Icon(Icons.add_rounded, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Overall circular budget
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.cardGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 40,
                                sections: [
                                  PieChartSectionData(
                                    color: overallPct > 1
                                        ? AppColors.expense
                                        : AppColors.accent,
                                    value: overallPct.clamp(0.0, 1.0),
                                    radius: 18,
                                    title: '',
                                  ),
                                  PieChartSectionData(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    value: (1 - overallPct).clamp(0.0, 1.0),
                                    radius: 18,
                                    title: '',
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(overallPct * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Used',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Budget',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              Formatters.currency(totalLimit),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _budgetStat(
                                    'Spent',
                                    Formatters.currency(totalSpent),
                                    AppColors.expense),
                                const SizedBox(width: 20),
                                _budgetStat(
                                    'Left',
                                    Formatters.currency(
                                        (totalLimit - totalSpent)
                                            .clamp(0, double.infinity)),
                                    AppColors.income),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (_isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (_errorMessage != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      color: AppColors.expense,
                      size: 56,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: _loadBudgets,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (budgets.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Column(
                  children: [
                    Icon(
                      Icons.pie_chart_outline_rounded,
                      size: 56,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No budgets yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildBudgetCard(context, isDark, budgets[index]),
                  childCount: budgets.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showBudgetSheet({BudgetModel? budget}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (budget == null) {
      _limitController.clear();
    } else {
      _newBudgetCategory = budget.category;
      _limitController.text = budget.limit.toStringAsFixed(2);
      _monthController.text = budget.month;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    budget == null ? 'New Budget' : 'Edit Budget',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 52,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: TransactionCategory.values.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, index) {
                        final category = TransactionCategory.values[index];
                        final selected = _newBudgetCategory == category;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _newBudgetCategory = category);
                            setSheetState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? category.color
                                  : (isDark
                                      ? AppColors.darkCard
                                      : Colors.grey.shade100),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                category.label,
                                style: TextStyle(
                                  color:
                                      selected ? Colors.white : category.color,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _limitController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: 'Limit amount',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _monthController,
                    decoration: const InputDecoration(
                      hintText: 'YYYY-MM',
                      prefixIcon: Icon(Icons.calendar_month_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _isSaving ? null : () => _saveBudget(budget: budget),
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.primaryGradient,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                budget == null
                                    ? 'Create Budget'
                                    : 'Update Budget',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _budgetStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(
      BuildContext context, bool isDark, BudgetModel budget) {
    final isOver = budget.isOverBudget;
    final progressColor = isOver ? AppColors.expense : budget.category.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOver
              ? AppColors.expense.withValues(alpha: 0.3)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: budget.category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(budget.category.icon,
                    color: budget.category.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          budget.category.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (isOver)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.expense.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Over Budget',
                              style: TextStyle(
                                color: AppColors.expense,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${Formatters.currency(budget.spent)} / ${Formatters.currency(budget.limit)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                          ),
                    ),
                    if (budget.month.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        budget.month,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showBudgetSheet(budget: budget);
                  } else if (value == 'delete') {
                    _deleteBudget(budget);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: budget.percentage,
              backgroundColor: progressColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(budget.percentage * 100).toStringAsFixed(0)}% used',
                style: TextStyle(
                  color: progressColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                isOver
                    ? 'Over by ${Formatters.currency(budget.spent - budget.limit)}'
                    : '${Formatters.currency(budget.remaining)} left',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
