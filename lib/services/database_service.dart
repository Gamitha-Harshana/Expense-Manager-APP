import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../core/constants.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(ExpenseCategoryAdapter());

    // Open Boxes
    await Hive.openBox<Expense>(AppConstants.expenseBox);
    await Hive.openBox<ExpenseCategory>(AppConstants.categoryBox);
    await Hive.openBox(AppConstants.settingsBox);

    // Initialize default categories if empty
    final categoryBox = Hive.box<ExpenseCategory>(AppConstants.categoryBox);
    if (categoryBox.isEmpty) {
      await initDefaultCategories(categoryBox);
    }
  }

  static Future<void> initDefaultCategories(Box<ExpenseCategory> box) async {
    final defaults = [
      ExpenseCategory(name: 'Food', colorValue: Colors.orange.value, iconName: 'restaurant'),
      ExpenseCategory(name: 'Transport', colorValue: Colors.blue.value, iconName: 'directions_car'),
      ExpenseCategory(name: 'Shopping', colorValue: Colors.pink.value, iconName: 'shopping_bag'),
      ExpenseCategory(name: 'Bills', colorValue: Colors.red.value, iconName: 'receipt'),
      ExpenseCategory(name: 'Entertainment', colorValue: Colors.purple.value, iconName: 'movie'),
    ];
    
    for (var category in defaults) {
      await box.put(category.id, category);
    }
  }

  static Box<Expense> getExpenseBox() => Hive.box<Expense>(AppConstants.expenseBox);
  static Box<ExpenseCategory> getCategoryBox() => Hive.box<ExpenseCategory>(AppConstants.categoryBox);
}
