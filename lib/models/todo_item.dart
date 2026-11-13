import 'package:uuid/uuid.dart';

class TodoItem {
  final String id;
  String title;
  double amount;
  DateTime dueDate;
  String type; // 'future_expense' or 'money_lent'
  String? personName;
  String? note;
  bool isCompleted;
  DateTime createdAt;
  String? linkedExpenseId; // tracks the auto-created expense when a Future Expense is ticked
  String? categoryId; // chosen expense category for Future Expense type

  TodoItem({
    String? id,
    required this.title,
    required this.amount,
    required this.dueDate,
    required this.type,
    this.personName,
    this.note,
    this.isCompleted = false,
    DateTime? createdAt,
    this.linkedExpenseId,
    this.categoryId,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  bool get isFutureExpense => type == 'future_expense';
  bool get isMoneyLent => type == 'money_lent';

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'amount': amount,
        'dueDate': dueDate.toIso8601String(),
        'type': type,
        'personName': personName,
        'note': note,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'linkedExpenseId': linkedExpenseId,
        'categoryId': categoryId,
      };

  factory TodoItem.fromMap(Map<dynamic, dynamic> map) => TodoItem(
        id: map['id'] as String,
        title: map['title'] as String,
        amount: (map['amount'] as num).toDouble(),
        dueDate: DateTime.parse(map['dueDate'] as String),
        type: map['type'] as String? ?? 'future_expense',
        personName: map['personName'] as String?,
        note: map['note'] as String?,
        isCompleted: map['isCompleted'] as bool? ?? false,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : DateTime.now(),
        linkedExpenseId: map['linkedExpenseId'] as String?,
        categoryId: map['categoryId'] as String?,
      );
}
