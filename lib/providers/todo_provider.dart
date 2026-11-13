import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';
import '../models/todo_item.dart';

class TodoProvider extends ChangeNotifier {
  final _box = Hive.box(AppConstants.todoBox);

  List<TodoItem> get todos {
    final List<TodoItem> list = [];
    for (var key in _box.keys) {
      final val = _box.get(key);
      if (val is Map) {
        list.add(TodoItem.fromMap(val));
      }
    }
    // Sort: pending first, then by due date ascending (soonest due first)
    list.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.dueDate.compareTo(b.dueDate);
    });
    return list;
  }

  List<TodoItem> get futureExpenses =>
      todos.where((t) => t.isFutureExpense).toList();

  List<TodoItem> get moneyLent =>
      todos.where((t) => t.isMoneyLent).toList();

  double get totalPendingExpenses => futureExpenses
      .where((t) => !t.isCompleted)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalPendingReceivables => moneyLent
      .where((t) => !t.isCompleted)
      .fold(0.0, (sum, t) => sum + t.amount);

  Future<void> addTodo(TodoItem item) async {
    await _box.put(item.id, item.toMap());
    notifyListeners();
  }

  Future<void> updateTodo(TodoItem item) async {
    await _box.put(item.id, item.toMap());
    notifyListeners();
  }

  Future<void> toggleComplete(TodoItem item) async {
    item.isCompleted = !item.isCompleted;
    await _box.put(item.id, item.toMap());
    notifyListeners();
  }

  Future<void> deleteTodo(String id) async {
    await _box.delete(id);
    notifyListeners();
  }
}
