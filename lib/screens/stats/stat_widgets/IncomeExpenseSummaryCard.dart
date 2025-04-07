import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import thư viện intl

class IncomeExpenseSummaryCard extends StatelessWidget {
  final int income;
  final int expense;
  final int balance;
  final ColorScheme theme;

  const IncomeExpenseSummaryCard({
    required this.income,
    required this.expense,
    required this.balance,
    required this.theme,
  });

  // Hàm để định dạng số tiền theo VNĐ
  String formatCurrency(int amount) {
    final NumberFormat formatter = NumberFormat('#,###', 'vi_VN');
    return formatter.format(amount) + 'đ';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Thu nhập',
                      amount: formatCurrency(income),
                      color: theme.primary,
                    ),
                  ),
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Chi tiêu',
                      amount: formatCurrency(expense),
                      color: theme.tertiary,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: 'Số dư',
                      amount: formatCurrency(balance),
                      color: theme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    String? balance, // Thêm balance (có thể null)
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (balance != null) ...[
            const SizedBox(height: 8),
            Text(
              balance,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
