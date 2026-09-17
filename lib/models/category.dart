import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class ExpenseCategory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int colorValue;

  @HiveField(3)
  String iconName;

  ExpenseCategory({
    String? id,
    required this.name,
    required this.colorValue,
    required this.iconName,
  }) : id = id ?? const Uuid().v4();
}
