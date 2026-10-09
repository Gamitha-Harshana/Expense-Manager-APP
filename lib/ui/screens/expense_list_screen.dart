import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/category.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/utils.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<String> _selectedCategoryIds = {}; // Empty means all categories
  DateTimeRange? _selectedDateRange;

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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                              child: const Text('Clear All'),
                            ),
                        ],
                      ),
                    ),
                    const Divider(),
                    CheckboxListTile(
                      value: tempSelected.isEmpty,
                      title: const Text('All Categories'),
                      secondary: const Icon(Icons.all_inclusive),
                      onChanged: (val) {
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

                          return CheckboxListTile(
                            value: isChecked,
                            activeColor: Color(cat.colorValue),
                            secondary: CircleAvatar(
                              radius: 14,
                              backgroundColor: Color(cat.colorValue),
                              child: Icon(
                                AppUtils.getIconData(cat.iconName),
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(cat.name),
                            onChanged: (val) {
                              setModalState(() {
                                if (val == true) {
                                  tempSelected.add(cat.id);
                                } else {
                                  tempSelected.remove(cat.id);
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
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Text(
                    'Filter by Date',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.all_inclusive),
                  title: const Text('All Time'),
                  trailing: _selectedDateRange == null
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedDateRange = null;
                    });
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.today),
                  title: const Text('Today'),
                  onTap: () {
                    final today = DateTime(now.year, now.month, now.day);
                    setState(() {
                      _selectedDateRange =
                          DateTimeRange(start: today, end: today);
                    });
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_view_week),
                  title: const Text('This Week'),
                  onTap: () {
                    final startOfWeek =
                        now.subtract(Duration(days: now.weekday - 1));
                    setState(() {
                      _selectedDateRange = DateTimeRange(
                        start: DateTime(
                          startOfWeek.year,
                          startOfWeek.month,
                          startOfWeek.day,
                        ),
                        end: DateTime(now.year, now.month, now.day),
                      );
                    });
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('This Month'),
                  onTap: () {
                    final startOfMonth = DateTime(now.year, now.month, 1);
                    final endOfMonth = DateTime(now.year, now.month + 1, 0);
                    setState(() {
                      _selectedDateRange = DateTimeRange(
                        start: startOfMonth,
                        end: endOfMonth,
                      );
                    });
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.date_range),
                  title: const Text('Custom Date Range...'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDateRange: _selectedDateRange ??
                          DateTimeRange(
                            start: now.subtract(const Duration(days: 7)),
                            end: now,
                          ),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDateRange = picked;
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
    final currency = Provider.of<SettingsProvider>(context).currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
        actions: [
          if (_hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              tooltip: 'Clear Filters',
              onPressed: _clearFilters,
            ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final allExpenses = provider.expenses;
          final categories = provider.categories;

          // Filter by category (multiple selection)
          var filteredExpenses = allExpenses;
          if (_selectedCategoryIds.isNotEmpty) {
            filteredExpenses = filteredExpenses
                .where((e) => _selectedCategoryIds.contains(e.categoryId))
                .toList();
          }

          // Filter by date range
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
              23,
              59,
              59,
            );
            filteredExpenses = filteredExpenses.where((e) {
              return !e.date.isBefore(start) && !e.date.isAfter(end);
            }).toList();
          }

          // Filter by search query (title and note)
          if (_searchQuery.trim().isNotEmpty) {
            final query = _searchQuery.trim().toLowerCase();
            filteredExpenses = filteredExpenses.where((e) {
              final titleMatch = e.title.toLowerCase().contains(query);
              final noteMatch = e.note.toLowerCase().contains(query);
              return titleMatch || noteMatch;
            }).toList();
          }

          final filteredTotal = filteredExpenses.fold(
            0.0,
            (sum, item) => sum + item.amount,
          );

          return Column(
            children: [
              // Search Bar + Multiple Category Dropdown + Date Dropdown
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                child: Row(
                  children: [
                    // Search Bar
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search title...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Theme.of(context).cardTheme.color ??
                              Theme.of(context).colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 0.0,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.withAlpha(80),
                            ),
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Multi-Select Category Dropdown Button
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: _selectedCategoryIds.isNotEmpty
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(35)
                            : (Theme.of(context).cardTheme.color ??
                                Theme.of(context).colorScheme.surface),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedCategoryIds.isNotEmpty
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.withAlpha(80),
                          width: _selectedCategoryIds.isNotEmpty ? 1.5 : 1,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () =>
                            _showCategoryFilterSheet(context, categories),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _selectedCategoryIds.isNotEmpty
                                    ? Icons.category
                                    : Icons.category_outlined,
                                color: _selectedCategoryIds.isNotEmpty
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                                size: 20,
                              ),
                              if (_selectedCategoryIds.isNotEmpty) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${_selectedCategoryIds.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(width: 2),
                              Icon(
                                Icons.arrow_drop_down,
                                color: _selectedCategoryIds.isNotEmpty
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Date Filter Dropdown Button
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: _selectedDateRange != null
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(35)
                            : (Theme.of(context).cardTheme.color ??
                                Theme.of(context).colorScheme.surface),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedDateRange != null
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.withAlpha(80),
                          width: _selectedDateRange != null ? 1.5 : 1,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showDateFilterSheet(context),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _selectedDateRange != null
                                    ? Icons.calendar_month
                                    : Icons.calendar_today_outlined,
                                color: _selectedDateRange != null
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                                size: 19,
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.arrow_drop_down,
                                color: _selectedDateRange != null
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Active Filter Chips (if any)
              if (_selectedCategoryIds.isNotEmpty ||
                  _selectedDateRange != null) ...[
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      if (_selectedDateRange != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: InputChip(
                            avatar: const Icon(
                              Icons.date_range,
                              size: 14,
                              color: Colors.white,
                            ),
                            label: Text(
                              _formatDateRangeLabel(_selectedDateRange!),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            deleteIconColor: Colors.white,
                            onDeleted: () {
                              setState(() {
                                _selectedDateRange = null;
                              });
                            },
                          ),
                        ),
                      ..._selectedCategoryIds.map((id) {
                        final cat = provider.getCategoryById(id);
                        if (cat == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: InputChip(
                            avatar: Icon(
                              AppUtils.getIconData(cat.iconName),
                              size: 14,
                              color: Colors.white,
                            ),
                            label: Text(
                              cat.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            backgroundColor: Color(cat.colorValue),
                            deleteIconColor: Colors.white,
                            onDeleted: () {
                              setState(() {
                                _selectedCategoryIds.remove(id);
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
              ],

              // Results Count / Filtered Total bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredExpenses.length} expense${filteredExpenses.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Total: ${AppUtils.formatCurrency(filteredTotal, symbol: currency)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 12),

              // Expenses List
              Expanded(
                child: allExpenses.isEmpty
                    ? const Center(child: Text('No expenses recorded.'))
                    : filteredExpenses.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No matching expenses found.',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: _clearFilters,
                                  child: const Text('Clear Filters'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredExpenses.length,
                            itemBuilder: (context, index) {
                              final expense = filteredExpenses[index];
                              final category = provider.getCategoryById(
                                expense.categoryId,
                              );

                              return Dismissible(
                                key: Key(expense.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (_) {
                                  provider.deleteExpense(expense);
                                  AppUtils.showSnackBar(
                                    context,
                                    'Expense deleted',
                                  );
                                },
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: category != null
                                        ? Color(category.colorValue)
                                        : Colors.grey,
                                    child: Icon(
                                      AppUtils.getIconData(
                                        category?.iconName ?? '',
                                      ),
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(expense.title),
                                  subtitle: Text(
                                    '${AppUtils.formatDate(expense.date)} • ${category?.name ?? 'Unknown'}${expense.note.isNotEmpty ? ' • ${expense.note}' : ''}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Text(
                                    AppUtils.formatCurrency(
                                      expense.amount,
                                      symbol: currency,
                                    ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
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
