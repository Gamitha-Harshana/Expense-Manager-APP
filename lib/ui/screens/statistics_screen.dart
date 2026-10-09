import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/utils.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isOverall = false;
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

    final Set<DateTime> monthSet = {currentMonthKey};
    for (var expense in provider.expenses) {
      monthSet.add(DateTime(expense.date.year, expense.date.month));
    }

    final sortedMonths = monthSet.toList()
      ..sort((a, b) => b.compareTo(a));

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
                    'Select Month for Statistics',
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
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
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
                        subtitle: Text('${monthExpenses.length} transactions'),
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
                            _isOverall = false;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          final allExpenses = provider.expenses;
          final categories = provider.categories;
          final currency =
              Provider.of<SettingsProvider>(context).currencySymbol;

          // Determine which expenses to display
          final List<Expense> displayedExpenses = _isOverall
              ? allExpenses
              : allExpenses
                  .where((e) =>
                      e.date.year == _selectedMonth.year &&
                      e.date.month == _selectedMonth.month)
                  .toList();

          final double currentTotal = displayedExpenses.fold(
            0.0,
            (sum, item) => sum + item.amount,
          );

          // Calculate total per category for displayed expenses
          Map<String, double> categoryTotals = {};
          for (var expense in displayedExpenses) {
            categoryTotals[expense.categoryId] =
                (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
          }

          // Active categories sorted by amount descending
          final activeCategories = categories
              .where((cat) => (categoryTotals[cat.id] ?? 0) > 0)
              .toList()
            ..sort((a, b) =>
                (categoryTotals[b.id] ?? 0).compareTo(categoryTotals[a.id] ?? 0));

          List<PieChartSectionData> pieSections = [];
          for (var category in activeCategories) {
            final total = categoryTotals[category.id] ?? 0;
            if (total > 0 && currentTotal > 0) {
              final percentage = (total / currentTotal) * 100;
              pieSections.add(
                PieChartSectionData(
                  color: Color(category.colorValue),
                  value: total,
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: 52,
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            }
          }

          return CustomScrollView(
            slivers: [
              // Top Mode Selector: Monthly vs Overall
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.calendar_month, size: 16),
                              SizedBox(width: 6),
                              Text('Monthly Stats'),
                            ],
                          ),
                          selected: !_isOverall,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _isOverall = false;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.pie_chart, size: 16),
                              SizedBox(width: 6),
                              Text('Overall Stats'),
                            ],
                          ),
                          selected: _isOverall,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _isOverall = true;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Month Navigator (shown only in Monthly mode)
              if (!_isOverall)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      elevation: 0,
                      color: Theme.of(context).cardTheme.color ??
                          Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.grey.withAlpha(50),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
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
                                horizontal: 12.0,
                                vertical: 6.0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    DateFormat('MMMM yyyy')
                                        .format(_selectedMonth),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.chevron_right,
                              color: _isCurrentMonth ? Colors.grey : null,
                            ),
                            tooltip: 'Next Month',
                            onPressed: _isCurrentMonth ? null : _nextMonth,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Empty State or Chart & List
              if (displayedExpenses.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pie_chart_outline,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isOverall
                                ? 'No expenses recorded yet.'
                                : 'No expenses in ${DateFormat('MMMM yyyy').format(_selectedMonth)}.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          if (!_isOverall && !_isCurrentMonth) ...[
                            const SizedBox(height: 12),
                            TextButton.icon(
                              icon: const Icon(Icons.replay),
                              label: const Text('Back to Current Month'),
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
                )
              else ...[
                // Pie Chart
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: SizedBox(
                      height: 250,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 72,
                              sections: pieSections,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isOverall ? 'Overall Total' : 'Month Total',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppUtils.formatCurrency(
                                  currentTotal,
                                  symbol: currency,
                                ),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${displayedExpenses.length} txn${displayedExpenses.length == 1 ? '' : 's'}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Category Breakdown Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isOverall
                              ? 'Overall Category Breakdown'
                              : '${DateFormat('MMM yyyy').format(_selectedMonth)} Breakdown',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${activeCategories.length} categories',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Category Breakdown List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = activeCategories[index];
                      final total = categoryTotals[category.id] ?? 0;
                      final percentage = currentTotal > 0
                          ? (total / currentTotal) * 100
                          : 0.0;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor:
                                        Color(category.colorValue),
                                    child: Icon(
                                      AppUtils.getIconData(category.iconName),
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      category.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        AppUtils.formatCurrency(
                                          total,
                                          symbol: currency,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${percentage.toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: (percentage / 100).clamp(0.0, 1.0),
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(category.colorValue),
                                ),
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: activeCategories.length,
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
