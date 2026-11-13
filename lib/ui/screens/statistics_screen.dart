import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../models/expense.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isOverall = false;
  late DateTime _selectedMonth;
  int _touchedIndex = -1;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Set<DateTime> monthSet = {currentMonthKey};
    for (int i = 0; i < 12; i++) {
      monthSet.add(DateTime(now.year, now.month - i));
    }
    for (var expense in provider.expenses) {
      monthSet.add(DateTime(expense.date.year, expense.date.month));
    }

    final sortedMonths = monthSet.toList()..sort((a, b) => b.compareTo(a));

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
                    'Select Month for Statistics',
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
                      final total = monthExpenses.fold(0.0, (sum, e) => sum + e.amount);

                      return ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primary.withOpacity(0.2)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.calendar_month_rounded,
                            size: 18,
                            color: isSelected ? AppTheme.primary : AppTheme.textMedium,
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              DateFormat('MMMM yyyy').format(monthDate),
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final currency = Provider.of<SettingsProvider>(context).currencySymbol;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter expenses based on selected mode
    final List<Expense> activeExpenses = _isOverall
        ? provider.expenses
        : provider.expenses
            .where((e) =>
                e.date.year == _selectedMonth.year &&
                e.date.month == _selectedMonth.month)
            .toList();

    final totalAmount = activeExpenses.fold(0.0, (sum, item) => sum + item.amount);

    // Group expenses by category
    final Map<String, double> categoryTotals = {};
    for (var expense in activeExpenses) {
      categoryTotals[expense.categoryId] =
          (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
    }

    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bg : const Color(0xFFF6F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Statistics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Violet Segmented Control (Monthly Stats vs Overall Stats)
            Container(
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surface1 : const Color(0xFFECECF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppTheme.outline : const Color(0xFFE5E5F0),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isOverall = false),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: !_isOverall ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Monthly Stats',
                          style: TextStyle(
                            color: !_isOverall ? Colors.white : AppTheme.textMedium,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isOverall = true),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: _isOverall ? AppTheme.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Overall Stats',
                          style: TextStyle(
                            color: _isOverall ? Colors.white : AppTheme.textMedium,
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
            const SizedBox(height: 12),

            // Month Navigator (When Monthly is selected)
            if (!_isOverall)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surface1 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppTheme.outline : const Color(0xFFE5E5F0),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      visualDensity: VisualDensity.compact,
                      onPressed: _previousMonth,
                    ),
                    InkWell(
                      onTap: () => _showMonthPicker(context, provider, currency),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          children: [
                            Text(
                              DateFormat('MMMM yyyy').format(_selectedMonth),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right_rounded,
                        color: _isCurrentMonth ? Colors.grey : null,
                      ),
                      visualDensity: VisualDensity.compact,
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),

            // Thinner Donut Chart with Total in Center
            if (activeExpenses.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.only(top: 16),
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
                        Icons.pie_chart_outline_rounded,
                        size: 48,
                        color: isDark ? AppTheme.textMedium : Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _isOverall ? 'No expenses recorded yet' : 'No expenses in this month',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              SizedBox(
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedIndex = -1;
                                return;
                              }
                              _touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        sectionsSpace: 3,
                        centerSpaceRadius: 65,
                        sections: sortedEntries.asMap().entries.map((entry) {
                          final index = entry.key;
                          final data = entry.value;
                          final category = provider.getCategoryById(data.key);
                          final isTouched = index == _touchedIndex;
                          final radius = isTouched ? 28.0 : 22.0;

                          final color = category != null
                              ? Color(category.colorValue)
                              : AppTheme.primary;

                          return PieChartSectionData(
                            color: color,
                            value: data.value,
                            title: '',
                            radius: radius,
                          );
                        }).toList(),
                      ),
                    ),
                    // Center Total Label
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isOverall ? 'Total Expenses' : 'Month Total',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textMedium,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            AppUtils.formatCurrency(totalAmount, symbol: currency),
                            key: ValueKey<double>(totalAmount),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppTheme.textHigh : const Color(0xFF14141C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Category Breakdown Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isOverall
                        ? 'Overall Breakdown'
                        : '${DateFormat('MMM yyyy').format(_selectedMonth)} Breakdown',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${sortedEntries.length} categories',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Legend Rows as Cards
              ...sortedEntries.map((entry) {
                final category = provider.getCategoryById(entry.key);
                final amount = entry.value;
                final percentage = totalAmount > 0 ? (amount / totalAmount * 100) : 0.0;
                final catColor = category != null ? Color(category.colorValue) : AppTheme.primary;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surface1 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppTheme.outline : const Color(0xFFE5E5F0),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      // 40px Icon Tile with 16% Opacity Background
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          AppUtils.getIconData(category?.iconName ?? ''),
                          color: catColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category?.name ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${percentage.toStringAsFixed(1)}% of ${_isOverall ? 'all' : 'month'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        AppUtils.formatCurrency(amount, symbol: currency),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
