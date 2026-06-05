// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../themes/app_theme.dart';
import '../models/transaction_model.dart';
import '../services/app_services.dart';
import '../widgets/gradient_card.dart';
import '../widgets/transaction_card.dart';
import '../widgets/section_header.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/animated_counter.dart';
import '../utils/formatters.dart';

class _ChartSeries {
  final List<double> expenses;
  final List<double> income;
  final List<String> labels;

  const _ChartSeries({
    required this.expenses,
    required this.income,
    required this.labels,
  });
}

class HomeScreen extends StatefulWidget {
  final int refreshVersion;

  const HomeScreen({super.key, this.refreshVersion = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _filterIndex = 1; // 0=Daily, 1=Weekly, 2=Monthly, 3=Yearly
  late AnimationController _cardAnimController;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;
  List<TransactionModel> _transactions = [];
  bool _isLoadingTransactions = true;

  final List<String> _filters = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cardFade =
        CurvedAnimation(parent: _cardAnimController, curve: Curves.easeIn);
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _cardAnimController, curve: Curves.easeOut));
    _cardAnimController.forward();
    _loadTransactions();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _loadTransactions();
    }
  }

  @override
  void dispose() {
    _cardAnimController.dispose();
    super.dispose();
  }

  void _onFilterChanged(int index) {
    setState(() => _filterIndex = index);
    _cardAnimController.forward(from: 0);
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await AppServices.transactions.getTransactions();
      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _isLoadingTransactions = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingTransactions = false);
    }
  }

  double get _totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _totalSavings => _totalIncome - _totalExpenses;

  Map<TransactionCategory, double> get _categoryTotals {
    final totals = <TransactionCategory, double>{};
    for (final transaction
        in _transactions.where((t) => t.type == TransactionType.expense)) {
      totals[transaction.category] =
          (totals[transaction.category] ?? 0) + transaction.amount;
    }
    return totals;
  }

  _ChartSeries get _apiChartSeries {
    switch (_filterIndex) {
      case 0:
      case 1:
        return _dailySeries(7);
      case 2:
        return _monthlySeries(6);
      case 3:
        return _monthlySeries(12);
      default:
        return _dailySeries(7);
    }
  }

  _ChartSeries _dailySeries(int days) {
    final now = DateTime.now();
    final starts = List.generate(days, (index) {
      final date = now.subtract(Duration(days: days - 1 - index));
      return DateTime(date.year, date.month, date.day);
    });
    final expenses = List<double>.filled(days, 0);
    final income = List<double>.filled(days, 0);

    for (final transaction in _transactions) {
      final date = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      final index = starts.indexWhere((start) => start == date);
      if (index == -1) continue;

      if (transaction.type == TransactionType.income) {
        income[index] += transaction.amount;
      } else {
        expenses[index] += transaction.amount;
      }
    }

    return _ChartSeries(
      expenses: expenses,
      income: income,
      labels: starts.map((date) => '${date.month}/${date.day}').toList(),
    );
  }

  _ChartSeries _monthlySeries(int months) {
    final now = DateTime.now();
    final starts = List.generate(months, (index) {
      final offset = months - 1 - index;
      return DateTime(now.year, now.month - offset, 1);
    });
    final expenses = List<double>.filled(months, 0);
    final income = List<double>.filled(months, 0);

    for (final transaction in _transactions) {
      final date = DateTime(transaction.date.year, transaction.date.month, 1);
      final index = starts.indexWhere(
        (start) => start.year == date.year && start.month == date.month,
      );
      if (index == -1) continue;

      if (transaction.type == TransactionType.income) {
        income[index] += transaction.amount;
      } else {
        expenses[index] += transaction.amount;
      }
    }

    const monthNames = [
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
      'Dec',
    ];

    return _ChartSeries(
      expenses: expenses,
      income: income,
      labels: starts.map((date) => monthNames[date.month - 1]).toList(),
    );
  }

  List<double> get _chartExpenses {
    switch (_filterIndex) {
      case 0: // Daily — last 7 hours mock
        return _apiChartSeries.expenses;
      case 1: // Weekly
        return _apiChartSeries.expenses;
      case 2: // Monthly
        return _apiChartSeries.expenses;
      case 3: // Yearly
        return _apiChartSeries.expenses;
      default:
        return _apiChartSeries.expenses;
    }
  }

  List<String> get _chartLabels {
    switch (_filterIndex) {
      case 0:
        return _apiChartSeries.labels;
      case 1:
        return _apiChartSeries.labels;
      case 2:
        return _apiChartSeries.labels;
      case 3:
        return _apiChartSeries.labels;
      default:
        return _apiChartSeries.labels;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recentTransactions = _transactions.take(5).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── AppBar ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good Morning 👋',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Alex Johnson',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ],
                    ),
                    GestureDetector(
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: AppColors.primaryGradient,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text(
                            'AJ',
                            style: TextStyle(
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
              ),
            ),
          ),

          // ─── Balance Card ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: FadeTransition(
                opacity: _cardFade,
                child: SlideTransition(
                  position: _cardSlide,
                  child: GradientCard(
                    colors: AppColors.cardGradient,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Balance',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.visibility_rounded,
                                      color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Show',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AnimatedCounter(
                          value: _totalSavings,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Income / Expense row
                        Row(
                          children: [
                            Expanded(
                              child: _buildBalanceItem(
                                icon: Icons.arrow_downward_rounded,
                                label: 'Income',
                                amount: _totalIncome,
                                color: AppColors.income,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            Expanded(
                              child: _buildBalanceItem(
                                icon: Icons.arrow_upward_rounded,
                                label: 'Expenses',
                                amount: _totalExpenses,
                                color: AppColors.expense,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Savings Overview ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMiniCard(
                      context: context,
                      icon: Icons.savings_rounded,
                      label: 'Savings',
                      value: Formatters.currency(_totalSavings),
                      color: AppColors.income,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMiniCard(
                      context: context,
                      icon: Icons.trending_up_rounded,
                      label: 'Savings Rate',
                      value: Formatters.percentage(
                          _totalIncome == 0 ? 0 : _totalSavings / _totalIncome),
                      color: AppColors.primary,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Filter Chips ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: FilterChipRow(
                options: _filters,
                selectedIndex: _filterIndex,
                onSelected: _onFilterChanged,
              ),
            ),
          ),

          // ─── Weekly Expense Line Chart ─────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'Expense Trend',
                    actionText: 'See All',
                    onAction: () {},
                  ),
                  const SizedBox(height: 16),
                  _buildLineChart(isDark),
                ],
              ),
            ),
          ),

          // ─── Income vs Expense Bar Chart ──────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: 'Income vs Expense'),
                  const SizedBox(height: 16),
                  _buildBarChart(isDark),
                ],
              ),
            ),
          ),

          // ─── Category Pie Chart ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: 'By Category'),
                  const SizedBox(height: 16),
                  _buildPieChart(isDark),
                ],
              ),
            ),
          ),

          // ─── Quick Actions ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: 16),
                  _buildQuickActions(isDark),
                ],
              ),
            ),
          ),

          // ─── Recent Transactions ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: SectionHeader(
                title: 'Recent Transactions',
                actionText: 'See All',
                onAction: () {},
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
            sliver: _isLoadingTransactions
                ? const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                : recentTransactions.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            'No transactions yet',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => TransactionCard(
                            transaction: recentTransactions[index],
                          ),
                          childCount: recentTransactions.length,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              AnimatedCounter(
                value: amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(bool isDark) {
    final data = _chartExpenses;
    final labels = _chartLabels;
    final hasData = data.any((value) => value > 0);
    final maxVal = hasData ? data.reduce((a, b) => a > b ? a : b) : 1.0;

    if (!_isLoadingTransactions && !hasData) {
      return _buildEmptyChartCard(isDark, 'No API expense trend yet');
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(_filterIndex),
        height: 180,
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              horizontalInterval: maxVal / 4,
              getDrawingHorizontalLine: (v) => FlLine(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.grey.withOpacity(0.1),
                strokeWidth: 1,
              ),
              drawVerticalLine: false,
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (v, meta) {
                    final i = v.toInt();
                    if (i < 0 || i >= labels.length) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        labels[i],
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          fontSize: 11,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (v, meta) {
                    if (v == 0) return const SizedBox();
                    return Text(
                      Formatters.shortCurrency(v),
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: data
                    .asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value))
                    .toList(),
                isCurved: true,
                curveSmoothness: 0.3,
                color: AppColors.primary,
                barWidth: 2.5,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, __, ___, ____) => FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primary,
                    strokeWidth: 2,
                    strokeColor: isDark ? AppColors.darkCard : Colors.white,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withOpacity(0.25),
                      AppColors.primary.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) =>
                    isDark ? AppColors.darkSurface : Colors.white,
                tooltipRoundedRadius: 10,
                getTooltipItems: (touchedSpots) => touchedSpots
                    .map(
                      (spot) => LineTooltipItem(
                        Formatters.currency(spot.y),
                        const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(bool isDark) {
    final series = _dailySeries(7);
    final expData = series.expenses;
    final incData = series.income;
    final labels = series.labels;
    final hasData =
        expData.any((value) => value > 0) || incData.any((value) => value > 0);
    final maxValue = [
      ...expData,
      ...incData,
    ].fold(0.0, (max, value) => value > max ? value : max);

    if (!_isLoadingTransactions && !hasData) {
      return _buildEmptyChartCard(isDark, 'No API income or expense data yet');
    }

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue == 0 ? 1 : maxValue * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) =>
                  isDark ? AppColors.darkSurface : Colors.white,
              tooltipRoundedRadius: 10,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  Formatters.currency(rod.toY),
                  TextStyle(
                    color: rod.color ?? AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: maxValue == 0 ? 1 : maxValue / 4,
            getDrawingHorizontalLine: (v) => FlLine(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1),
              strokeWidth: 1,
            ),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: incData[i],
                  color: AppColors.income.withOpacity(0.7),
                  width: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: expData[i],
                  color: AppColors.expense.withOpacity(0.7),
                  width: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildEmptyChartCard(bool isDark, String message) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildPieChart(bool isDark) {
    final totals = _categoryTotals;
    final entries = totals.entries.toList();
    final total = totals.values.fold(0.0, (a, b) => a + b);

    if (!_isLoadingTransactions && total == 0) {
      return _buildEmptyChartCard(isDark, 'No API category spending yet');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Pie chart
          SizedBox(
            height: 150,
            width: 150,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 38,
                sections: entries.map((e) {
                  final pct = (e.value / total * 100).toStringAsFixed(0);
                  return PieChartSectionData(
                    color: e.key.color,
                    value: e.value,
                    title: '$pct%',
                    radius: 40,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Legend
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entries.map((e) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: e.key.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      e.key.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 11,
                          ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    final actions = [
      {'icon': Icons.add_rounded, 'label': 'Add', 'color': AppColors.primary},
      {
        'icon': Icons.analytics_rounded,
        'label': 'Reports',
        'color': AppColors.income
      },
      {
        'icon': Icons.savings_rounded,
        'label': 'Budget',
        'color': const Color(0xFFFF922B)
      },
      {
        'icon': Icons.account_balance_rounded,
        'label': 'Transfer',
        'color': AppColors.expense
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((a) {
        final color = a['color'] as Color;
        return Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(a['icon'] as IconData, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              a['label'] as String,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
