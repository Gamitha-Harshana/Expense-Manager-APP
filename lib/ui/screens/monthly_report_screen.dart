import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  late DateTime _baseMonth;
  late DateTime _targetMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _baseMonth = DateTime(now.year, now.month - 1);
    _targetMonth = DateTime(now.year, now.month);
  }

  void _swapMonths() {
    setState(() {
      final temp = _baseMonth;
      _baseMonth = _targetMonth;
      _targetMonth = temp;
    });
  }

  void _resetToDefault() {
    final now = DateTime.now();
    setState(() {
      _baseMonth = DateTime(now.year, now.month - 1);
      _targetMonth = DateTime(now.year, now.month);
    });
  }

  void _compareWithLastYear() {
    setState(() {
      _baseMonth = DateTime(_targetMonth.year - 1, _targetMonth.month);
    });
  }

  void _showMonthPicker({
    required BuildContext context,
    required bool isBaseMonth,
    required ExpenseProvider provider,
    required String currency,
  }) {
    final now = DateTime.now();
    final selectedDate = isBaseMonth ? _baseMonth : _targetMonth;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Set<DateTime> monthSet = {
      DateTime(now.year, now.month),
      DateTime(now.year, now.month - 1),
    };

    for (int i = 0; i < 12; i++) {
      monthSet.add(DateTime(now.year, now.month - i));
    }
    for (var expense in provider.expenses) {
      monthSet.add(DateTime(expense.date.year, expense.date.month));
    }

    final sortedMonths = monthSet.toList()..sort((a, b) => b.compareTo(a));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppTheme.surface2 : Colors.white,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isBaseMonth ? 'Select Base Month' : 'Select Comparison Month',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: sortedMonths.length,
                      itemBuilder: (ctx, index) {
                        final monthDate = sortedMonths[index];
                        final isSelected = monthDate.year == selectedDate.year &&
                            monthDate.month == selectedDate.month;
                        final isCurrent = monthDate.year == now.year &&
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
                              if (isBaseMonth) {
                                _baseMonth = monthDate;
                              } else {
                                _targetMonth = monthDate;
                              }
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
    final provider = Provider.of<ExpenseProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final currency = settingsProvider.currencySymbol;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseExpenses = provider.expenses.where((e) =>
        e.date.month == _baseMonth.month && e.date.year == _baseMonth.year).toList();
    final baseTotal = baseExpenses.fold(0.0, (sum, e) => sum + e.amount);

    final targetExpenses = provider.expenses.where((e) =>
        e.date.month == _targetMonth.month && e.date.year == _targetMonth.year).toList();
    final targetTotal = targetExpenses.fold(0.0, (sum, e) => sum + e.amount);

    final difference = targetTotal - baseTotal;
    final isMore = difference > 0;
    final isEqual = difference == 0;

    double? percentChange;
    if (baseTotal > 0) {
      percentChange = ((targetTotal - baseTotal) / baseTotal) * 100;
    } else if (targetTotal > 0) {
      percentChange = 100.0;
    } else {
      percentChange = 0.0;
    }

    final Map<String, double> baseCategoryTotals = {};
    for (var expense in baseExpenses) {
      baseCategoryTotals[expense.categoryId] =
          (baseCategoryTotals[expense.categoryId] ?? 0) + expense.amount;
    }

    final Map<String, double> targetCategoryTotals = {};
    for (var expense in targetExpenses) {
      targetCategoryTotals[expense.categoryId] =
          (targetCategoryTotals[expense.categoryId] ?? 0) + expense.amount;
    }

    final allCategoryIds = {
      ...baseCategoryTotals.keys,
      ...targetCategoryTotals.keys,
    }.toList();

    allCategoryIds.sort((a, b) {
      final aTotal = targetCategoryTotals[a] ?? baseCategoryTotals[a] ?? 0;
      final bTotal = targetCategoryTotals[b] ?? baseCategoryTotals[b] ?? 0;
      return bTotal.compareTo(aTotal);
    });

    final baseFormatted = DateFormat('MMM yyyy').format(_baseMonth);
    final targetFormatted = DateFormat('MMM yyyy').format(_targetMonth);

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bg : const Color(0xFFF6F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Monthly Report'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            tooltip: 'Comparison Options',
            onSelected: (value) {
              if (value == 'default') {
                _resetToDefault();
              } else if (value == 'last_year') {
                _compareWithLastYear();
              } else if (value == 'swap') {
                _swapMonths();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'default',
                child: Row(
                  children: [
                    Icon(Icons.restore_rounded, size: 20),
                    SizedBox(width: 10),
                    Expanded(child: Text('Last vs This Month')),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'last_year',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 20),
                    SizedBox(width: 10),
                    Expanded(child: Text('Same Month Last Year')),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'swap',
                child: Row(
                  children: [
                    Icon(Icons.swap_horiz_rounded, size: 20),
                    SizedBox(width: 10),
                    Expanded(child: Text('Swap Months')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section: Compare Months
            const Text(
              'Compare Months',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMedium,
              ),
            ),
            const SizedBox(height: 12),

            // Side-by-Side Delta Cards
            Row(
              children: [
                // Base Month Delta Card
                Expanded(
                  child: InkWell(
                    onTap: () => _showMonthPicker(
                      context: context,
                      isBaseMonth: true,
                      provider: provider,
                      currency: currency,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.surface1 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppTheme.outline : const Color(0xFFE5E5F0),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            baseFormatted,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textMedium,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 240),
                            child: Text(
                              AppUtils.formatCurrency(baseTotal, symbol: currency),
                              key: ValueKey<double>(baseTotal),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Arrow / Swap
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded),
                    color: AppTheme.textMedium,
                    tooltip: 'Swap',
                    onPressed: _swapMonths,
                  ),
                ),

                // Target Month Delta Card (Violet Border Highlighted)
                Expanded(
                  child: InkWell(
                    onTap: () => _showMonthPicker(
                      context: context,
                      isBaseMonth: false,
                      provider: provider,
                      currency: currency,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.surface1 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            targetFormatted,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 240),
                            child: Text(
                              AppUtils.formatCurrency(targetTotal, symbol: currency),
                              key: ValueKey<double>(targetTotal),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // One Insight Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isEqual
                    ? (isDark ? AppTheme.surface1 : Colors.grey.shade100)
                    : isMore
                        ? AppTheme.danger.withOpacity(isDark ? 0.12 : 0.08)
                        : AppTheme.success.withOpacity(isDark ? 0.12 : 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isEqual
                      ? (isDark ? AppTheme.outline : const Color(0xFFE5E5F0))
                      : isMore
                          ? AppTheme.danger.withOpacity(0.35)
                          : AppTheme.success.withOpacity(0.35),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isEqual
                        ? Icons.horizontal_rule_rounded
                        : isMore
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                    color: isEqual
                        ? AppTheme.textMedium
                        : isMore
                            ? AppTheme.danger
                            : AppTheme.success,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isEqual
                          ? 'Same spending in both months'
                          : isMore
                              ? 'You spent ${AppUtils.formatCurrency(difference.abs(), symbol: currency)} more than $baseFormatted (+${percentChange.toStringAsFixed(1)}%)'
                              : 'You saved ${AppUtils.formatCurrency(difference.abs(), symbol: currency)} compared to $baseFormatted (-${percentChange.abs().toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isEqual
                            ? AppTheme.textMedium
                            : isMore
                                ? AppTheme.danger
                                : AppTheme.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Category Breakdown Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$targetFormatted by category',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'vs $baseFormatted',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (allCategoryIds.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surface1 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppTheme.outline : const Color(0xFFE5E5F0),
                    width: 0.5,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'No expenses recorded in the selected months',
                    style: TextStyle(color: AppTheme.textMedium),
                  ),
                ),
              )
            else
              ...allCategoryIds.map((catId) {
                final category = provider.getCategoryById(catId);
                final targetAmt = targetCategoryTotals[catId] ?? 0.0;
                final baseAmt = baseCategoryTotals[catId] ?? 0.0;
                final catDifference = targetAmt - baseAmt;
                final catPercentage = targetTotal > 0 ? (targetAmt / targetTotal * 100) : 0.0;
                final catColor = category != null ? Color(category.colorValue) : AppTheme.primary;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14.0),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.surface1 : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppTheme.outline : const Color(0xFFE5E5F0),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // 40px Icon Tile
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
                                  '$baseFormatted: ${AppUtils.formatCurrency(baseAmt, symbol: currency)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppUtils.formatCurrency(targetAmt, symbol: currency),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              if (catDifference > 0)
                                Text(
                                  '+${AppUtils.formatCurrency(catDifference, symbol: currency)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.danger,
                                  ),
                                )
                              else if (catDifference < 0)
                                Text(
                                  '-${AppUtils.formatCurrency(catDifference.abs(), symbol: currency)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.success,
                                  ),
                                )
                              else
                                const Text(
                                  'No change',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textMedium,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),

                    ],
                  ),
                );
              }),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
