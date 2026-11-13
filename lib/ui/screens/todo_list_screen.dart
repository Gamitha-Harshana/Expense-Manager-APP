import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/todo_item.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/todo_provider.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  String _selectedFilter = 'all'; // 'all', 'future_expense', 'money_lent'
  bool _hideCompleted = false;

  void _showAddEditTodoSheet({TodoItem? existingItem}) {
    final isEditing = existingItem != null;
    final titleController =
        TextEditingController(text: existingItem?.title ?? '');
    final amountController = TextEditingController(
        text: existingItem != null ? existingItem.amount.toString() : '');
    final personController =
        TextEditingController(text: existingItem?.personName ?? '');
    final noteController = TextEditingController(text: existingItem?.note ?? '');

    String selectedType = existingItem?.type ?? 'future_expense';
    DateTime selectedDate = existingItem?.dueDate ??
        DateTime.now().add(const Duration(days: 7));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
    final categories = expenseProvider.categories;
    // Pre-select: use item's saved category, else first available
    String? selectedCategoryId = existingItem?.categoryId ??
        (categories.isNotEmpty ? categories.first.id : null);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.surface2 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isLent = selectedType == 'money_lent';
            final primary = AppTheme.primary;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 16.0,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.0,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        isEditing ? 'Edit Item' : 'New Financial To-Do',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Type Selector (uses theme primary color) ──────────
                      Container(
                        height: 44,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.surface1
                              : const Color(0xFFECECF4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setModalState(
                                    () => selectedType = 'future_expense'),
                                borderRadius: BorderRadius.circular(10),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: selectedType == 'future_expense'
                                        ? primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Future Expense',
                                    style: TextStyle(
                                      color: selectedType == 'future_expense'
                                          ? Colors.white
                                          : AppTheme.textMedium,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setModalState(
                                    () => selectedType = 'money_lent'),
                                borderRadius: BorderRadius.circular(10),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: selectedType == 'money_lent'
                                        ? primary
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Money Lent (Receive)',
                                    style: TextStyle(
                                      color: selectedType == 'money_lent'
                                          ? Colors.white
                                          : AppTheme.textMedium,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title Field
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: isLent ? 'Purpose / Description' : 'Expense Title',
                          hintText: isLent ? 'e.g. Loan for laptop' : 'e.g. Rent, College fee',
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Amount Field
                      TextField(
                        controller: amountController,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          hintText: '0.00',
                          prefixIcon: Icon(Icons.attach_money_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Person Name (Only if Money Lent)
                      if (isLent) ...[
                        TextField(
                          controller: personController,
                          decoration: const InputDecoration(
                            labelText: 'Person Name (Who will pay back?)',
                            hintText: 'e.g. Alex, Sam',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // ── Category Selector (only for Future Expense) ───────
                      if (!isLent && categories.isNotEmpty) ...[
                        Text(
                          'Expense Category',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.textMedium : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final cat = categories[i];
                              final isSelected = selectedCategoryId == cat.id;
                              return GestureDetector(
                                onTap: () => setModalState(
                                    () => selectedCategoryId = cat.id),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? primary
                                        : (isDark
                                            ? AppTheme.surface1
                                            : const Color(0xFFF0F0F8)),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? primary
                                          : (isDark
                                              ? AppTheme.outline
                                              : const Color(0xFFDDDDF0)),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Text(
                                    cat.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textMedium,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Due Date Picker Tile
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: selectedDate,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.surface1 : const Color(0xFFF6F6FA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.outline
                                  : const Color(0xFFE5E5F0),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isLent ? 'Expected Repayment Date' : 'Due Date',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textMedium,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(selectedDate),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: AppTheme.textMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Note Field
                      TextField(
                        controller: noteController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Note (Optional)',
                          hintText: 'Add extra details...',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Submit Button (always theme primary color) ─────────
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            final title = titleController.text.trim();
                            final amount =
                                double.tryParse(amountController.text) ?? 0.0;
                            if (title.isEmpty) {
                              AppUtils.showSnackBar(
                                  context, 'Please enter a title');
                              return;
                            }
                            if (amount <= 0) {
                              AppUtils.showSnackBar(
                                  context, 'Please enter a valid amount');
                              return;
                            }

                            final provider = Provider.of<TodoProvider>(
                                context,
                                listen: false);

                            if (isEditing) {
                              existingItem.title = title;
                              existingItem.amount = amount;
                              existingItem.type = selectedType;
                              existingItem.dueDate = selectedDate;
                              existingItem.categoryId =
                                  isLent ? null : selectedCategoryId;
                              existingItem.personName =
                                  personController.text.trim().isEmpty
                                      ? null
                                      : personController.text.trim();
                              existingItem.note =
                                  noteController.text.trim().isEmpty
                                      ? null
                                      : noteController.text.trim();
                              provider.updateTodo(existingItem);
                            } else {
                              final newItem = TodoItem(
                                title: title,
                                amount: amount,
                                dueDate: selectedDate,
                                type: selectedType,
                                categoryId: isLent ? null : selectedCategoryId,
                                personName:
                                    personController.text.trim().isEmpty
                                        ? null
                                        : personController.text.trim(),
                                note: noteController.text.trim().isEmpty
                                    ? null
                                    : noteController.text.trim(),
                              );
                              provider.addTodo(newItem);
                            }

                            Navigator.pop(ctx);
                          },
                          child: Text(
                            isEditing ? 'UPDATE ITEM' : 'ADD TO-DO',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleItemCompletion(TodoItem item) {
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);

    if (item.isFutureExpense) {
      if (!item.isCompleted) {
        // === MARKING COMPLETE: auto-add expense to dashboard ===
        final categories = expenseProvider.categories;
        // Use the saved categoryId if available, else fall back to first category
        final catId = item.categoryId ??
            (categories.isNotEmpty ? categories.first.id : '');
        final newExpense = Expense(
          title: item.title,
          amount: item.amount,
          date: DateTime.now(),
          categoryId: catId,
          note: item.note ?? '',
        );
        expenseProvider.addExpense(newExpense);
        // Store the linked expense ID so we can remove it on un-tick
        item.linkedExpenseId = newExpense.id;
        item.isCompleted = true;
        todoProvider.updateTodo(item);
      } else {
        // === UN-TICKING: remove the previously auto-added expense ===
        if (item.linkedExpenseId != null) {
          final allExpenses = expenseProvider.expenses;
          try {
            final linked = allExpenses.firstWhere(
              (e) => e.id == item.linkedExpenseId,
            );
            expenseProvider.deleteExpense(linked);
          } catch (_) {
            // Expense already removed — nothing to do
          }
        }
        item.linkedExpenseId = null;
        item.isCompleted = false;
        todoProvider.updateTodo(item);
      }
    } else {
      // Money Lent: just toggle, no expense side-effect
      todoProvider.toggleComplete(item);
    }
    // No SnackBar / popup shown
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currency = settingsProvider.currencySymbol;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter items
    List<TodoItem> items = todoProvider.todos;
    if (_selectedFilter == 'future_expense') {
      items = items.where((t) => t.isFutureExpense).toList();
    } else if (_selectedFilter == 'money_lent') {
      items = items.where((t) => t.isMoneyLent).toList();
    }

    if (_hideCompleted) {
      items = items.where((t) => !t.isCompleted).toList();
    }

    final totalExpenses = todoProvider.totalPendingExpenses;
    final totalReceivables = todoProvider.totalPendingReceivables;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bg : const Color(0xFFF6F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial To-Do',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Future Expenses & Money Lent',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppTheme.textMedium : Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _hideCompleted
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 22,
            ),
            tooltip: _hideCompleted ? 'Show Completed' : 'Hide Completed',
            onPressed: () {
              setState(() {
                _hideCompleted = !_hideCompleted;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Summary Row (To Pay vs To Receive)
            Row(
              children: [
                // Future Expenses Card (To Pay)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surface1 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppTheme.outline : const Color(0xFFE5E5F0),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.warning.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.schedule_rounded,
                                size: 18,
                                color: AppTheme.warning,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'To Pay',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.warning,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            AppUtils.formatCurrency(totalExpenses, symbol: currency),
                            key: ValueKey<double>(totalExpenses),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${todoProvider.futureExpenses.where((t) => !t.isCompleted).length} pending',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Money Lent Card (To Receive)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.surface1 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppTheme.outline : const Color(0xFFE5E5F0),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.success.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.call_received_rounded,
                                size: 18,
                                color: AppTheme.success,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'To Receive',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            AppUtils.formatCurrency(totalReceivables, symbol: currency),
                            key: ValueKey<double>(totalReceivables),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${todoProvider.moneyLent.where((t) => !t.isCompleted).length} pending',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter Chips
            Row(
              children: [
                _buildFilterChip('all', 'All (${todoProvider.todos.length})'),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'future_expense',
                  'To Pay (${todoProvider.futureExpenses.length})',
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'money_lent',
                  'To Receive (${todoProvider.moneyLent.length})',
                ),
              ],
            ),
            const SizedBox(height: 14),

            // To-Do List Items
            if (items.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surface1 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppTheme.outline : const Color(0xFFE5E5F0),
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.checklist_rounded,
                        size: 48,
                        color: isDark ? AppTheme.textMedium : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No to-do items found',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap "+ Add Item" to schedule future expenses or money lent',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isLent = item.isMoneyLent;
                  final isOverdue = !item.isCompleted &&
                      item.dueDate.isBefore(DateTime.now().subtract(const Duration(days: 1)));

                  return Dismissible(
                    key: Key(item.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20.0),
                      margin: const EdgeInsets.only(bottom: 10.0),
                      decoration: BoxDecoration(
                        color: AppTheme.danger,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      todoProvider.deleteTodo(item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Deleted "${item.title}"'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              todoProvider.addTodo(item);
                            },
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.surface1 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: item.isCompleted
                              ? (isDark ? AppTheme.outline : const Color(0xFFE5E5F0))
                              : isOverdue
                                  ? AppTheme.danger.withOpacity(0.5)
                                  : isLent
                                      ? AppTheme.success.withOpacity(0.4)
                                      : AppTheme.warning.withOpacity(0.4),
                          width: item.isCompleted ? 0.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Custom Checkbox with scale bounce animation
                          GestureDetector(
                            onTap: () => _handleItemCompletion(item),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: item.isCompleted
                                    ? (isLent ? AppTheme.success : AppTheme.warning)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: item.isCompleted
                                      ? Colors.transparent
                                      : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                                  width: 2,
                                ),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: item.isCompleted
                                    ? const Icon(
                                        Icons.check_rounded,
                                        key: ValueKey('checked'),
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : const SizedBox.shrink(key: ValueKey('empty')),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Title and Subtitle Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    decoration: item.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: item.isCompleted
                                        ? AppTheme.textMedium
                                        : (isDark ? AppTheme.textHigh : const Color(0xFF14141C)),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    // Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isLent
                                            ? AppTheme.success.withOpacity(0.15)
                                            : AppTheme.warning.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isLent
                                            ? (item.personName != null
                                                ? 'From ${item.personName}'
                                                : 'Money Lent')
                                            : 'Future Expense',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: isLent
                                              ? AppTheme.success
                                              : AppTheme.warning,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Due Date
                                    Text(
                                      'Due ${DateFormat('MMM dd').format(item.dueDate)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight:
                                            isOverdue ? FontWeight.bold : FontWeight.normal,
                                        color: isOverdue
                                            ? AppTheme.danger
                                            : AppTheme.textMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Amount Column
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isLent ? '+' : '-'}${AppUtils.formatCurrency(item.amount, symbol: currency)}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  decoration: item.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: item.isCompleted
                                      ? AppTheme.textMedium
                                      : isLent
                                          ? AppTheme.success
                                          : AppTheme.warning,
                                ),
                              ),
                              if (item.isCompleted)
                                const Text(
                                  'Settled',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textMedium,
                                  ),
                                ),
                            ],
                          ),

                          // Edit Icon
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            color: AppTheme.textMedium,
                            visualDensity: VisualDensity.compact,
                            onPressed: () =>
                                _showAddEditTodoSheet(existingItem: item),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 120),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 104.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            elevation: 0,
            backgroundColor: AppTheme.primary,
            icon: const Icon(Icons.add_task_rounded, size: 22, color: Colors.white),
            label: const Text(
              'Add Item',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            onPressed: () => _showAddEditTodoSheet(),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String type, String label) {
    final isSelected = _selectedFilter == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = type;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.2)
              : (isDark ? AppTheme.surface1 : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (isDark ? AppTheme.outline : const Color(0xFFE5E5F0)),
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? (isDark ? AppTheme.textHigh : AppTheme.primary)
                  : (isDark ? AppTheme.textMedium : Colors.grey.shade700),
            ),
          ),
        ),
      ),
    );
  }
}
