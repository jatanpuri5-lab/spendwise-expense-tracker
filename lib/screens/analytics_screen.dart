// lib/screens/analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../themes/app_theme.dart';
import '../dummy_data/dummy_data.dart';
import '../models/transaction_model.dart';
import '../services/app_services.dart';
import '../widgets/section_header.dart';
import '../widgets/filter_chip_row.dart';
import '../utils/formatters.dart';

class AnalyticsScreen extends StatefulWidget {
  final int refreshVersion;

  const AnalyticsScreen({super.key, this.refreshVersion = 0});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  int _filterIndex = 1; // weekly/monthly toggle
  int _touchedPieIndex = -1;
  late AnimationController _animController;
  Map<TransactionCategory, double> _apiCategoryTotals = {};

  final List<String> _filters = ['Weekly', 'Monthly', 'Quarterly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animController.forward();
    _loadCategoryTotals();
  }

  Future<void> _loadCategoryTotals() async {
    try {
      final transactions = await AppServices.transactions.getTransactions();
      final totals = <TransactionCategory, double>{};
      for (final transaction
          in transactions.where((t) => t.type == TransactionType.expense)) {
        totals[transaction.category] =
            (totals[transaction.category] ?? 0) + transaction.amount;
      }
      if (!mounted) return;
      setState(() => _apiCategoryTotals = totals);
    } catch (_) {
      if (!mounted) return;
      setState(() => _apiCategoryTotals = {});
    }
  }

  @override
  void didUpdateWidget(covariant AnalyticsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshVersion != widget.refreshVersion) {
      _loadCategoryTotals();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<double> get _barData {
    switch (_filterIndex) {
      case 0:
        return DummyData.weeklyExpenses;
      case 1:
        return DummyData.monthlyExpenses;
      case 2:
        return [8200, 9100, 7800, 8600];
      case 3:
        return [
          18500,
          22000,
          19800,
          21000,
          23500,
          20800,
          19200,
          21500,
          24000,
          22800,
          21100,
          19700
        ];
      default:
        return DummyData.monthlyExpenses;
    }
  }

  List<String> get _barLabels {
    switch (_filterIndex) {
      case 0:
        return DummyData.weekDays;
      case 1:
        return DummyData.months;
      case 2:
        return ['Q1', 'Q2', 'Q3', 'Q4'];
      case 3:
        return DummyData.months;
      default:
        return DummyData.months;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryTotals = _apiCategoryTotals;
    final totalExpense = categoryTotals.values.fold(0.0, (a, b) => a + b);
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // AppBar
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text(
                  'Analytics',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            ),
          ),

          // Summary row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  _buildSummaryChip(
                    context,
                    isDark,
                    label: 'Total Spent',
                    value: Formatters.currency(totalExpense),
                    color: AppColors.expense,
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryChip(
                    context,
                    isDark,
                    label: 'Avg/Month',
                    value: Formatters.currency(totalExpense / 12),
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: FilterChipRow(
                options: _filters,
                selectedIndex: _filterIndex,
                onSelected: (i) {
                  setState(() => _filterIndex = i);
                  _animController.forward(from: 0);
                },
              ),
            ),
          ),

          // ─── Large Pie Chart ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Spending Breakdown'),
                  const SizedBox(height: 16),
                  _buildLargePieChart(isDark, sortedEntries, totalExpense),
                ],
              ),
            ),
          ),

          // ─── Monthly Expense Bar Chart ─────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Expense Breakdown'),
                  const SizedBox(height: 16),
                  _buildAnimatedBarChart(isDark),
                ],
              ),
            ),
          ),

          // ─── Spending Trend Line ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Income vs Expense Trend'),
                  const SizedBox(height: 16),
                  _buildTrendChart(isDark),
                ],
              ),
            ),
          ),

          // ─── Category Comparison ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Category Comparison'),
                  const SizedBox(height: 16),
                  ...sortedEntries.map(
                    (e) => _buildCategoryBar(
                      context,
                      isDark,
                      category: e.key,
                      amount: e.value,
                      total: totalExpense,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(
    BuildContext context,
    bool isDark, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLargePieChart(
    bool isDark,
    List<MapEntry<TransactionCategory, double>> entries,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        _touchedPieIndex = -1;
                        return;
                      }
                      _touchedPieIndex =
                          response.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sectionsSpace: 3,
                centerSpaceRadius: 55,
                sections: entries.asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  final isTouched = i == _touchedPieIndex;
                  final pct = (e.value / total * 100).toStringAsFixed(1);
                  return PieChartSectionData(
                    color: e.key.color,
                    value: e.value,
                    title: isTouched ? '$pct%\n${e.key.label}' : '$pct%',
                    radius: isTouched ? 65 : 50,
                    titleStyle: TextStyle(
                      color: Colors.white,
                      fontSize: isTouched ? 13 : 10,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend grid
          Wrap(
            spacing: 16,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: entries.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: e.key.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${e.key.label} · ${Formatters.currency(e.value)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBarChart(bool isDark) {
    final data = _barData;
    final labels = _barLabels;
    final maxY = data.reduce((a, b) => a > b ? a : b) * 1.2;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(_filterIndex),
        height: 220,
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: BarChart(
          BarChartData(
            maxY: maxY,
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
                  interval: data.length > 6 ? 2 : 1,
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
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 44,
                  getTitlesWidget: (v, meta) {
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
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (v) => FlLine(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.1),
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: data.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value,
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: data.length > 6 ? 10 : 16,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendChart(bool isDark) {
    const expData = DummyData.monthlyExpenses;
    const incData = DummyData.monthlyIncome;

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.1),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 2,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= DummyData.months.length) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DummyData.months[i],
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                getTitlesWidget: (v, meta) => Text(
                  Formatters.shortCurrency(v),
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // Income line
            LineChartBarData(
              spots: incData
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              color: AppColors.income,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.income.withValues(alpha: 0.08),
              ),
            ),
            // Expense line
            LineChartBarData(
              spots: expData
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              color: AppColors.expense,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.expense.withValues(alpha: 0.08),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) =>
                  isDark ? AppColors.darkSurface : Colors.white,
              tooltipRoundedRadius: 10,
              getTooltipItems: (spots) => spots.map((spot) {
                final label = spot.barIndex == 0 ? 'Income' : 'Expense';
                final color =
                    spot.barIndex == 0 ? AppColors.income : AppColors.expense;
                return LineTooltipItem(
                  '$label\n${Formatters.currency(spot.y)}',
                  TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBar(
    BuildContext context,
    bool isDark, {
    required TransactionCategory category,
    required double amount,
    required double total,
  }) {
    final pct = amount / total;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(category.icon, color: category.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      Formatters.currency(amount),
                      style: TextStyle(
                        color: category.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: pct,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: category.color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${(pct * 100).toStringAsFixed(1)}% of total',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
