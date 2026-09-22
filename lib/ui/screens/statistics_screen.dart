import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/utils.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final expenses = provider.expenses;
          final categories = provider.categories;
          final currency = Provider.of<SettingsProvider>(context).currencySymbol;

          if (expenses.isEmpty) {
            return const Center(child: Text('No expenses to analyze.'));
          }

          // Calculate total per category
          Map<String, double> categoryTotals = {};
          for (var expense in expenses) {
            categoryTotals[expense.categoryId] = 
                (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
          }

          List<PieChartSectionData> pieSections = [];
          for (var category in categories) {
            final total = categoryTotals[category.id] ?? 0;
            if (total > 0) {
              pieSections.add(
                PieChartSectionData(
                  color: Color(category.colorValue),
                  value: total,
                  title: '${((total / provider.totalExpenses) * 100).toStringAsFixed(1)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              );
            }
          }

          return Column(
            children: [
              const SizedBox(height: 32),
              SizedBox(
                height: 250,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 70,
                        sections: pieSections,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Total'),
                        Text(
                          AppUtils.formatCurrency(provider.totalExpenses, symbol: currency),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final total = categoryTotals[category.id] ?? 0;
                    if (total == 0) return const SizedBox.shrink();

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(category.colorValue),
                        child: Icon(
                          AppUtils.getIconData(category.iconName),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(category.name),
                      trailing: Text(
                        AppUtils.formatCurrency(total, symbol: currency),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
