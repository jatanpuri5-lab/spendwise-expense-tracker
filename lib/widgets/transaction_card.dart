// lib/widgets/transaction_card.dart

import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../themes/app_theme.dart';
import '../utils/formatters.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;
  final bool showDate;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = transaction.type == TransactionType.expense;
    final cat = transaction.category;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? AppColors.darkDivider
                : Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: cat.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(cat.icon, color: cat.color, size: 24),
            ),
            const SizedBox(width: 14),

            // Title & date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: cat.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          cat.label,
                          style: TextStyle(
                            color: cat.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (showDate) ...[
                        const SizedBox(width: 8),
                        Text(
                          Formatters.date(transaction.date),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: isExpense ? AppColors.expense : AppColors.income,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                if (transaction.paymentMethod != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.paymentMethod!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 11,
                        ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
