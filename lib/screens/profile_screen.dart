// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../models/transaction_model.dart';
import '../services/app_services.dart';
import '../utils/formatters.dart';
import '../widgets/gradient_card.dart';
import 'auth_screen.dart';
import 'budget_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = true;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  List<TransactionModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final transactions = await AppServices.transactions.getTransactions();
      if (!mounted) return;
      setState(() => _transactions = transactions);
    } catch (_) {
      if (!mounted) return;
      setState(() => _transactions = []);
    }
  }

  double get _totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _totalSavings => _totalIncome - _totalExpenses;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = AppServices.auth.currentUser;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text(
                  'Profile',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
            ),
          ),

          // Profile card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: GradientCard(
                colors: AppColors.primaryGradient,
                child: Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'AJ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'SpendWise User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'Signed in',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '✦ Premium Member',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Stats row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  _buildStatCard(context, isDark,
                      label: 'Balance',
                      value: Formatters.currency(_totalSavings),
                      color: AppColors.primary),
                  const SizedBox(width: 10),
                  _buildStatCard(context, isDark,
                      label: 'Savings',
                      value: Formatters.currency(_totalSavings),
                      color: AppColors.income),
                  const SizedBox(width: 10),
                  _buildStatCard(context, isDark,
                      label: 'Transactions',
                      value: '${_transactions.length}',
                      color: AppColors.expense),
                ],
              ),
            ),
          ),

          // Settings sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preferences',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 14),
                  _buildSettingsTile(
                    context,
                    isDark,
                    icon: Icons.dark_mode_rounded,
                    iconColor: AppColors.primary,
                    title: 'Dark Mode',
                    trailing: Switch(
                      value: _isDarkMode,
                      onChanged: (v) => setState(() => _isDarkMode = v),
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                  _buildSettingsTile(
                    context,
                    isDark,
                    icon: Icons.notifications_rounded,
                    iconColor: const Color(0xFFFF922B),
                    title: 'Notifications',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (v) =>
                          setState(() => _notificationsEnabled = v),
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                  _buildSettingsTile(
                    context,
                    isDark,
                    icon: Icons.fingerprint_rounded,
                    iconColor: AppColors.income,
                    title: 'Biometric Auth',
                    trailing: Switch(
                      value: _biometricEnabled,
                      onChanged: (v) => setState(() => _biometricEnabled = v),
                      activeThumbColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 14),
                  _buildSettingsTile(
                    context,
                    isDark,
                    icon: Icons.savings_rounded,
                    iconColor: AppColors.primary,
                    title: 'Budget Planner',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BudgetScreen()),
                    ),
                  ),
                  _buildSettingsTile(
                    context,
                    isDark,
                    icon: Icons.currency_exchange_rounded,
                    iconColor: const Color(0xFF845EF7),
                    title: 'Currency & Region',
                    subtitle: 'USD · United States',
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    context,
                    isDark,
                    icon: Icons.cloud_upload_rounded,
                    iconColor: const Color(0xFF339AF0),
                    title: 'Backup & Export',
                    subtitle: 'Last backup: Today',
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    context,
                    isDark,
                    icon: Icons.security_rounded,
                    iconColor: AppColors.income,
                    title: 'Privacy & Security',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Support',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 14),
                  _buildSettingsTile(
                    context,
                    isDark,
                    icon: Icons.help_rounded,
                    iconColor: const Color(0xFFFF6B9D),
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                  _buildSettingsTile(
                    context,
                    isDark,
                    icon: Icons.star_rounded,
                    iconColor: const Color(0xFFFFD43B),
                    title: 'Rate the App',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // Logout
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
              child: GestureDetector(
                onTap: () {
                  AppServices.auth.logout();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (_) => false,
                  );
                },
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.expense.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.expense.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded,
                          color: AppColors.expense, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Log Out',
                        style: TextStyle(
                          color: AppColors.expense,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    bool isDark, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                    )),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 12)),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }
}
