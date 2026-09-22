import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/expense_provider.dart';
import '../../core/utils.dart';
import 'add_category_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // ---- Theme Section ----
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Appearance',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Light Mode'),
                  secondary: const Icon(Icons.light_mode),
                  value: ThemeMode.light,
                  groupValue: settingsProvider.themeMode,
                  onChanged: (val) => settingsProvider.setThemeMode(val!),
                ),
                const Divider(height: 0),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark Mode'),
                  secondary: const Icon(Icons.dark_mode),
                  value: ThemeMode.dark,
                  groupValue: settingsProvider.themeMode,
                  onChanged: (val) => settingsProvider.setThemeMode(val!),
                ),
                const Divider(height: 0),
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  secondary: const Icon(Icons.settings_brightness),
                  value: ThemeMode.system,
                  groupValue: settingsProvider.themeMode,
                  onChanged: (val) => settingsProvider.setThemeMode(val!),
                ),
              ],
            ),
          ),

          // ---- Currency Section ----
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Currency',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.monetization_on),
              title: const Text('Currency Symbol'),
              subtitle: Text('Current: ${settingsProvider.currencySymbol}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showCurrencyPicker(context, settingsProvider),
            ),
          ),

          // ---- Categories Section ----
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Categories',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.add_circle_outline),
                  title: const Text('Add Custom Category'),
                  subtitle: const Text('Create your own expense category'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
                    );
                  },
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('Manage Categories'),
                  subtitle: Consumer<ExpenseProvider>(
                    builder: (context, provider, _) {
                      return Text('${provider.categories.length} categories');
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, SettingsProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          itemCount: currencies.length,
          itemBuilder: (context, index) {
            final currency = currencies[index];
            final isSelected = provider.currencySymbol == currency['symbol'];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
                child: Text(
                  currency['symbol']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(currency['name']!),
              trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                provider.setCurrencySymbol(currency['symbol']!);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}
