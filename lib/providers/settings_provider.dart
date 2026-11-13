import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class SettingsProvider extends ChangeNotifier {
  final _settingsBox = Hive.box(AppConstants.settingsBox);

  static const Color defaultPrimaryColor = Color(0xFF7C5CFF);

  SettingsProvider() {
    // Synchronize AppTheme with persisted color on startup
    AppTheme.setPrimaryColor(primaryColor);
  }

  // Theme logic
  ThemeMode get themeMode {
    final mode = _settingsBox.get('themeMode', defaultValue: 'system');
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String modeString = 'system';
    if (mode == ThemeMode.light) modeString = 'light';
    if (mode == ThemeMode.dark) modeString = 'dark';

    await _settingsBox.put('themeMode', modeString);
    notifyListeners();
  }

  // App UI Accent Color logic
  Color get primaryColor {
    final colorVal = _settingsBox.get(
      'primaryColor',
      defaultValue: defaultPrimaryColor.value,
    );
    return Color(colorVal);
  }

  Future<void> setPrimaryColor(Color color) async {
    await _settingsBox.put('primaryColor', color.value);
    AppTheme.setPrimaryColor(color);
    notifyListeners();
  }

  // Currency logic
  String get currencySymbol {
    return _settingsBox.get('currencySymbol', defaultValue: '\$');
  }

  Future<void> setCurrencySymbol(String symbol) async {
    await _settingsBox.put('currencySymbol', symbol);
    notifyListeners();
  }
}
