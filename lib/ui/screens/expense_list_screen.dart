import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/utils.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final expenses = provider.expenses;
          final currency = Provider.of<SettingsProvider>(context).currencySymbol;

          if (expenses.isEmpty) {
            return const Center(child: Text('No expenses recorded.'));
          }

          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              final category = provider.getCategoryById(expense.categoryId);

              return Dismissible(
                key: Key(expense.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  provider.deleteExpense(expense);
                  AppUtils.showSnackBar(context, 'Expense deleted');
                },
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
                  title: Text(expense.title),
                  subtitle: Text('${AppUtils.formatDate(expense.date)} • ${category?.name ?? 'Unknown'}'),
                  trailing: Text(
                    AppUtils.formatCurrency(expense.amount, symbol: currency),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    // Could open edit screen
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
