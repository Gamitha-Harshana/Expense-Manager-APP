import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/settings_provider.dart';
import '../../providers/expense_provider.dart';
import 'manage_categories_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<Map<String, dynamic>> colorPalette = [
    {'name': 'Electric Violet', 'color': Color(0xFF7C5CFF)},
    {'name': 'Royal Blue', 'color': Color(0xFF3B82F6)},
    {'name': 'Ocean Cyan', 'color': Color(0xFF06B6D4)},
    {'name': 'Emerald Green', 'color': Color(0xFF10B981)},
    {'name': 'Teal', 'color': Color(0xFF14B8A6)},
    {'name': 'Amber Gold', 'color': Color(0xFFF59E0B)},
    {'name': 'Coral Orange', 'color': Color(0xFFFF6B4A)},
    {'name': 'Rose Pink', 'color': Color(0xFFF43F5E)},
    {'name': 'Deep Purple', 'color': Color(0xFFA855F7)},
    {'name': 'Crimson Red', 'color': Color(0xFFEF4444)},
  ];

  static const List<Map<String, String>> currencies = [
    {'symbol': '\$', 'name': 'US Dollar (\$)'},
    {'symbol': '€', 'name': 'Euro (€)'},
    {'symbol': '£', 'name': 'British Pound (£)'},
    {'symbol': '¥', 'name': 'Japanese Yen (¥)'},
    {'symbol': '₹', 'name': 'Indian Rupee (₹)'},
    {'symbol': 'Rs', 'name': 'Sri Lankan Rupee (Rs)'},
    {'symbol': '₩', 'name': 'Korean Won (₩)'},
    {'symbol': '₽', 'name': 'Russian Ruble (₽)'},
    {'symbol': 'A\$', 'name': 'Australian Dollar (A\$)'},
    {'symbol': 'C\$', 'name': 'Canadian Dollar (C\$)'},
  ];

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.bg : const Color(0xFFF6F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // ---- Appearance Section ----
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 12, 4, 12),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMedium,
              ),
            ),
          ),

          // Theme Preview Swatches Row
          Row(
            children: [
              Expanded(
                child: _buildThemeSwatch(
                  context: context,
                  label: 'Light',
                  mode: ThemeMode.light,
                  currentMode: settingsProvider.themeMode,
                  onTap: () => settingsProvider.setThemeMode(ThemeMode.light),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeSwatch(
                  context: context,
                  label: 'Dark',
                  mode: ThemeMode.dark,
                  currentMode: settingsProvider.themeMode,
                  onTap: () => settingsProvider.setThemeMode(ThemeMode.dark),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeSwatch(
                  context: context,
                  label: 'System',
                  mode: ThemeMode.system,
                  currentMode: settingsProvider.themeMode,
                  onTap: () => settingsProvider.setThemeMode(ThemeMode.system),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ---- Accent Color Section ----
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 8, 4, 10),
            child: Text(
              'Accent Color',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMedium,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: colorPalette.map((item) {
                    final color = item['color'] as Color;
                    final isSelected =
                        settingsProvider.primaryColor.value == color.value;

                    return Tooltip(
                      message: item['name'] as String,
                      child: GestureDetector(
                        onTap: () {
                          settingsProvider.setPrimaryColor(color);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  )
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 22,
                                )
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ---- Currency Section ----
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 8, 4, 10),
            child: Text(
              'Currency',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMedium,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surface1 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.outline : const Color(0xFFE5E5F0),
                width: 0.5,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  settingsProvider.currencySymbol,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              title: const Text(
                'Currency Symbol',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                'Current: ${settingsProvider.currencySymbol}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMedium,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppTheme.textMedium,
              ),
              onTap: () => _showCurrencyPicker(context, settingsProvider),
            ),
          ),
          const SizedBox(height: 24),

          // ---- Categories Section ----
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 8, 4, 10),
            child: Text(
              'Categories',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMedium,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surface1 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.outline : const Color(0xFFE5E5F0),
                width: 0.5,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.category_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              title: const Text(
                'Manage Categories',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: Consumer<ExpenseProvider>(
                builder: (context, provider, _) {
                  return Text(
                    '${provider.categories.length} categories',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textMedium,
                    ),
                  );
                },
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: AppTheme.textMedium,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageCategoriesScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildThemeSwatch({
    required BuildContext context,
    required String label,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == currentMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Container(
                height: 76,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surface1 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primary
                        : (isDark ? AppTheme.outline : const Color(0xFFE5E5F0)),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: _buildSwatchPreview(mode),
              ),
              if (isSelected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? (isDark ? AppTheme.textHigh : AppTheme.primary)
                : AppTheme.textMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildSwatchPreview(ThemeMode mode) {
    if (mode == ThemeMode.light) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F6),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 8,
              width: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      );
    } else if (mode == ThemeMode.dark) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0B0B10),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 8,
              width: 32,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1D1D28),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      );
    } else {
      // System Default: Half light, half dark
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                color: const Color(0xFFF2F2F6),
              ),
            ),
            Expanded(
              child: Container(
                color: const Color(0xFF0B0B10),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showCurrencyPicker(BuildContext context, SettingsProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.surface2 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
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
                    'Select Currency',
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
                    itemCount: currencies.length,
                    itemBuilder: (context, index) {
                      final currency = currencies[index];
                      final isSelected = provider.currencySymbol == currency['symbol'];
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
                          alignment: Alignment.center,
                          child: Text(
                            currency['symbol']!,
                            style: TextStyle(
                              color: isSelected ? AppTheme.primary : null,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(currency['name']!),
                        trailing: isSelected
                            ? Icon(Icons.check_rounded, color: AppTheme.primary)
                            : null,
                        onTap: () {
                          provider.setCurrencySymbol(currency['symbol']!);
                          Navigator.pop(context);
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
}
