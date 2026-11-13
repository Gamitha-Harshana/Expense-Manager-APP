import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/category.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<String> _selectedCategoryIds = {};
  DateTimeRange? _selectedDateRange;

  // ── Multi-select state ──────────────────────────────────────────────────────
  final Set<String> _selectedExpenseIds = {};
  bool get _isSelecting => _selectedExpenseIds.isNotEmpty;

  void _toggleSelectExpense(String id) {
    setState(() {
      if (_selectedExpenseIds.contains(id)) {
        _selectedExpenseIds.remove(id);
      } else {
        _selectedExpenseIds.add(id);
      }
    });
  }

  void _clearExpenseSelection() => setState(() => _selectedExpenseIds.clear());

  void _confirmDeleteSelected(ExpenseProvider provider, String currency) {
    if (_selectedExpenseIds.isEmpty) return;
    final count = _selectedExpenseIds.length;
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
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textMedium)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteSelectedExpenses(provider, currency);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedExpenses(ExpenseProvider provider, String currency) {
    final expenses = provider.expenses
        .where((e) => _selectedExpenseIds.contains(e.id))
        .toList();
    final count = expenses.length;
    final total = expenses.fold(0.0, (s, e) => s + e.amount);
    _clearExpenseSelection();
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategoryIds.clear();
      _selectedDateRange = null;
    });
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedCategoryIds.isNotEmpty ||
      _selectedDateRange != null;

  String _formatDateRangeLabel(DateTimeRange range) {
    if (range.start.year == range.end.year &&
        range.start.month == range.end.month &&
        range.start.day == range.end.day) {
      return AppUtils.formatDate(range.start);
    }
    return '${DateFormat('MMM dd').format(range.start)} - ${DateFormat('MMM dd').format(range.end)}';
  }

  void _showCategoryFilterSheet(
    BuildContext context,
    List<ExpenseCategory> categories,
  ) {
    final tempSelected = Set<String>.from(_selectedCategoryIds);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Categories',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (tempSelected.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                setModalState(() {
                                  tempSelected.clear();
                                });
                              },
                              child: Text(
                                'Clear All',
                                style: TextStyle(color: AppTheme.primary),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.all_inclusive_rounded),
                      title: const Text('All Categories'),
                      trailing: tempSelected.isEmpty
                          ? Icon(Icons.check_rounded, color: AppTheme.primary)
                          : null,
                      onTap: () {
                        setModalState(() {
                          tempSelected.clear();
                        });
                      },
                    ),
                    const Divider(height: 1),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: categories.length,
                        itemBuilder: (ctx, index) {
                          final cat = categories[index];
                          final isChecked = tempSelected.contains(cat.id);
                          final catColor = Color(cat.colorValue);

                          return ListTile(
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: catColor.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                AppUtils.getIconData(cat.iconName),
                                size: 18,
                                color: catColor,
                              ),
                            ),
                            title: Text(cat.name),
                            trailing: isChecked
                                ? Icon(Icons.check_rounded, color: AppTheme.primary)
                                : null,
                            onTap: () {
                              setModalState(() {
                                if (isChecked) {
                                  tempSelected.remove(cat.id);
                                } else {
                                  tempSelected.add(cat.id);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedCategoryIds = Set.from(tempSelected);
                            });
                            Navigator.pop(ctx);
                          },
                          child: Text(
                            tempSelected.isEmpty
                                ? 'Show All Categories'
                                : 'Apply (${tempSelected.length} Selected)',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDateFilterSheet(BuildContext context) {
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.surface2 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
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
                    'Filter by Date',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.all_inclusive_rounded),
                  title: const Text('All Time'),
                  trailing: _selectedDateRange == null
                      ? Icon(Icons.check_rounded, color: AppTheme.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedDateRange = null;
                    });
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.today_rounded),
                  title: const Text('Today'),
                  onTap: () {
                    final today = DateTime(now.year, now.month, now.day);
                    setState(() {
                      _selectedDateRange = DateTimeRange(start: today, end: today);
                    });
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_view_week_rounded),
                  title: const Text('This Week'),
                  onTap: () {
                    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                    setState(() {
                      _selectedDateRange = DateTimeRange(
                        start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
                        end: now,
                      );
                    });
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month_rounded),
                  title: const Text('This Month'),
                  onTap: () {
                    setState(() {
                      _selectedDateRange = DateTimeRange(
                        start: DateTime(now.year, now.month, 1),
                        end: now,
                      );
                    });
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.update_rounded),
                  title: const Text('Future Expenses'),
                  onTap: () {
                    final tomorrow = DateTime(now.year, now.month, now.day + 1);
                    setState(() {
                      _selectedDateRange = DateTimeRange(
                        start: tomorrow,
                        end: DateTime(2100),
                      );
                    });
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.date_range_rounded),
                  title: const Text('Custom Range...'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDateRange: _selectedDateRange,
                    );
                    if (range != null) {
                      setState(() {
                        _selectedDateRange = range;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final currency = Provider.of<SettingsProvider>(context).currencySymbol;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Apply Filters
    List<Expense> filteredExpenses = provider.expenses.where((expense) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesTitle = expense.title.toLowerCase().contains(query);
        final matchesNote = expense.note?.toLowerCase().contains(query) ?? false;
        if (!matchesTitle && !matchesNote) return false;
      }

      if (_selectedCategoryIds.isNotEmpty) {
        if (!_selectedCategoryIds.contains(expense.categoryId)) return false;
      }

      if (_selectedDateRange != null) {
        final start = DateTime(
          _selectedDateRange!.start.year,
          _selectedDateRange!.start.month,
          _selectedDateRange!.start.day,
        );
        final end = DateTime(
          _selectedDateRange!.end.year,
          _selectedDateRange!.end.month,
          _selectedDateRange!.end.day,
          23, 59, 59,
        );
        if (expense.date.isBefore(start) || expense.date.isAfter(end)) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort by date newest first
    filteredExpenses.sort((a, b) => b.date.compareTo(a.date));

    final totalFilteredAmount = filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);

    // Group expenses by date (e.g. "Nov 04, 2026")
    final Map<String, List<Expense>> groupedExpenses = {};
    for (var exp in filteredExpenses) {
      final dateKey = DateFormat('MMM dd').format(exp.date);
      groupedExpenses.putIfAbsent(dateKey, () => []).add(exp);
    }

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bg : const Color(0xFFF6F6FA),
      appBar: _isSelecting
          ? AppBar(
              backgroundColor: isDark ? AppTheme.surface1 : Colors.white,
              elevation: 2,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Cancel',
                onPressed: _clearExpenseSelection,
              ),
              title: Text(
                '${_selectedExpenseIds.length} selected',
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
                    final allIds = filteredExpenses.map((e) => e.id).toSet();
                    setState(() {
                      if (_selectedExpenseIds.containsAll(allIds)) {
                        _selectedExpenseIds.clear();
                      } else {
                        _selectedExpenseIds.addAll(allIds);
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppTheme.danger),
                  tooltip: 'Delete Selected',
                  onPressed: () => _confirmDeleteSelected(provider, currency),
                ),
                const SizedBox(width: 8),
              ],
            )
          : AppBar(
              backgroundColor: Colors.transparent,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'All Expenses',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          '${filteredExpenses.length} expenses',
                          key: ValueKey<int>(filteredExpenses.length),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: AppTheme.textMedium,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('·',
                          style: TextStyle(color: AppTheme.textMedium)),
                      const SizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          'Total ${AppUtils.formatCurrency(totalFilteredAmount, symbol: currency)}',
                          key: ValueKey<double>(totalFilteredAmount),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: AppTheme.textMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                if (filteredExpenses.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.checklist_rounded),
                    tooltip: 'Select Multiple',
                    onPressed: () {
                      setState(() {
                        _selectedExpenseIds.add(filteredExpenses.first.id);
                      });
                    },
                  ),
              ],
            ),
      body: Column(
        children: [
          // Search & Filter Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Search Input Field
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surface2 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppTheme.outline : const Color(0xFFE5E5F0),
                      width: 0.5,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                      color: isDark ? AppTheme.textHigh : const Color(0xFF14141C),
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search title...',
                      hintStyle: const TextStyle(
                        color: AppTheme.textMedium,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: AppTheme.textMedium,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),

                // Labeled Filter Chips Row
                Row(
                  children: [
                    // Category Filter Chip
                    InkWell(
                      onTap: () => _showCategoryFilterSheet(context, provider.categories),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: _selectedCategoryIds.isNotEmpty
                              ? AppTheme.primary.withOpacity(0.2)
                              : (isDark ? AppTheme.surface2 : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedCategoryIds.isNotEmpty
                                ? AppTheme.primary
                                : (isDark ? AppTheme.outline : const Color(0xFFE5E5F0)),
                            width: _selectedCategoryIds.isNotEmpty ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _selectedCategoryIds.isNotEmpty
                                    ? AppTheme.primary
                                    : AppTheme.textMedium,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedCategoryIds.isEmpty
                                  ? 'Category'
                                  : 'Category (${_selectedCategoryIds.length})',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _selectedCategoryIds.isNotEmpty
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: _selectedCategoryIds.isNotEmpty
                                    ? (isDark ? AppTheme.textHigh : AppTheme.primary)
                                    : (isDark ? AppTheme.textHigh : const Color(0xFF14141C)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Date Filter Chip
                    InkWell(
                      onTap: () => _showDateFilterSheet(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 36,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: _selectedDateRange != null
                              ? AppTheme.primary.withOpacity(0.2)
                              : (isDark ? AppTheme.surface2 : Colors.white),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedDateRange != null
                                ? AppTheme.primary
                                : (isDark ? AppTheme.outline : const Color(0xFFE5E5F0)),
                            width: _selectedDateRange != null ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _selectedDateRange != null
                                    ? AppTheme.primary
                                    : AppTheme.textMedium,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedDateRange == null
                                  ? 'All time'
                                  : _formatDateRangeLabel(_selectedDateRange!),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: _selectedDateRange != null
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: _selectedDateRange != null
                                    ? (isDark ? AppTheme.textHigh : AppTheme.primary)
                                    : (isDark ? AppTheme.textHigh : const Color(0xFF14141C)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_hasActiveFilters) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        tooltip: 'Clear filters',
                        visualDensity: VisualDensity.compact,
                        onPressed: _clearFilters,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Date-Grouped Transaction List
          Expanded(
            child: filteredExpenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: isDark ? AppTheme.textMedium : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No expenses found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_hasActiveFilters) ...[
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Clear all filters'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 100.0),
                    itemCount: groupedExpenses.keys.length,
                    itemBuilder: (context, groupIndex) {
                      final dateKey = groupedExpenses.keys.elementAt(groupIndex);
                      final groupItems = groupedExpenses[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Group Header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
                            child: Text(
                              dateKey,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textMedium,
                              ),
                            ),
                          ),

                          // Expense Items in Date Group
                          ...groupItems.map((expense) {
                            final category = provider.getCategoryById(expense.categoryId);
                            final catColor = category != null
                                ? Color(category.colorValue)
                                : AppTheme.primary;
                            final isFuture = expense.date.isAfter(DateTime.now());

                            final isSelected =
                                _selectedExpenseIds.contains(expense.id);

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
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
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
                                    margin: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 16),
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
                                    ? () => _toggleSelectExpense(expense.id)
                                    : null,
                                onLongPress: () =>
                                    _toggleSelectExpense(expense.id),
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
                                            ? AppTheme.primary
                                                .withOpacity(0.18)
                                            : AppTheme.primary
                                                .withOpacity(0.1))
                                        : (isDark
                                            ? AppTheme.surface1
                                            : Colors.white),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primary
                                          : (isFuture
                                              ? AppTheme.warning
                                                  .withOpacity(0.5)
                                              : (isDark
                                                  ? AppTheme.outline
                                                  : const Color(
                                                      0xFFE5E5F0))),
                                      width: isSelected
                                          ? 1.5
                                          : (isFuture ? 1 : 0.5),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      if (_isSelecting) ...[
                                        AnimatedContainer(
                                          duration: const Duration(
                                              milliseconds: 180),
                                          width: 22,
                                          height: 22,
                                          margin: const EdgeInsets.only(
                                              right: 12),
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
                                              ? const Icon(
                                                  Icons.check_rounded,
                                                  size: 14,
                                                  color: Colors.white)
                                              : null,
                                        ),
                                      ],
                                      // 40px Category Icon Tile
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: catColor.withOpacity(0.16),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          AppUtils.getIconData(
                                              category?.iconName ?? ''),
                                          color: catColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Title & Category Name
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    expense.title,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isFuture)
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 6),
                                                    padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 6,
                                                      vertical: 1,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppTheme.warning
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: const Text(
                                                      'Upcoming',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            AppTheme.warning,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              category?.name ?? 'General',
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
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
