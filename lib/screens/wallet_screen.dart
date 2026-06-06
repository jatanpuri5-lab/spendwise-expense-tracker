// lib/screens/wallet_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../themes/app_theme.dart';
import '../dummy_data/dummy_data.dart';
import '../widgets/gradient_card.dart';
import '../utils/formatters.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Savings growth data (cumulative)
    final savingsData = <FlSpot>[];
    double runningTotal = 8000;
    for (int i = 0; i < 12; i++) {
      runningTotal += DummyData.monthlyIncome[i] - DummyData.monthlyExpenses[i];
      savingsData.add(FlSpot(i.toDouble(), runningTotal));
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Wallet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Wallet cards
            GradientCard(
              colors: AppColors.cardGradient,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Primary Wallet',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                      ),
                      const Icon(Icons.credit_card_rounded,
                          color: Colors.white, size: 22),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Formatters.currency(DummyData.totalBalance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _walletStat(
                          'Income',
                          Formatters.currency(DummyData.totalIncome),
                          AppColors.income),
                      const SizedBox(width: 24),
                      _walletStat(
                          'Expense',
                          Formatters.currency(DummyData.totalExpenses),
                          AppColors.expense),
                      const SizedBox(width: 24),
                      _walletStat(
                          'Savings',
                          Formatters.currency(DummyData.totalSavings),
                          Colors.white),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Financial summary cards
            Text('Financial Summary',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _summaryCard(context, isDark,
                    label: 'Net Worth',
                    value: Formatters.currency(DummyData.totalBalance),
                    change: '+8.4%',
                    positive: true,
                    icon: Icons.account_balance_rounded,
                    color: AppColors.primary),
                _summaryCard(context, isDark,
                    label: 'Monthly Savings',
                    value: Formatters.currency(DummyData.totalSavings),
                    change: '+12.1%',
                    positive: true,
                    icon: Icons.savings_rounded,
                    color: AppColors.income),
                _summaryCard(context, isDark,
                    label: 'Avg. Expense',
                    value: Formatters.currency(DummyData.totalExpenses / 30),
                    change: '-3.2%',
                    positive: true,
                    icon: Icons.trending_down_rounded,
                    color: AppColors.expense),
                _summaryCard(context, isDark,
                    label: 'Savings Rate',
                    value: Formatters.percentage(
                        DummyData.totalSavings / DummyData.totalIncome),
                    change: '+5.6%',
                    positive: true,
                    icon: Icons.percent_rounded,
                    color: const Color(0xFFFF922B)),
              ],
            ),
            const SizedBox(height: 28),

            // Savings growth chart
            Text('Savings Growth',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 14),
            Container(
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
                        reservedSize: 50,
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
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: savingsData,
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: AppColors.incomeGradient,
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.income.withValues(alpha: 0.2),
                            AppColors.income.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Insights
            Text('Expense Insights',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 14),
            _buildInsightCard(context, isDark,
                icon: Icons.trending_down_rounded,
                color: AppColors.income,
                title: 'Great job!',
                subtitle: 'Your food expenses are 12% lower than last month.'),
            _buildInsightCard(context, isDark,
                icon: Icons.warning_rounded,
                color: AppColors.expense,
                title: 'Over budget',
                subtitle: 'Shopping exceeded budget by \$24.49 this month.'),
            _buildInsightCard(context, isDark,
                icon: Icons.lightbulb_rounded,
                color: const Color(0xFFFF922B),
                title: 'Tip',
                subtitle:
                    'You could save \$189/yr by switching to a cheaper streaming plan.'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _walletStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(
    BuildContext context,
    bool isDark, {
    required String label,
    required String value,
    required String change,
    required bool positive,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: positive
                      ? AppColors.income.withValues(alpha: 0.1)
                      : AppColors.expense.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: positive ? AppColors.income : AppColors.expense,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
