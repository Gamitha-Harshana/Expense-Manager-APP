import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/utils.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currency = settingsProvider.currencySymbol;
    final now = DateTime.now();

    // Current month expenses
    final currentMonthExpenses = provider.expenses.where((e) =>
        e.date.month == now.month && e.date.year == now.year).toList();
    final currentTotal = currentMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);

    // Previous month
    final prevMonth = now.month == 1 ? 12 : now.month - 1;
    final prevYear = now.month == 1 ? now.year - 1 : now.year;
    final prevMonthExpenses = provider.expenses.where((e) =>
        e.date.month == prevMonth && e.date.year == prevYear).toList();
    final prevTotal = prevMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);

    // Difference
    final difference = currentTotal - prevTotal;
    final isMore = difference > 0;
    final isEqual = difference == 0;

    // Current month category breakdown
    Map<String, double> categoryTotals = {};
    for (var expense in currentMonthExpenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current Month Card
            Card(
              color: Theme.of(context).colorScheme.primary,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      _getMonthName(now.month) + ' ${now.year}',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppUtils.formatCurrency(currentTotal, symbol: currency),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currentMonthExpenses.length} transactions',
                      style: const TextStyle(color: Colors.white60, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Comparison Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'Compared to Last Month',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildComparisonColumn(
                          context,
                          'Last Month',
                          AppUtils.formatCurrency(prevTotal, symbol: currency),
                          Colors.grey,
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.grey.shade400,
                        ),
                        _buildComparisonColumn(
                          context,
                          'This Month',
                          AppUtils.formatCurrency(currentTotal, symbol: currency),
                          Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isEqual
                            ? Colors.grey.shade200
                            : isMore
                                ? Colors.red.shade50
                                : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isEqual
                                ? Icons.horizontal_rule
                                : isMore
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                            color: isEqual
                                ? Colors.grey
                                : isMore
                                    ? Colors.red
                                    : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isEqual
                                ? 'Same as last month'
                                : isMore
                                    ? 'You spent ${AppUtils.formatCurrency(difference.abs(), symbol: currency)} more'
                                    : 'You saved ${AppUtils.formatCurrency(difference.abs(), symbol: currency)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isEqual
                                  ? Colors.grey
                                  : isMore
                                      ? Colors.red
                                      : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category Breakdown
            const Text(
              'This Month by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (categoryTotals.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text('No expenses this month')),
                ),
              )
            else
              ...categoryTotals.entries.map((entry) {
                final category = provider.getCategoryById(entry.key);
                final percentage = currentTotal > 0 ? (entry.value / currentTotal * 100) : 0;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: category != null
                          ? Color(category.colorValue)
                          : Colors.grey,
                      child: Icon(
                        AppUtils.getIconData(category?.iconName ?? ''),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(category?.name ?? 'Unknown'),
                    subtitle: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        category != null ? Color(category.colorValue) : Colors.grey,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppUtils.formatCurrency(entry.value, symbol: currency),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonColumn(
      BuildContext context, String label, String amount, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month];
  }
}
