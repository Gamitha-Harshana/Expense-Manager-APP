import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import 'add_expense_screen.dart';
import 'expense_list_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DateTime _selectedMonth;
  // ── Multi-select state ──────────────────────────────────────────────────────
  final Set<String> _selectedIds = {};
  bool get _isSelecting => _selectedIds.isNotEmpty;

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() => setState(() => _selectedIds.clear());

  void _confirmDeleteSelected(ExpenseProvider provider, String currency) {
    if (_selectedIds.isEmpty) return;
    final count = _selectedIds.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surface2 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete $count Expense${count > 1 ? 's' : ''}?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to permanently delete $count selected expense${count > 1 ? 's' : ''}?',
          style: const TextStyle(color: AppTheme.textMedium, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMedium)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteSelected(provider, currency);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteSelected(ExpenseProvider provider, String currency) {
    final expenses = provider.expenses
        .where((e) => _selectedIds.contains(e.id))
        .toList();
    final count = expenses.length;
    final total = expenses.fold(0.0, (s, e) => s + e.amount);
    _clearSelection();
    for (final e in expenses) {
      provider.deleteExpense(e);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline_rounded,
                color: Colors.white70, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Deleted $count expense${count > 1 ? 's' : ''} · ${AppUtils.formatCurrency(total, symbol: currency)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppTheme.primary,
          onPressed: () {
            for (final e in expenses) {
              provider.addExpense(e);
            }
          },
        ),
      ),
    );
  }
  // ───────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  void _showMonthPicker(
    BuildContext context,
    ExpenseProvider provider,
    String currency,
  ) {
    final now = DateTime.now();
    final currentMonthKey = DateTime(now.year, now.month);

    final Set<DateTime> monthSet = {currentMonthKey};
    for (int i = 0; i < 12; i++) {
      monthSet.add(DateTime(now.year, now.month - i));
    }
    for (var expense in provider.expenses) {
      monthSet.add(DateTime(expense.date.year, expense.date.month));
    }

    final sortedMonths = monthSet.toList()
      ..sort((a, b) => b.compareTo(a));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.surface2
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Text(
                      'Select Month',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: sortedMonths.length,
                      itemBuilder: (ctx, index) {
                        final monthDate = sortedMonths[index];
                        final isSelected =
                            monthDate.year == _selectedMonth.year &&
                            monthDate.month == _selectedMonth.month;
                        final isCurrent =
                            monthDate.year == now.year &&
                            monthDate.month == now.month;

                        final monthExpenses = provider.expenses.where((e) =>
                            e.date.year == monthDate.year &&
                            e.date.month == monthDate.month);
                        final total = monthExpenses.fold(
                          0.0,
                          (sum, e) => sum + e.amount,
                        );

                        return ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.calendar_month_rounded,
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.textMedium,
                              size: 20,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                DateFormat('MMMM yyyy').format(monthDate),
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.success.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Current',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text(
                            '${monthExpenses.length} transactions',
                            style: const TextStyle(color: AppTheme.textMedium),
                          ),
                          trailing: Text(
                            AppUtils.formatCurrency(total, symbol: currency),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppTheme.primary : null,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedMonth = monthDate;
                            });
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<SettingsProvider>(context).currencySymbol;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bg : const Color(0xFFF6F6FA),
      appBar: _isSelecting
          ? AppBar(
              backgroundColor: isDark ? AppTheme.surface1 : Colors.white,
              elevation: 2,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Cancel',
                onPressed: _clearSelection,
              ),
              title: Text(
                '${_selectedIds.length} selected',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.select_all_rounded),
                  tooltip: 'Select All',
                  onPressed: () {
                    final provider =
                        Provider.of<ExpenseProvider>(context, listen: false);
                    final selectedMonthExpenses = provider.expenses
                        .where((e) =>
                            e.date.year == _selectedMonth.year &&
                            e.date.month == _selectedMonth.month)
                        .toList();
                    final recentIds =
                        selectedMonthExpenses.take(5).map((e) => e.id).toSet();
                    setState(() {
                      if (_selectedIds.containsAll(recentIds)) {
                        _selectedIds.clear();
                      } else {
                        _selectedIds.addAll(recentIds);
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppTheme.danger),
                  tooltip: 'Delete Selected',
                  onPressed: () {
                    final provider =
                        Provider.of<ExpenseProvider>(context, listen: false);
                    _confirmDeleteSelected(provider, currency);
                  },
                ),
                const SizedBox(width: 8),
              ],
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              title: const Text(
                'Expense Manager',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surface2 : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isDark ? AppTheme.outline : const Color(0xFFE5E5F0),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 20),
                    tooltip: 'Settings',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SettingsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final selectedMonthExpenses = provider.expenses.where((e) =>
              e.date.year == _selectedMonth.year &&
              e.date.month == _selectedMonth.month).toList();

          final monthTotal = selectedMonthExpenses.fold(
            0.0,
            (sum, item) => sum + item.amount,
          );

          // Find top category
          final Map<String, double> catMap = {};
          for (var exp in selectedMonthExpenses) {
            catMap[exp.categoryId] = (catMap[exp.categoryId] ?? 0) + exp.amount;
          }
          String topCatName = 'None';
          int topCatPct = 0;
          if (catMap.isNotEmpty && monthTotal > 0) {
            final sortedEntries = catMap.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            final topCat = provider.getCategoryById(sortedEntries.first.key);
            topCatName = topCat?.name ?? 'General';
            topCatPct = (sortedEntries.first.value / monthTotal * 100).round();
          }

          final recentExpenses = selectedMonthExpenses.take(5).toList();

          return CustomScrollView(
            slivers: [
              // Hero Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Month Navigator Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.chevron_left_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              tooltip: 'Previous Month',
                              visualDensity: VisualDensity.compact,
                              onPressed: _previousMonth,
                            ),
                            InkWell(
                              onTap: () => _showMonthPicker(
                                context,
                                provider,
                                currency,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('MMMM yyyy').format(_selectedMonth),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.white70,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.chevron_right_rounded,
                                color: _isCurrentMonth ? Colors.white38 : Colors.white,
                                size: 24,
                              ),
                              tooltip: 'Next Month',
                              visualDensity: VisualDensity.compact,
                              onPressed: _nextMonth,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Total Amount
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0.0, 0.12),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                )),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            AppUtils.formatCurrency(monthTotal, symbol: currency),
                            key: ValueKey<String>('total_${_selectedMonth.year}_${_selectedMonth.month}_$monthTotal'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Transaction Count
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            '${selectedMonthExpenses.length} transactions',
                            key: ValueKey<int>(selectedMonthExpenses.length),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Back to current month chip if viewing past month
              if (!_isCurrentMonth)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ActionChip(
                        avatar: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Back to Current Month'),
                        backgroundColor: isDark ? AppTheme.surface2 : Colors.white,
                        side: BorderSide(
                          color: isDark ? AppTheme.outline : const Color(0xFFE5E5F0),
                        ),
                        onPressed: () {
                          final now = DateTime.now();
                          setState(() {
                            _selectedMonth = DateTime(now.year, now.month);
                          });
                        },
                      ),
                    ),
                  ),
                ),

              // Recent Transactions Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (recentExpenses.isNotEmpty)
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              icon: Icon(
                                _isSelecting
                                    ? Icons.close_rounded
                                    : Icons.checklist_rounded,
                                size: 16,
                                color: AppTheme.primary,
                              ),
                              label: Text(
                                _isSelecting ? 'Done' : 'Select',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  if (_isSelecting) {
                                    _clearSelection();
                                  } else {
                                    _selectedIds.add(recentExpenses.first.id);
                                  }
                                });
                              },
                            ),
                          if (!_isSelecting &&
                              selectedMonthExpenses.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ExpenseListScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'See all',
                                style: TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Transactions List or Empty Card
              if (recentExpenses.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(28),
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
                              Icons.receipt_long_outlined,
                              size: 44,
                              color: isDark ? AppTheme.textMedium : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No expenses in ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap "+ Add" to record your spending',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final expense = recentExpenses[index];
                        final category =
                            provider.getCategoryById(expense.categoryId);
                        final catColor = category != null
                            ? Color(category.colorValue)
                            : AppTheme.primary;
                        final isSelected = _selectedIds.contains(expense.id);

                        return Dismissible(
                          key: Key(expense.id),
                          direction: _isSelecting
                              ? DismissDirection.none
                              : DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            margin: const EdgeInsets.only(bottom: 8.0),
                            decoration: BoxDecoration(
                              color: AppTheme.danger,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            provider.deleteExpense(expense);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.delete_outline_rounded,
                                        color: Colors.white70, size: 18),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Deleted "${expense.title}"',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF1E1E2E),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                margin:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                duration: const Duration(seconds: 5),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  textColor: AppTheme.primary,
                                  onPressed: () {
                                    provider.addExpense(expense);
                                  },
                                ),
                              ),
                            );
                          },
                          child: GestureDetector(
                            onTap: _isSelecting
                                ? () => _toggleSelect(expense.id)
                                : null,
                            onLongPress: () => _toggleSelect(expense.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 8.0),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14.0,
                                vertical: 12.0,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDark
                                        ? AppTheme.primary.withOpacity(0.18)
                                        : AppTheme.primary.withOpacity(0.1))
                                    : (isDark
                                        ? AppTheme.surface1
                                        : Colors.white),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : (isDark
                                          ? AppTheme.outline
                                          : const Color(0xFFE5E5F0)),
                                  width: isSelected ? 1.5 : 0.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  if (_isSelecting) ...[
                                    AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      width: 22,
                                      height: 22,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected
                                            ? AppTheme.primary
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.primary
                                              : (isDark
                                                  ? Colors.grey.shade600
                                                  : Colors.grey.shade400),
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(Icons.check_rounded,
                                              size: 14, color: Colors.white)
                                          : null,
                                    ),
                                  ],
                                  // 40px Category Icon Tile (16% opacity background)
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: catColor.withOpacity(0.16),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      AppUtils.getIconData(
                                          category?.iconName ?? ''),
                                      color: catColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Title & Date
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          expense.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${DateFormat('MMM dd').format(expense.date)} · ${category?.name ?? 'General'}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Amount
                                  Text(
                                    '-${AppUtils.formatCurrency(expense.amount, symbol: currency)}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF14141C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ), // GestureDetector
                        );
                      },
                      childCount: recentExpenses.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          );
        },
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
            icon: const Icon(Icons.add_rounded, size: 22, color: Colors.white),
            label: const Text(
              'Add',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
              );
            },
          ),
        ),
      ),
    );
  }
}
