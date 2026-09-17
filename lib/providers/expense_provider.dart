import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../services/database_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final _expenseBox = DatabaseService.getExpenseBox();
  final _categoryBox = DatabaseService.getCategoryBox();

  List<Expense> get expenses {
    final list = _expenseBox.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date)); // Newest first
    return list;
  }

  List<ExpenseCategory> get categories {
    final list = _categoryBox.values.toList();
    if (list.isEmpty) {
      // Fallback: If categories are empty (e.g. after a Hot Reload skipped init), initialize them.
      DatabaseService.initDefaultCategories(_categoryBox).then((_) {
        notifyListeners();
      });
    }
    return list;
  }

  double get totalExpenses {
    return expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  Future<void> addExpense(Expense expense) async {
    await _expenseBox.put(expense.id, expense);
    notifyListeners();
  }

  Future<void> updateExpense(Expense expense) async {
    await expense.save();
    notifyListeners();
  }

  Future<void> deleteExpense(Expense expense) async {
    await expense.delete();
    notifyListeners();
  }

  Future<void> addCategory(ExpenseCategory category) async {
    await _categoryBox.put(category.id, category);
    notifyListeners();
  }

  ExpenseCategory? getCategoryById(String id) {
    return _categoryBox.get(id);
  }

  List<Expense> getExpensesForCategory(String categoryId) {
    return expenses.where((e) => e.categoryId == categoryId).toList();
  }
}
