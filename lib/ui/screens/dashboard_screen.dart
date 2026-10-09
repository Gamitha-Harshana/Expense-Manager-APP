import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/utils.dart';
import 'add_expense_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DateTime _selectedMonth;

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
    if (_isCurrentMonth) return;
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

    // Collect all distinct months from expenses + include current month
    final Set<DateTime> monthSet = {currentMonthKey};
    for (var expense in provider.expenses) {
      monthSet.add(DateTime(expense.date.year, expense.date.month));
    }

    final sortedMonths = monthSet.toList()
      ..sort((a, b) => b.compareTo(a)); // Newest first

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
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  child: Text(
                    'Select Month',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
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
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade200,
                          child: Icon(
                            Icons.calendar_month,
                            color: isSelected ? Colors.white : Colors.grey.shade700,
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
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Current',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          '${monthExpenses.length} transactions',
                        ),
                        trailing: Text(
                          AppUtils.formatCurrency(total, symbol: currency),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : null,
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<SettingsProvider>(context).currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          // Filter expenses for selected month
          final selectedMonthExpenses = provider.expenses.where((e) =>
              e.date.year == _selectedMonth.year &&
              e.date.month == _selectedMonth.month).toList();

          final monthTotal = selectedMonthExpenses.fold(
            0.0,
            (sum, item) => sum + item.amount,
          );

          final recentExpenses = selectedMonthExpenses.take(5).toList();

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    color: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 20.0,
                      ),
                      child: Column(
                        children: [
                          // Month Selector Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.chevron_left,
                                  color: Colors.white,
                                ),
                                tooltip: 'Previous Month',
                                onPressed: _previousMonth,
                              ),
                              InkWell(
                                onTap: () => _showMonthPicker(
                                  context,
                                  provider,
                                  currency,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 6.0,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        DateFormat('MMMM yyyy')
                                            .format(_selectedMonth),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.white70,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.chevron_right,
                                  color: _isCurrentMonth
                                      ? Colors.white30
                                      : Colors.white,
                                ),
                                tooltip: 'Next Month',
                                onPressed: _isCurrentMonth ? null : _nextMonth,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isCurrentMonth
                                ? 'This Month Expenses'
                                : 'Past Month Expenses',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppUtils.formatCurrency(
                              monthTotal,
                              symbol: currency,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${selectedMonthExpenses.length} transaction${selectedMonthExpenses.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                          if (!_isCurrentMonth) ...[
                            const SizedBox(height: 12),
                            ActionChip(
                              avatar: const Icon(
                                Icons.refresh,
                                size: 16,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Back to Current Month',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              backgroundColor: const Color(0x33FFFFFF),
                              side: BorderSide.none,
                              onPressed: () {
                                setState(() {
                                  final now = DateTime.now();
                                  _selectedMonth =
                                      DateTime(now.year, now.month);
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isCurrentMonth
                            ? 'Recent Transactions'
                            : '${DateFormat('MMM yyyy').format(_selectedMonth)} Transactions',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.history, size: 18),
                        label: const Text('Past Months'),
                        onPressed: () => _showMonthPicker(
                          context,
                          provider,
                          currency,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (recentExpenses.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      _isCurrentMonth
                          ? 'No expenses this month. Add one!'
                          : 'No expenses recorded in ${DateFormat('MMMM yyyy').format(_selectedMonth)}.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final expense = recentExpenses[index];
                    final category = provider.getCategoryById(
                      expense.categoryId,
                    );

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: category != null
                            ? Color(category.colorValue)
                            : Colors.grey,
                        child: Icon(
                          AppUtils.getIconData(category?.iconName ?? ''),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(expense.title),
                      subtitle: Text(AppUtils.formatDate(expense.date)),
                      trailing: Text(
                        AppUtils.formatCurrency(
                          expense.amount,
                          symbol: currency,
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    );
                  }, childCount: recentExpenses.length),
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
