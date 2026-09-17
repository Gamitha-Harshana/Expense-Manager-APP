import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'expense.g.dart';

@HiveType(typeId: 0)
class Expense extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double amount;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  String categoryId;

  @HiveField(5)
  String note;

  Expense({
    String? id,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.note = '',
  }) : id = id ?? const Uuid().v4();
}
